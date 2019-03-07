package com.xbo1.hybrid_stack_plugin;

import android.content.Context;
import android.content.Intent;

import java.util.HashMap;
import java.util.Map;

public class HSRouter {
    private static HSRouter sRouterInst;
    private Context mAppContext;
    public static HSRouter sharedInstance(){
        if(sRouterInst==null){
            sRouterInst = new HSRouter();
        }
        return sRouterInst;
    }
    Map<String,Class> routes = new HashMap<>();
    void setAppContext(Context context){
        mAppContext = context;
    }
    void addRoute(String pageId, Class clazz) {
        routes.put(pageId, clazz);
    }

    void openNativePage(String pageId, HashMap<String, Object> args) {
        if (!routes.containsKey(pageId)) {
            return;
        }
        Intent intent = new Intent(mAppContext,routes.get(pageId));
//        intent.setData(Uri.parse(url));
//        intent.setAction(Intent.ACTION_VIEW);
        intent.putExtra("args", args);
        mAppContext.startActivity(intent);
    }

    void openFlutterPage(Context context, String pageId, HashMap<String, Object> args) {
        Intent intent = new Intent(context, HSFlutterActivity.class);
        intent.putExtra("args", args);
        intent.putExtra("pageId", pageId);
        context.startActivity(intent);
    }
}
