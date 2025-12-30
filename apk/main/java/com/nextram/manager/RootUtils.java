package com.nextram.manager;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class RootUtils {
    
    public boolean isRootAvailable() {
        try {
            Process process = Runtime.getRuntime().exec("su -c id");
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            process.waitFor();
            String output = reader.readLine();
            boolean firstCheck = process.exitValue() == 0 && output != null && output.contains("uid=0");
            
            if (!firstCheck) {
                return false;
            }
            
            Process process2 = Runtime.getRuntime().exec("su -c echo 'root_test'");
            BufferedReader reader2 = new BufferedReader(new InputStreamReader(process2.getInputStream()));
            process2.waitFor();
            String output2 = reader2.readLine();
            boolean secondCheck = process2.exitValue() == 0 && output2 != null && output2.contains("root_test");
            
            return secondCheck;
        } catch (Exception e) {
            return false;
        }
    }
    
    public boolean isRootAvailableWithTest() {
        try {
            Process process = Runtime.getRuntime().exec("su -c id");
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            process.waitFor();
            String output = reader.readLine();
            boolean firstCheck = process.exitValue() == 0 && output != null && output.contains("uid=0");
            
            if (!firstCheck) return false;
            
            Process process2 = Runtime.getRuntime().exec("su -c echo 'root_test'");
            BufferedReader reader2 = new BufferedReader(new InputStreamReader(process2.getInputStream()));
            process2.waitFor();
            String output2 = reader2.readLine();
            boolean secondCheck = process2.exitValue() == 0 && output2 != null && output2.contains("root_test");
            
            return secondCheck;
        } catch (Exception e) {
            return false;
        }
    }
    
    public String readFile(String filePath) {
        if (!isRootAvailable()) {
            return "ERROR: Root access not available. Please grant root permissions.";
        }
        
        try {
            Process process = Runtime.getRuntime().exec("su");
            DataOutputStream os = new DataOutputStream(process.getOutputStream());
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            
            os.writeBytes("cat " + filePath + "\n");
            os.writeBytes("exit\n");
            os.flush();
            
            StringBuilder output = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
            
            process.waitFor();
            return output.toString();
        } catch (IOException | InterruptedException e) {
            return "ERROR: " + e.getMessage();
        }
    }
    
    public boolean writeFile(String filePath, String content) {
        if (!isRootAvailable()) {
            return false;
        }
        
        try {
            Process process = Runtime.getRuntime().exec("su");
            DataOutputStream os = new DataOutputStream(process.getOutputStream());
            
            String escapedContent = content
                .replace("'", "'\\''")
                .replace("\"", "\\\"")
                .replace("$", "\\$")
                .replace("`", "\\`")
                .replace("!", "\\!");
            
            String tempFile = "/data/local/tmp/service_sh_temp";
            os.writeBytes("echo '" + escapedContent + "' > " + tempFile + "\n");

            os.writeBytes("cp " + tempFile + " " + filePath + "\n");
            os.writeBytes("chmod 755 " + filePath + "\n");
            os.writeBytes("rm " + tempFile + "\n");
            
            os.writeBytes("exit\n");
            os.flush();
            
            process.waitFor();
            return process.exitValue() == 0;
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean executeCommand(String command) {
        if (!isRootAvailable()) {
            return false;
        }
        
        try {
            Process process = Runtime.getRuntime().exec("su");
            DataOutputStream os = new DataOutputStream(process.getOutputStream());
            
            os.writeBytes(command + "\n");
            os.writeBytes("exit\n");
            os.flush();
            
            process.waitFor();
            return process.exitValue() == 0;
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public String executeCommandWithOutput(String command) {
        if (!isRootAvailable()) {
            return "ERROR: Root access not available";
        }
        
        try {
            Process process = Runtime.getRuntime().exec("su");
            DataOutputStream os = new DataOutputStream(process.getOutputStream());
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            
            os.writeBytes(command + "\n");
            os.writeBytes("exit\n");
            os.flush();
            
            StringBuilder output = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
            
            process.waitFor();
            return output.toString();
        } catch (IOException | InterruptedException e) {
            return "ERROR: " + e.getMessage();
        }
    }
    
    public String getRootStatus() {
        if (isRootAvailable()) {
            return "Root access: Granted";
        } else {
            return "Root access: Required";
        }
    }
    
    public Map<String, String> getModuleProperties() {
        if (!isRootAvailable()) {
            return null;
        }
        
        try {
            String content = readFile("/data/adb/modules/NextRAM/module.prop");
            if (content.startsWith("ERROR:")) {
                return null;
            }
            
            Map<String, String> props = new HashMap<>();
            String[] lines = content.split("\n");
            
            for (String line : lines) {
                line = line.trim();
                if (line.startsWith("#") || line.isEmpty()) {
                    continue;
                }
                
                int separatorIndex = line.indexOf('=');
                if (separatorIndex != -1) {
                    String key = line.substring(0, separatorIndex).trim();
                    String value = line.substring(separatorIndex + 1).trim();
                    props.put(key, value);
                }
            }
            
            return props;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    public Map<String, String> getModulePropInfo() {
        Map<String, String> props = getModuleProperties();
        if (props == null) {
            return null;
        }
        
        if (props.containsKey("author")) {
            String authors = props.get("author");
            authors = authors.replaceAll(",\\s+", ", ").trim();
            props.put("author_formatted", authors);
        }
        
        return props;
    }
    
    public String getModuleVersion() {
        Map<String, String> props = getModuleProperties();
        return (props != null && props.containsKey("version")) ? props.get("version") : "Unknown";
    }
    
    public String getModuleVersionCode() {
        Map<String, String> props = getModuleProperties();
        return (props != null && props.containsKey("versionCode")) ? props.get("versionCode") : "0";
    }
    
    public String getModuleName() {
        Map<String, String> props = getModuleProperties();
        return (props != null && props.containsKey("name")) ? props.get("name") : "NextRAM";
    }
    
    public String getModuleId() {
        Map<String, String> props = getModuleProperties();
        return (props != null && props.containsKey("id")) ? props.get("id") : "NextRAM";
    }
    
    public String getModuleAuthor() {
        Map<String, String> props = getModuleProperties();
        return (props != null && props.containsKey("author")) ? props.get("author") : "Unknown";
    }
    
    public String getModuleDescription() {
        Map<String, String> props = getModuleProperties();
        return (props != null && props.containsKey("description")) ? props.get("description") : "Advanced memory optimization for Android devices";
    }
    
    public String getModuleAllInfo() {
        Map<String, String> props = getModuleProperties();
        if (props == null) {
            return "ERROR: Could not read module properties";
        }
        
        StringBuilder info = new StringBuilder();
        for (Map.Entry<String, String> entry : props.entrySet()) {
            info.append(entry.getKey()).append(": ").append(entry.getValue()).append("\n");
        }
        
        return info.toString();
    }

    public boolean copyFile(String source, String destination) {
        if (!isRootAvailable()) {
            return false;
        }
        
        String command = "cp \"" + source + "\" \"" + destination + "\"";
        return executeCommand(command);
    }

    public boolean createDirectory(String path) {
        if (!isRootAvailable()) {
            return false;
        }
        
        String command = "mkdir -p \"" + path + "\"";
        return executeCommand(command);
    }

    public boolean deleteDirectory(String path) {
        if (!isRootAvailable()) {
            return false;
        }
        
        String command = "rm -rf \"" + path + "\"";
        return executeCommand(command);
    }

    public boolean setPermissions(String path, String permissions) {
        if (!isRootAvailable()) {
            return false;
        }
        
        String command = "chmod " + permissions + " \"" + path + "\"";
        return executeCommand(command);
    }

    public boolean setOwner(String path, String owner) {
        if (!isRootAvailable()) {
            return false;
        }
        
        String command = "chown " + owner + " \"" + path + "\"";
        return executeCommand(command);
    }

    public String exportConfig() {
        String content = readFile("/data/adb/modules/NextRAM/config.conf");
        if (content.startsWith("ERROR:")) {
            return content;
        }
        
        try {
            String timestamp = new SimpleDateFormat("yyyy-MM-dd-HHmmss").format(new Date());
            String fileName = "NextRAM-config-" + timestamp + ".conf";
            String filePath = "/storage/emulated/0/Download/" + fileName;
            
            boolean success = writeFile(filePath, content);
            return success ? filePath : "ERROR: Failed to write file to Downloads";
        } catch (Exception e) {
            return "ERROR: " + e.getMessage();
        }
    }

    public boolean importConfig(String content) {
        if (!isRootAvailable()) {
            return false;
        }
        
        try {
            String currentContent = readFile("/data/adb/modules/NextRAM/config.conf");
            if (currentContent.startsWith("ERROR:")) {
                return writeFile("/data/adb/modules/NextRAM/config.conf", content);
            }
            
            String mergedContent = mergeConfigs(currentContent, content);
            return writeFile("/data/adb/modules/NextRAM/config.conf", mergedContent);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    private String mergeConfigs(String currentContent, String importedContent) {
        Map<String, String> currentConfig = new HashMap<>();
        Map<String, String> importedConfig = new HashMap<>();
        
        parseConfigContent(currentContent, currentConfig);
        parseConfigContent(importedContent, importedConfig);
        
        currentConfig.putAll(importedConfig);
        
        StringBuilder merged = new StringBuilder();
        for (Map.Entry<String, String> entry : currentConfig.entrySet()) {
            merged.append(entry.getKey()).append("=").append(entry.getValue()).append("\n");
        }
        
        return merged.toString();
    }
    
    private void parseConfigContent(String content, Map<String, String> config) {
        String[] lines = content.split("\n");
        for (String line : lines) {
            line = line.trim();
            if (line.isEmpty() || line.startsWith("#")) {
                continue;
            }
            
            int equalsIndex = line.indexOf('=');
            if (equalsIndex > 0) {
                String key = line.substring(0, equalsIndex).trim();
                String value = line.substring(equalsIndex + 1).trim();
                config.put(key, value);
            }
        }
    }
    
    public boolean writeFileToDownloads(String fileName, String content) {
        if (!isRootAvailable()) {
            return false;
        }
        
        try {
            String filePath = "/storage/emulated/0/Download/" + fileName;
            return writeFile(filePath, content);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}