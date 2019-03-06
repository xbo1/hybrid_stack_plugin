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
    public void setAppContext(Context context){
//        if (mAppContext != null) {
//            return;
//        }
        mAppContext = context;
    }
    public void addRoute(String pageId, Class clazz) {
        routes.put(pageId, clazz);
    }

    public void openNativePage(String pageId) {
        if (!routes.containsKey(pageId)) {
            return;
        }
        Intent intent = new Intent(mAppContext,routes.get(pageId));
//        intent.setData(Uri.parse(url));
        intent.setAction(Intent.ACTION_VIEW);
        mAppContext.startActivity(intent);
    }
}
