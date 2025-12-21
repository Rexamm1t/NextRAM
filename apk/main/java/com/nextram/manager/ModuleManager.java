package com.nextram.manager;

import android.net.Uri;
import android.content.Context;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Map;
import java.util.HashMap;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;

public class ModuleManager {
    private static final String TAG = "NextRAM_ModuleManager";
    private static final String MODULE_DIR = "/data/adb/modules/NextRAM";
    private static final String MODULE_PROP = MODULE_DIR + "/module.prop";
    private static final String MODULE_UPDATE_DIR = "/data/adb/modules_update/NextRAM";
    private static final String MAGISK_DB = "/data/adb/magisk.db";
    private static final String BUSYBOX_PATH = "/data/adb/magisk/busybox";
    private Context context;
    private RootUtils rootUtils;
    private StringBuilder installLog = new StringBuilder();

    public ModuleManager(Context context) {
        this.context = context;
        this.rootUtils = new RootUtils();
    }

    public boolean isModuleInstalled() {
        if (!rootUtils.isRootAvailable()) {
            return false;
        }
        
        String result = rootUtils.executeCommandWithOutput("[ -d \"" + MODULE_DIR + "\" ] && echo 'installed' || echo 'not_installed'");
        return result != null && result.contains("installed");
    }

    public boolean isModuleEnabled() {
        if (!rootUtils.isRootAvailable()) {
            return false;
        }
        
        String result = rootUtils.executeCommandWithOutput("[ -f \"" + MODULE_DIR + "/disable\" ] && echo 'disabled' || echo 'enabled'");
        return result != null && result.contains("enabled");
    }

    public Map<String, String> getModuleInfo() {
        if (!isModuleInstalled()) {
            return null;
        }
        
        return rootUtils.getModuleProperties();
    }

    public String getModuleVersion() {
        Map<String, String> props = getModuleInfo();
        return (props != null && props.containsKey("version")) ? props.get("version") : "Unknown";
    }

    public String getModuleVersionCode() {
        Map<String, String> props = getModuleInfo();
        return (props != null && props.containsKey("versionCode")) ? props.get("versionCode") : "0";
    }

    public boolean installModule(Uri zipUri) {
        installLog.setLength(0);
        
        if (!rootUtils.isRootAvailable()) {
            installLog.append("ERROR: Root access required\n");
            Log.e(TAG, "Root access required for installation");
            return false;
        }

        File tempZip = null;
        String tempDir = null;
        
        try {
            tempZip = copyUriToTempFile(zipUri, "nextram_install.zip");
            if (tempZip == null || !tempZip.exists()) {
                installLog.append("ERROR: Failed to copy zip file\n");
                Log.e(TAG, "Failed to copy zip file");
                return false;
            }

            if (!validateZip(tempZip.getAbsolutePath())) {
                installLog.append("ERROR: Invalid module zip - missing module.prop or install.sh\n");
                Log.e(TAG, "Invalid module zip");
                return false;
            }

            tempDir = "/data/local/tmp/nextram_extract_" + System.currentTimeMillis();
            installLog.append("Extracting to: ").append(tempDir).append("\n");
            
            rootUtils.executeCommand("rm -rf " + tempDir);
            rootUtils.executeCommand("mkdir -p " + tempDir);
            
            boolean unzipSuccess = rootUtils.executeCommand("unzip -o \"" + tempZip.getAbsolutePath() + "\" -d \"" + tempDir + "\"");
            if (!unzipSuccess) {
                installLog.append("ERROR: Failed to extract zip\n");
                Log.e(TAG, "Failed to extract zip");
                rootUtils.executeCommand("rm -rf " + tempDir);
                return false;
            }

            if (!validateModuleProp(tempDir + "/module.prop")) {
                installLog.append("ERROR: Module validation failed: invalid module.prop (id must be NextRAM)\n");
                Log.e(TAG, "Module validation failed: invalid module.prop");
                rootUtils.executeCommand("rm -rf " + tempDir);
                return false;
            }

            String installScript = tempDir + "/install.sh";
            
            if (!rootUtils.executeCommand("[ -f \"" + installScript + "\" ]")) {
                installLog.append("ERROR: No install.sh found in module\n");
                Log.e(TAG, "No install.sh found in module");
                rootUtils.executeCommand("rm -rf " + tempDir);
                return false;
            }

            rootUtils.executeCommand("chmod 755 \"" + installScript + "\"");
            
            boolean isUpdate = isModuleInstalled();
            String installMode = isUpdate ? "upgrade" : "install";
            installLog.append("Install mode: ").append(installMode).append("\n");
            
            String envVars = "SKIPMOUNT=false PROPFILE=false POSTFSDATA=false LATESTARTSERVICE=true";
            String magiskEnv = "MODPATH=" + MODULE_DIR + " TMPDIR=" + tempDir + " ZIPDIR=" + tempZip.getParent();
            
            String installCmd = "cd \"" + tempDir + "\" && " + envVars + " " + magiskEnv + " " + BUSYBOX_PATH + " ash \"" + installScript + "\" \"" + installMode + "\" 2>&1";
            
            installLog.append("Executing install script...\n");
            String installOutput = rootUtils.executeCommandWithOutput(installCmd);
            installLog.append("Install script output:\n").append(installOutput).append("\n");
            
            int exitCode = rootUtils.executeCommandWithOutput("echo $?").trim().equals("0") ? 0 : 1;
            
            if (exitCode != 0) {
                installLog.append("ERROR: Install script failed with exit code ").append(exitCode).append("\n");
                Log.e(TAG, "Install script failed");
                rootUtils.executeCommand("rm -rf " + tempDir);
                return false;
            }

            rootUtils.executeCommand("mkdir -p \"" + MODULE_DIR + "\"");
            rootUtils.executeCommand("cp -rf \"" + tempDir + "/.\" \"" + MODULE_DIR + "/\" 2>/dev/null || true");
            
            rootUtils.executeCommand("find \"" + MODULE_DIR + "\" -name '*.sh' -exec chmod 755 {} \\;");
            rootUtils.executeCommand("chown -R root:root \"" + MODULE_DIR + "\"");
            
            if (isUpdate) {
                rootUtils.executeCommand("[ -d \"" + MODULE_UPDATE_DIR + "\" ] && rm -rf \"" + MODULE_UPDATE_DIR + "\"");
            }

            rootUtils.executeCommand("rm -rf \"" + tempDir + "\"");
            
            if (tempZip != null) {
                tempZip.delete();
            }

            updateMagiskDatabase();
            installLog.append("SUCCESS: Module ").append(installMode).append("ed successfully\n");
            Log.i(TAG, "Module " + installMode + "ed successfully");
            return true;

        } catch (Exception e) {
            installLog.append("ERROR: Installation exception: ").append(e.getMessage()).append("\n");
            Log.e(TAG, "Installation error: " + e.getMessage(), e);
            
            if (tempDir != null) {
                rootUtils.executeCommand("rm -rf \"" + tempDir + "\"");
            }
            
            if (tempZip != null && tempZip.exists()) {
                tempZip.delete();
            }
            
            return false;
        }
    }

    public boolean uninstallModule() {
        if (!rootUtils.isRootAvailable()) {
            return false;
        }

        try {
            String moduleDisableFile = MODULE_DIR + "/remove";
            rootUtils.executeCommand("touch \"" + moduleDisableFile + "\"");
            
            boolean removed = rootUtils.executeCommand("rm -rf \"" + MODULE_DIR + "\"");
            rootUtils.executeCommand("rm -rf \"" + MODULE_UPDATE_DIR + "\"");

            removeFromMagiskDatabase();

            Log.i(TAG, "Module uninstalled successfully");
            return removed;
        } catch (Exception e) {
            Log.e(TAG, "Uninstall error: " + e.getMessage(), e);
            return false;
        }
    }

    public boolean enableModule() {
        if (!isModuleInstalled()) {
            return false;
        }
        
        boolean success = rootUtils.executeCommand("rm -f \"" + MODULE_DIR + "/disable\"");
        if (success) {
            rootUtils.executeCommand(BUSYBOX_PATH + " sh -c \"if [ -f /data/adb/magisk/magiskboot ]; then /data/adb/magisk/magiskboot --service start; fi\"");
        }
        return success;
    }

    public boolean disableModule() {
        if (!isModuleInstalled()) {
            return false;
        }
        
        boolean success = rootUtils.executeCommand("touch \"" + MODULE_DIR + "/disable\"");
        if (success) {
            rootUtils.executeCommand(BUSYBOX_PATH + " sh -c \"if [ -f /data/adb/magisk/magiskboot ]; then /data/adb/magisk/magiskboot --service stop; fi\"");
        }
        return success;
    }

    private boolean validateZip(String zipPath) {
        try {
            ZipFile zipFile = new ZipFile(zipPath);
            ZipEntry moduleProp = zipFile.getEntry("module.prop");
            ZipEntry installSh = zipFile.getEntry("install.sh");
            
            zipFile.close();
            
            return moduleProp != null && installSh != null;
        } catch (Exception e) {
            Log.e(TAG, "Zip validation error: " + e.getMessage());
            return false;
        }
    }

    private boolean validateModuleProp(String modulePropPath) {
        try {
            String content = rootUtils.readFile(modulePropPath);
            if (content == null || content.startsWith("ERROR:")) {
                return false;
            }
            
            String[] lines = content.split("\n");
            for (String line : lines) {
                line = line.trim();
                if (line.startsWith("id=")) {
                    String idValue = line.substring(3).trim();
                    return idValue.equals("NextRAM");
                }
            }
            return false;
        } catch (Exception e) {
            Log.e(TAG, "Module prop validation error: " + e.getMessage());
            return false;
        }
    }

    private File copyUriToTempFile(Uri uri, String fileName) {
        try {
            InputStream inputStream = context.getContentResolver().openInputStream(uri);
            if (inputStream == null) {
                return null;
            }

            File tempFile = new File(context.getCacheDir(), fileName);
            OutputStream outputStream = new FileOutputStream(tempFile);

            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }

            outputStream.close();
            inputStream.close();
            
            return tempFile;
        } catch (Exception e) {
            Log.e(TAG, "Failed to copy URI to temp file: " + e.getMessage());
            return null;
        }
    }

    private void updateMagiskDatabase() {
        try {
            Map<String, String> props = getModuleInfo();
            if (props == null) {
                return;
            }
            
            String version = props.getOrDefault("version", "1.0");
            String versionCode = props.getOrDefault("versionCode", "1");
            String author = props.getOrDefault("author", "rexamm1t");
            String description = props.getOrDefault("description", "Advanced memory optimization");
            
            String sql = "INSERT OR REPLACE INTO modules (name, version, versionCode, author, description, enabled) " +
                        "VALUES ('NextRAM', '" + version + "', " + versionCode + 
                        ", '" + author + "', '" + description + "', 1)";
            
            rootUtils.executeCommand("sqlite3 " + MAGISK_DB + " \"" + sql.replace("\"", "\\\"") + "\"");
        } catch (Exception e) {
            Log.w(TAG, "Could not update Magisk database: " + e.getMessage());
        }
    }

    private void removeFromMagiskDatabase() {
        try {
            String sql = "DELETE FROM modules WHERE name = 'NextRAM'";
            rootUtils.executeCommand("sqlite3 " + MAGISK_DB + " \"" + sql.replace("\"", "\\\"") + "\"");
        } catch (Exception e) {
            Log.w(TAG, "Could not remove from Magisk database: " + e.getMessage());
        }
    }

    public String getInstallationStatus() {
        if (!rootUtils.isRootAvailable()) {
            return "ROOT_REQUIRED";
        }
        
        if (!isModuleInstalled()) {
            return "NOT_INSTALLED";
        }
        
        return isModuleEnabled() ? "ENABLED" : "DISABLED";
    }

    public Map<String, String> getDetailedStatus() {
        Map<String, String> status = new HashMap<>();
        
        boolean rootAvailable = rootUtils.isRootAvailable();
        status.put("root_available", String.valueOf(rootAvailable));
        
        if (rootAvailable) {
            boolean installed = isModuleInstalled();
            status.put("installed", String.valueOf(installed));
            
            if (installed) {
                status.put("enabled", String.valueOf(isModuleEnabled()));
                Map<String, String> info = getModuleInfo();
                if (info != null) {
                    status.put("version", info.getOrDefault("version", "Unknown"));
                    status.put("versionCode", info.getOrDefault("versionCode", "0"));
                    status.put("author", info.getOrDefault("author", "Unknown"));
                    status.put("id", info.getOrDefault("id", "Unknown"));
                }
            } else {
                status.put("enabled", "false");
            }
        }
        
        return status;
    }
    
    public String getInstallLog() {
        return installLog.toString();
    }
    
    public void clearInstallLog() {
        installLog.setLength(0);
    }
}