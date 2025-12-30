package com.nextram.manager;

import android.util.Log;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

public class GitHubStoreLoader {
    private static final String TAG = "NextRAM_GitHubStore";
    private static final String GITHUB_API_URL = "https://api.github.com/repos/Rexamm1t/NextRAM-web/contents/store";
    private static final String RAW_GITHUB_URL = "https://raw.githubusercontent.com/Rexamm1t/NextRAM-web/main/store/";
    
    public List<String> getStoreFileList() {
        List<String> fileList = new ArrayList<>();
        HttpURLConnection connection = null;
        
        try {
            URL url = new URL(GITHUB_API_URL);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("User-Agent", "NextRAM-Android");
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);
            
            int responseCode = connection.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                InputStream inputStream = connection.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                StringBuilder response = new StringBuilder();
                String line;
                
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                reader.close();
                
                JSONArray jsonArray = new JSONArray(response.toString());
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject file = jsonArray.getJSONObject(i);
                    String fileName = file.getString("name");
                    if (fileName.endsWith(".json")) {
                        fileList.add(fileName);
                    }
                }
                
                Log.d(TAG, "Found " + fileList.size() + " store files");
            } else {
                Log.e(TAG, "GitHub API error: " + responseCode);
            }
        } catch (Exception e) {
            Log.e(TAG, "Error fetching store file list: " + e.getMessage());
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
        
        return fileList;
    }
    
    public String getStoreFileContent(String fileName) {
        HttpURLConnection connection = null;
        
        try {
            if (!fileName.endsWith(".json")) {
                return "{\"error\":\"invalid_file_format\",\"message\":\"Only .json files are supported\"}";
            }
            
            URL url = new URL(RAW_GITHUB_URL + fileName);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("User-Agent", "NextRAM-Android");
            connection.setConnectTimeout(10000);
            connection.setReadTimeout(10000);
            
            int responseCode = connection.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                InputStream inputStream = connection.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
                StringBuilder content = new StringBuilder();
                String line;
                
                while ((line = reader.readLine()) != null) {
                    content.append(line).append("\n");
                }
                reader.close();
                
                try {
                    JSONObject jsonObject = new JSONObject(content.toString());
                    
                    JSONObject response = new JSONObject();
                    response.put("name", jsonObject.optString("name", fileName.replace(".json", "")));
                    response.put("description", jsonObject.optString("description", "No description available"));
                    response.put("author", jsonObject.optString("author", "Unknown"));
                    response.put("version", jsonObject.optString("version", "1.0"));
                    response.put("device", jsonObject.optString("device", "Not specified"));
                    response.put("testedOn", jsonObject.optString("testedOn", "Not specified"));
                    response.put("createdDate", jsonObject.optString("createdDate", "Unknown"));
                    response.put("createdWith", jsonObject.optString("createdWith", "NextRAM Configurator"));
                    
                    if (jsonObject.has("config")) {
                        response.put("config", jsonObject.getJSONObject("config"));
                    } else {
                        response.put("config", jsonObject);
                    }
                    
                    response.put("rawContent", content.toString());
                    
                    Log.d(TAG, "Loaded store file: " + fileName);
                    return response.toString();
                } catch (Exception e) {
                    Log.e(TAG, "Invalid JSON in file: " + fileName, e);
                    return "{\"error\":\"invalid_json\",\"message\":\"" + e.getMessage() + "\"}";
                }
            } else {
                Log.e(TAG, "Failed to load file " + fileName + ": " + responseCode);
                return "{\"error\":\"file_not_found\",\"message\":\"HTTP " + responseCode + "\"}";
            }
        } catch (Exception e) {
            Log.e(TAG, "Error fetching store file content: " + e.getMessage());
            return "{\"error\":\"fetch_error\",\"message\":\"" + e.getMessage() + "\"}";
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
    
    public String getStoreConfigsAsJson() {
        try {
            List<String> fileList = getStoreFileList();
            JSONArray configs = new JSONArray();
            
            for (String fileName : fileList) {
                JSONObject config = new JSONObject();
                config.put("fileName", fileName);
                config.put("name", fileName.replace(".json", ""));
                config.put("loaded", false);
                configs.put(config);
            }
            
            JSONObject result = new JSONObject();
            result.put("configs", configs);
            result.put("count", fileList.size());
            result.put("source", "GitHub");
            
            return result.toString();
        } catch (Exception e) {
            Log.e(TAG, "Error creating store JSON: " + e.getMessage());
            return "{\"error\":\"" + e.getMessage() + "\"}";
        }
    }
}