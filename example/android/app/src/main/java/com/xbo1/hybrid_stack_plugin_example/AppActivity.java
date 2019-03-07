package com.xbo1.hybrid_stack_plugin_example;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class AppActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
    }
}
