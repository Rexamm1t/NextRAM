package com.nextram.manager;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import android.content.Intent;
import android.net.Uri;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.FileProvider;
import java.io.File;
import java.util.Map;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {
    private static final int FILE_PICK_REQUEST = 1001;
    private WebView webView;
    private RootUtils rootUtils;
    private ModuleManager moduleManager;
    private ValueCallback<Uri[]> fileUploadCallback;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        rootUtils = new RootUtils();
        moduleManager = new ModuleManager(this);
        
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
                Intent intent = fileChooserParams.createIntent();
                startActivityForResult(intent, FILE_PICK_REQUEST);
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
                String dataString = data.getDataString();
                if (dataString != null) {
                    results = new Uri[]{Uri.parse(dataString)};
                }
            }
            fileUploadCallback.onReceiveValue(results);
            fileUploadCallback = null;
        }
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        updateWebViewRootStatus();
    }

    private void updateWebViewRootStatus() {
        if (webView != null) {
            String script = "if (typeof nextram !== 'undefined') { " +
                    "nextram.hasRoot = " + rootUtils.isRootAvailable() + "; " +
                    "nextram.updateHomeStatus(); }";
            webView.evaluateJavascript(script, null);
        }
    }

    public class JavaScriptInterface {
        @JavascriptInterface
        public String readServiceSh() {
            return rootUtils.readFile("/data/adb/modules/NextRAM/config.conf");
        }
        
        @JavascriptInterface
        public boolean writeServiceSh(String content) {
            return rootUtils.writeFile("/data/adb/modules/NextRAM/config.conf", content);
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
            return rootUtils.isRootAvailable();
        }
        
        @JavascriptInterface
        public String getRootStatus() {
            return rootUtils.getRootStatus();
        }
        
        @JavascriptInterface
        public String testRoot() {
            return rootUtils.executeCommandWithOutput("echo 'Root test successful'");
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
        public boolean installModule(String fileUri) {
            try {
                Uri uri = Uri.parse(fileUri);
                return moduleManager.installModule(uri);
            } catch (Exception e) {
                return false;
            }
        }
        
        @JavascriptInterface
        public boolean uninstallModule() {
            return moduleManager.uninstallModule();
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
        public String getInstallLog() {
            return moduleManager.getInstallLog();
        }
        
        @JavascriptInterface
        public void clearInstallLog() {
            moduleManager.clearInstallLog();
        }
        
        @JavascriptInterface
        public void openFilePicker() {
            Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
            intent.setType("application/zip");
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            startActivityForResult(Intent.createChooser(intent, "Select NextRAM Module ZIP"), FILE_PICK_REQUEST);
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