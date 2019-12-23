package io.agora.tutorials1v1vcall;

import com.google.gson.Gson;

public class RetData {

    public TokenData data;

    public boolean success;

    public static RetData FromJson(String jsonStr)
    {
        Gson gson = new Gson();

        RetData data = gson.fromJson(jsonStr, RetData.class);
        return data;
    }
}
