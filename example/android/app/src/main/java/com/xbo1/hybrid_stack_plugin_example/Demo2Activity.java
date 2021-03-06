package com.xbo1.hybrid_stack_plugin_example;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.xbo1.hybrid_stack_plugin.HybridStackPlugin;

import org.json.JSONObject;

import java.io.Serializable;
import java.util.HashMap;

public class Demo2Activity extends Activity {
    static int pageId = 0;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.demo);
        Intent data = getIntent();
        if (data != null) {
            int id = data.getIntExtra("pageId", 0);
            TextView tvInfo = findViewById(R.id.tv_info);
            tvInfo.setText("原生页面2:"+id);
            Serializable initArgs = data.getSerializableExtra("args");
            if (initArgs instanceof HashMap) {
                HashMap<String, Object> args = (HashMap<String, Object>)initArgs;
                JSONObject json = new JSONObject(args);
                //包含了pageId和args为key的数据
                Toast.makeText(this, "初始化参数:"+json.toString(), Toast.LENGTH_LONG).show();
            }

        }
        Button btn1 = findViewById(R.id.btn_jump_to_flutter);
        btn1.setOnClickListener((View view)-> {
            HashMap<String, Object> args = new HashMap<>();
            args.put("id", pageId);
            HybridStackPlugin.pushFlutterPage(Demo2Activity.this,"demo2", args);
        });
        Button btn2 = findViewById(R.id.btn_jump_to_native);
        btn2.setOnClickListener((View view)-> {
            pageId++;
            Intent intent = new Intent(Demo2Activity.this, DemoActivity.class);
            intent.putExtra("pageId", pageId);
            startActivity(intent);
        });
    }

    @Override
    public void onBackPressed() {
//        super.onBackPressed();
        Intent intent = new Intent();
        intent.putExtra("args", "我是返回值");
        setResult(918, intent);
        finish();
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == HybridStackPlugin.NATIVE_REQUEST) {
            Serializable dataArgs = data.getSerializableExtra(HybridStackPlugin.EXTRA_KEY);
            HashMap<String, Object> args = new HashMap<>();
            if (dataArgs instanceof HashMap) {
                args = (HashMap<String, Object>)dataArgs;
            }
            JSONObject json = new JSONObject(args);
            Toast.makeText(this, json.toString(), Toast.LENGTH_LONG).show();
        }

    }
}
