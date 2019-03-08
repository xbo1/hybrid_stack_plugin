package com.xbo1.hybrid_stack_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Stack;

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
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("args", args);
        mAppContext.startActivity(intent);
    }

    void openFlutterPage(Context context, String pageId, HashMap<String, Object> args) {
        Intent intent = new Intent(context, HSFlutterActivity.class);
        intent.putExtra("args", args);
        intent.putExtra("pageId", pageId);
        context.startActivity(intent);
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
