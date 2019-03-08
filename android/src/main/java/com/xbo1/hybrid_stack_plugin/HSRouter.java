package com.xbo1.hybrid_stack_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Stack;

public class HSRouter {
    //used for called by native
    public static final int NATIVE_REQUEST = 8758;

    public static final int FLUTTER_REQUEST = 8759;
    private static HSRouter sRouterInst;
    public static HSRouter sharedInstance(){
        if(sRouterInst==null){
            sRouterInst = new HSRouter();
        }
        return sRouterInst;
    }
    Map<String,Class> routes = new HashMap<>();
    void addRoute(String pageId, Class clazz) {
        routes.put(pageId, clazz);
    }

    //从Flutter打开新Activity
    void openNativePage(String pageId, HashMap<String, Object> args) {
        if (!routes.containsKey(pageId)) {
            return;
        }
        Activity activity = mFlutterActivities.peek();
        Intent intent = new Intent(activity,routes.get(pageId));
//        intent.setData(Uri.parse(url));
//        intent.setAction(Intent.ACTION_VIEW);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("args", args);
        activity.startActivityForResult(intent, FLUTTER_REQUEST);
    }

    //从本地Activity打开Flutter页面
    void openFlutterPage(Activity activity, String pageId, HashMap<String, Object> args) {
        Intent intent = new Intent(activity, HSFlutterActivity.class);
        intent.putExtra("args", args);
        intent.putExtra("pageId", pageId);
        activity.startActivityForResult(intent, NATIVE_REQUEST);
    }

    private Stack<Activity> mFlutterActivities = new Stack<>();

    public void pushFlutterActivity(Activity activity) {
        mFlutterActivities.push(activity);
    }
    public void popFlutterActivity(Activity activity) {
        mFlutterActivities.pop();
    }
    void popFlutterActivity() {
        Activity activity = mFlutterActivities.peek();
        activity.finish();
    }
}
