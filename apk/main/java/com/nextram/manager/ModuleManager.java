package com.nextram.manager;

import android.content.Context;
import android.util.Log;
import java.util.Map;
import java.util.HashMap;

public class ModuleManager {
    private static final String TAG = "NextRAM_ModuleManager";
    private static final String MODULE_DIR = "/data/adb/modules/NextRAM";
    private static final String MODULE_PROP = MODULE_DIR + "/module.prop";
    private static final String MAGISK_DB = "/data/adb/magisk.db";
    private static final String BUSYBOX_PATH = "/data/adb/magisk/busybox";
    private Context context;
    private RootUtils rootUtils;

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
        
        if (!isModuleInstalled()) {
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
                boolean enabled = isModuleEnabled();
                status.put("enabled", String.valueOf(enabled));
                
                Map<String, String> info = getModuleInfo();
                if (info != null) {
                    status.put("version", info.getOrDefault("version", "Unknown"));
                    status.put("versionCode", info.getOrDefault("versionCode", "0"));
                    status.put("author", info.getOrDefault("author", "Unknown"));
                    status.put("id", info.getOrDefault("id", "Unknown"));
                    status.put("name", info.getOrDefault("name", "NextRAM"));
                    status.put("description", info.getOrDefault("description", ""));
                }
            } else {
                status.put("enabled", "false");
                status.put("version", "Unknown");
                status.put("versionCode", "0");
                status.put("author", "Unknown");
                status.put("id", "NextRAM");
                status.put("name", "NextRAM");
                status.put("description", "");
            }
        } else {
            status.put("installed", "false");
            status.put("enabled", "false");
            status.put("version", "Unknown");
            status.put("versionCode", "0");
            status.put("author", "Unknown");
            status.put("id", "NextRAM");
            status.put("name", "NextRAM");
            status.put("description", "");
        }
        
        return status;
    }
    
    public Map<String, String> getStoreConfigs() {
        if (!rootUtils.isRootAvailable()) {
            return null;
        }
        
        Map<String, String> configs = new HashMap<>();
        String storeDir = MODULE_DIR + "/store";
        String result = rootUtils.executeCommandWithOutput(
            "[ -d \"" + storeDir + "\" ] && echo 'exists' || echo 'not_exists'"
        );
        
        if (!result.contains("exists")) {
            return configs;
        }
        
        String listCommand = "find \"" + storeDir + "\" -name \"*.json\" -type f";
        String filesList = rootUtils.executeCommandWithOutput(listCommand);
        
        if (filesList == null || filesList.trim().isEmpty()) {
            return configs;
        }
        
        String[] files = filesList.split("\n");
        for (String filePath : files) {
            filePath = filePath.trim();
            if (filePath.isEmpty()) continue;
            
            try {
                String content = rootUtils.readFile(filePath);
                if (content != null && !content.startsWith("ERROR:")) {
                    String fileName = new java.io.File(filePath).getName();
                    configs.put(fileName, content);
                }
            } catch (Exception e) {
                Log.e(TAG, "Error reading store file: " + filePath, e);
            }
        }
        
        return configs;
    }
    
    public String getStoreFileContent(String fileName) {
        if (!rootUtils.isRootAvailable()) {
            return null;
        }
        
        String filePath = MODULE_DIR + "/store/" + fileName;
        String content = rootUtils.readFile(filePath);
        
        if (content != null && content.startsWith("ERROR:")) {
            return null;
        }
        
        return content;
    }
}