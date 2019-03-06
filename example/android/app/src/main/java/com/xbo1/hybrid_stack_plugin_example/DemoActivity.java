package com.xbo1.hybrid_stack_plugin_example;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.xbo1.hybrid_stack_plugin.HybridStackPlugin;

import java.util.HashMap;

public class DemoActivity extends Activity {
    static int pageId = 0;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.demo);
        Intent data = getIntent();
        if (data != null) {
            int id = data.getIntExtra("pageId", 0);
            TextView tvInfo = findViewById(R.id.tv_info);
            tvInfo.setText("原生页面:"+id);
        }
        Button btn1 = findViewById(R.id.btn_jump_to_flutter);
        btn1.setOnClickListener((View view)-> {
            HashMap<String, Object> args = new HashMap<>();
            HybridStackPlugin.getInstance().openFlutterPage("demo", args);
            Intent intent = new Intent(DemoActivity.this, MainActivity.class);
            startActivity(intent);
        });
        Button btn2 = findViewById(R.id.btn_jump_to_native);
        btn2.setOnClickListener((View view)-> {
            pageId++;
            Intent intent = new Intent(DemoActivity.this, Demo2Activity.class);
            intent.putExtra("pageId", pageId);
            startActivity(intent);
        });
    }
}
