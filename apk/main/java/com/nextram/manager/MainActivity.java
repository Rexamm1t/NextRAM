package com.nextram.manager;

import android.annotation.SuppressLint;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.OpenableColumns;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.util.Map;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {
    private static final int FILE_PICK_REQUEST = 1001;
    private WebView webView;
    private RootUtils rootUtils;
    private ModuleManager moduleManager;
    private GitHubStoreLoader githubStoreLoader;
    private ValueCallback<Uri[]> fileUploadCallback;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        rootUtils = new RootUtils();
        moduleManager = new ModuleManager(this);
        githubStoreLoader = new GitHubStoreLoader();
        
        webView = findViewById(R.id.webview);
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setAllowFileAccess(true);
        webSettings.setAllowContentAccess(true);
        
        webView.addJavascriptInterface(new JavaScriptInterface(), "AndroidRoot");
        
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return false;
            }
        });
        
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {
                fileUploadCallback = filePathCallback;
                
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
                intent.setType("*/*");
                intent.putExtra(Intent.EXTRA_MIME_TYPES, new String[] {
                    "text/plain", 
                    "application/octet-stream",
                    "text/x-config"
                });
                intent.putExtra(Intent.EXTRA_TITLE, "Выберите конфигурационный файл (.conf)");
                
                try {
                    startActivityForResult(Intent.createChooser(intent, "Выберите .conf файл"), FILE_PICK_REQUEST);
                } catch (ActivityNotFoundException e) {
                    Toast.makeText(MainActivity.this, 
                        "Установите файловый менеджер для выбора файлов", 
                        Toast.LENGTH_SHORT).show();
                    return false;
                }
                return true;
            }
        });
        
        webView.loadUrl("file:///android_asset/www/index.html");
    }
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        
        if (requestCode == FILE_PICK_REQUEST && fileUploadCallback != null) {
            Uri[] results = null;
            if (resultCode == RESULT_OK && data != null) {
                Uri uri = data.getData();
                String fileName = getFileName(uri);
                
                if (fileName != null && (fileName.endsWith(".conf") || fileName.endsWith(".json"))) {
                    results = new Uri[]{uri};
                } else {
                    Toast.makeText(this, 
                        "Пожалуйста, выберите файл с расширением .conf или .json", 
                        Toast.LENGTH_LONG).show();
                }
            }
            fileUploadCallback.onReceiveValue(results);
            fileUploadCallback = null;
        }
    }
    
    private String getFileName(Uri uri) {
        String result = null;
        if (uri.getScheme().equals("content")) {
            try (Cursor cursor = getContentResolver().query(uri, null, null, null, null)) {
                if (cursor != null && cursor.moveToFirst()) {
                    int index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME);
                    if (index != -1) {
                        result = cursor.getString(index);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (result == null) {
            result = uri.getPath();
            int cut = result.lastIndexOf('/');
            if (cut != -1) {
                result = result.substring(cut + 1);
            }
        }
        return result;
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        updateWebViewRootStatus();
        applyAppearanceSettings();
    }

    private void updateWebViewRootStatus() {
        if (webView != null) {
            boolean rootAvailable = rootUtils.isRootAvailableWithTest();
            
            String script = "if (typeof nextram !== 'undefined') { " +
                    "nextram.hasRoot = " + rootAvailable + "; " +
                    "nextram.updateRootStatus(); " +
                    "nextram.updateHomeStatus(); }";
            webView.evaluateJavascript(script, null);
        }
    }
    
    private void applyAppearanceSettings() {
        if (webView != null) {
            SharedPreferences prefs = getSharedPreferences("app_settings", MODE_PRIVATE);
            boolean glassEffect = prefs.getBoolean("glass_effect", false);
            boolean materialYou = prefs.getBoolean("material_you", false);
            String accentColor = prefs.getString("accent_color", "orange");
            
            String jsCode = String.format(
                "if (typeof nextram !== 'undefined') { " +
                "nextram.applyAppearanceSettings(%b, %b, '%s'); }",
                glassEffect, materialYou, accentColor
            );
            webView.evaluateJavascript(jsCode, null);
        }
    }
    
    public void refreshRootStatus() {
        updateWebViewRootStatus();
    }

    public class JavaScriptInterface {
        @JavascriptInterface
        public String readServiceSh() {
            return rootUtils.readFile("/data/adb/modules/NextRAM/config.conf");
        }
        
        @JavascriptInterface
        public String forceReadServiceSh() {
            if (!rootUtils.isRootAvailable()) {
                return "ERROR: Root access not available";
            }
            
            try {
                Process process = Runtime.getRuntime().exec("su");
                DataOutputStream os = new DataOutputStream(process.getOutputStream());
                BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                
                os.writeBytes("cat /data/adb/modules/NextRAM/config.conf 2>/dev/null || echo 'ERROR: File not found'\n");
                os.writeBytes("exit\n");
                os.flush();
                
                StringBuilder output = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
                
                process.waitFor();
                String result = output.toString();
                if (result.trim().startsWith("ERROR:")) {
                    return "ERROR: File not found";
                }
                return result;
            } catch (Exception e) {
                return "ERROR: " + e.getMessage();
            }
        }
        
        @JavascriptInterface
        public boolean writeServiceSh(String content) {
            return rootUtils.writeFile("/data/adb/modules/NextRAM/config.conf", content);
        }
        
        @JavascriptInterface
        public boolean writeFile(String filePath, String content) {
            return rootUtils.writeFile(filePath, content);
        }
        
        @JavascriptInterface
        public boolean applyConfiguration() {
            return rootUtils.executeCommand("/data/adb/modules/NextRAM/service.sh apply");
        }
        
        @JavascriptInterface
        public boolean restartService() {
            return rootUtils.executeCommand("/data/adb/modules/NextRAM/service.sh restart");
        }
        
        @JavascriptInterface
        public String executeCommand(String command) {
            return rootUtils.executeCommandWithOutput(command);
        }
        
        @JavascriptInterface
        public void showToast(String message) {
            Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT).show();
        }
        
        @JavascriptInterface
        public boolean hasRootAccess() {
            return rootUtils.isRootAvailableWithTest();
        }
        
        @JavascriptInterface
        public String getRootStatus() {
            return rootUtils.getRootStatus();
        }
        
        @JavascriptInterface
        public String testRoot() {
            String result = rootUtils.executeCommandWithOutput("echo 'root_test'");
            if (result.contains("root_test")) {
                return "root_test";
            }
            return "ERROR: Root test failed";
        }
        
        @JavascriptInterface
        public String getModuleVersion() {
            return rootUtils.getModuleVersion();
        }
        
        @JavascriptInterface
        public String getModuleVersionCode() {
            return rootUtils.getModuleVersionCode();
        }
        
        @JavascriptInterface
        public String getModuleName() {
            return rootUtils.getModuleName();
        }
        
        @JavascriptInterface
        public String getModuleId() {
            return rootUtils.getModuleId();
        }
        
        @JavascriptInterface
        public String getModuleAuthor() {
            return rootUtils.getModuleAuthor();
        }
        
        @JavascriptInterface
        public String getModuleDescription() {
            return rootUtils.getModuleDescription();
        }
        
        @JavascriptInterface
        public String getModuleAllInfo() {
            return rootUtils.getModuleAllInfo();
        }
        
        @JavascriptInterface
        public String readModuleProp() {
            return rootUtils.readFile("/data/adb/modules/NextRAM/module.prop");
        }
        
        @JavascriptInterface
        public boolean isModuleInstalled() {
            return moduleManager.isModuleInstalled();
        }
        
        @JavascriptInterface
        public boolean isModuleEnabled() {
            return moduleManager.isModuleEnabled();
        }
        
        @JavascriptInterface
        public String getModuleStatus() {
            return moduleManager.getInstallationStatus();
        }
        
        @JavascriptInterface
        public String getModuleDetails() {
            try {
                Map<String, String> details = moduleManager.getDetailedStatus();
                JSONObject json = new JSONObject();
                for (Map.Entry<String, String> entry : details.entrySet()) {
                    json.put(entry.getKey(), entry.getValue());
                }
                return json.toString();
            } catch (Exception e) {
                return "{\"root_available\":\"false\",\"installed\":\"false\",\"enabled\":\"false\"}";
            }
        }
        
        @JavascriptInterface
        public boolean enableModule() {
            return moduleManager.enableModule();
        }
        
        @JavascriptInterface
        public boolean disableModule() {
            return moduleManager.disableModule();
        }
        
        @JavascriptInterface
        public String getModulePath() {
            return "/data/adb/modules/NextRAM";
        }
        
        @JavascriptInterface
        public boolean checkFileExists(String path) {
            String result = rootUtils.executeCommandWithOutput("[ -f \"" + path + "\" ] && echo 'exists' || echo 'not_exists'");
            return result.contains("exists");
        }
        
        @JavascriptInterface
        public boolean checkDirExists(String path) {
            String result = rootUtils.executeCommandWithOutput("[ -d \"" + path + "\" ] && echo 'exists' || echo 'not_exists'");
            return result.contains("exists");
        }
        
        @JavascriptInterface
        public String getFileContent(String path) {
            return rootUtils.readFile(path);
        }
        
        @JavascriptInterface
        public String getStoreConfigs() {
            return githubStoreLoader.getStoreConfigsAsJson();
        }
        
        @JavascriptInterface
        public String getStoreConfigContent(String fileName) {
            return githubStoreLoader.getStoreFileContent(fileName);
        }
        
        @JavascriptInterface
        public String exportConfiguration() {
            return rootUtils.exportConfig();
        }
        
        @JavascriptInterface
        public boolean importConfiguration(String content) {
            return rootUtils.importConfig(content);
        }
        
        @JavascriptInterface
        public String getModuleFullInfo() {
            Map<String, String> props = rootUtils.getModulePropInfo();
            if (props == null) {
                return "ERROR: Could not read module properties";
            }
            
            try {
                JSONObject json = new JSONObject();
                json.put("id", props.getOrDefault("id", "NextRAM"));
                json.put("version", props.getOrDefault("version", "Unknown"));
                json.put("versionCode", props.getOrDefault("versionCode", "0"));
                json.put("status", props.getOrDefault("status", "Unknown"));
                json.put("authors", props.getOrDefault("author_formatted", props.getOrDefault("author", "Unknown")));
                json.put("name", props.getOrDefault("name", "NextRAM Module"));
                json.put("description", props.getOrDefault("description", ""));
                
                return json.toString();
            } catch (Exception e) {
                return "ERROR: " + e.getMessage();
            }
        }
        
        @JavascriptInterface
        public void setAppearanceSettings(String glassEffect, String materialYou) {
            SharedPreferences prefs = getSharedPreferences("app_settings", MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            
            editor.putBoolean("glass_effect", "true".equals(glassEffect));
            editor.putBoolean("material_you", "true".equals(materialYou));
            
            String accentColor = prefs.getString("accent_color", "orange");
            editor.putString("accent_color", accentColor);
            
            editor.apply();
            
            applyAppearanceSettings();
        }
        
        @JavascriptInterface
        public String getAppearanceSettings() {
            SharedPreferences prefs = getSharedPreferences("app_settings", MODE_PRIVATE);
            boolean glassEffect = prefs.getBoolean("glass_effect", false);
            boolean materialYou = prefs.getBoolean("material_you", false);
            String accentColor = prefs.getString("accent_color", "orange");
            
            try {
                JSONObject json = new JSONObject();
                json.put("glass_effect", glassEffect);
                json.put("material_you", materialYou);
                json.put("accent_color", accentColor);
                return json.toString();
            } catch (Exception e) {
                return "{\"glass_effect\":false,\"material_you\":false,\"accent_color\":\"orange\"}";
            }
        }
        
        @JavascriptInterface
        public void refreshRootStatus() {
            updateWebViewRootStatus();
        }
    }
    
    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}