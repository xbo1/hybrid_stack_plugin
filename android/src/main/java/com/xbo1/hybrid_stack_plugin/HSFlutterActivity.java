// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.xbo1.hybrid_stack_plugin;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import io.flutter.app.FlutterActivityEvents;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterNativeView;
import io.flutter.view.FlutterView;
import com.xbo1.hybrid_stack_plugin.XFlutterActivityDelegate.ViewFactory;

import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;

/**
 * Base class for activities that use Flutter.
 */
public class HSFlutterActivity extends Activity implements FlutterView.Provider, PluginRegistry, ViewFactory {
    private static final String TAG = "HSFlutterActivity";

    @SuppressLint("StaticFieldLeak")
    private static XFlutterActivityDelegate delegate;
    private static FlutterView flutterView;
    @SuppressLint("StaticFieldLeak")
    private static FlutterNativeView nativeView;

    // These aliases ensure that the methods we forward to the delegate adhere
    // to relevant interfaces versus just existing in FlutterActivityDelegate.
    private FlutterActivityEvents eventDelegate;
    private PluginRegistry pluginRegistry;

    MethodChannel.Result channelResult;
    protected ViewGroup rootView;
    private boolean isActive;
    void initDelegate() {
        if(delegate == null) {
            delegate = new XFlutterActivityDelegate(this, this);
        }

        eventDelegate = delegate;
        pluginRegistry = delegate;
    }
    /**
     * Returns the Flutter view used by this activity; will be null before
     * {@link #onCreate(Bundle)} is called.
     */
    @Override
    public FlutterView getFlutterView() {
        return createFlutterView(this);
    }

    /**
     * Hook for subclasses to customize the creation of the
     * {@code FlutterView}.
     *
     * <p>The default implementation returns {@code null}, which will cause the
     * activity to use a newly instantiated full-screen view.</p>
     */
    @Override
    public FlutterView createFlutterView(Context context) {
        if(flutterView!=null)
            return flutterView;
        flutterView = new FlutterView(this,null,createFlutterNativeView());
        return flutterView;
    }

    /**
     * Hook for subclasses to customize the creation of the
     * {@code FlutterNativeView}.
     *
     * <p>The default implementation returns {@code null}, which will cause the
     * activity to use a newly instantiated native view object.</p>
     */
    @Override
    public FlutterNativeView createFlutterNativeView() {
        if(nativeView!=null)
            return nativeView;
        nativeView = new FlutterNativeView(this.getApplicationContext());
        return nativeView;
    }

    @Override
    public boolean retainFlutterNativeView() {
        return true;
    }

    @Override
    public final boolean hasPlugin(String key) {
        return pluginRegistry.hasPlugin(key);
    }

    @Override
    public final <T> T valuePublishedByPlugin(String pluginKey) {
        return pluginRegistry.valuePublishedByPlugin(pluginKey);
    }

    @Override
    public final Registrar registrarFor(String pluginKey) {
        return pluginRegistry.registrarFor(pluginKey);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        boolean firstLaunch = nativeView == null;
        initDelegate();
        HSRouter.sharedInstance().pushFlutterActivity(this);
        eventDelegate.onCreate(savedInstanceState);

        if (firstLaunch) {
            delegate.runBundle();
            try {
                Class<?> c = Class.forName("io.flutter.plugins.GeneratedPluginRegistrant");
                Method method = c.getMethod("registerWith",PluginRegistry.class);
                method.invoke(null,pluginRegistry);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            }
        }

        rootView = createContentView();
        setContentView(rootView);

        addFlutterView();
        openFlutter(getIntent());
    }

    private ViewGroup createContentView() {
        ViewGroup ret = new FrameLayout(this);
        ret.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        View background = new View(this);
        background.setBackground(getLaunchScreenDrawableFromActivityTheme());
        background.setClickable(true);
        ret.addView(background);
        return ret;
    }
    private Drawable getLaunchScreenDrawableFromActivityTheme() {
        TypedValue typedValue = new TypedValue();
        if (!getTheme().resolveAttribute(
                android.R.attr.windowBackground,
                typedValue,
                true)) {
            return null;
        }
        if (typedValue.resourceId == 0) {
            return null;
        }
        try {
            return getResources().getDrawable(typedValue.resourceId);
        } catch (Resources.NotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    protected void onStart() {
        super.onStart();
        eventDelegate.onStart();
        isActive = true;
    }

    @Override
    protected void onResume() {
        super.onResume();
        addFlutterView();
        if (isFlutterViewAttachedOnMe()) {
            eventDelegate.onResume();
        }
        isActive = true;
    }

    @Override
    protected void onDestroy() {
        isActive = false;
        HSRouter.sharedInstance().popFlutterActivity();
//        eventDelegate.onDestroy();
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
//        if (!eventDelegate.onBackPressed()) {
//            super.onBackPressed();
//        }
        HybridStackPlugin.getInstance().popFlutterPage(new MethodChannel.Result() {
            @Override
            public void success(Object o) {
                if (!(o instanceof Boolean) || !((Boolean) o)) {
                    HSFlutterActivity.super.onBackPressed();
                }
            }
            @Override
            public void error(String s, String s1, Object o) {
                HSFlutterActivity.super.onBackPressed();
            }
            @Override
            public void notImplemented() {
                HSFlutterActivity.super.onBackPressed();
            }
        });
    }

    @Override
    protected void onStop() {
        if(isFlutterViewAttachedOnMe()) {
            eventDelegate.onStop();
        }
        super.onStop();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (isFlutterViewAttachedOnMe()) {
            eventDelegate.onPause();
        }

        isActive = false;
    }

    @Override
    protected void onPostResume() {
        super.onPostResume();
        if (isFlutterViewAttachedOnMe()) {
            eventDelegate.onPostResume();
        }
    }

    // @Override - added in API level 23
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (isFlutterViewAttachedOnMe()) {
            eventDelegate.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        //isFlutterViewAttachedOnMe() && 不能加，会导致数据无法返回
        if (!eventDelegate.onActivityResult(requestCode, resultCode, data)) {
            super.onActivityResult(requestCode, resultCode, data);
            //从Native返回的
            if (requestCode == HSRouter.FLUTTER_REQUEST && data != null) {
                Serializable dataArgs = data.getSerializableExtra(HSRouter.EXTRA_KEY);
                HashMap<String, Object> args = new HashMap<>();
                if (dataArgs instanceof HashMap) {
                    args = (HashMap<String, Object>)dataArgs;
                }
                if (channelResult != null) {
                    channelResult.success(args);
                }
            }
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        if(isFlutterViewAttachedOnMe()) {
            eventDelegate.onNewIntent(intent);
        }
    }

    @Override
    public void onUserLeaveHint() {
        if(isFlutterViewAttachedOnMe()) {
            eventDelegate.onUserLeaveHint();
        }
    }

    @Override
    public void onTrimMemory(int level) {
        if(isFlutterViewAttachedOnMe()) {
            eventDelegate.onTrimMemory(level);
        }
    }

    @Override
    public void onLowMemory() {
        if(isFlutterViewAttachedOnMe()) {
            eventDelegate.onLowMemory();
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if(isFlutterViewAttachedOnMe()) {
            eventDelegate.onConfigurationChanged(newConfig);
        }
    }

    private boolean isFlutterViewAttachedOnMe(){
        FlutterView flutterView = getFlutterView();
        ViewGroup priorParent = (ViewGroup) flutterView.getParent();
        return rootView == priorParent;
    }

    //Flutter View Related Logic
    void addFlutterView() {
        final FlutterView flutterView = getFlutterView();
        ViewGroup priorParent = (ViewGroup) flutterView.getParent();
        if (priorParent == rootView) {
            return;
        }
        final ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT);
        final HSFlutterActivity activity = this;
        if (priorParent != null) {
            priorParent.removeView(flutterView);
            final Handler handler = new Handler();
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    //Do something after delay of 10ms
                    if (flutterView.getParent() == null && activity.isActive==true ) {
                        rootView.addView(flutterView, params);
                    }
                }
            }, 10);
        }
        else{
            rootView.addView(flutterView, params);
        }
    }

    protected void openFlutter(Intent intent){
        Bundle bundle = intent.getExtras();
        HashMap<String, Object> args = new HashMap<>();
        String pageId = "";
        if (bundle != null) {
            pageId = bundle.getString("pageId");
            Serializable intentArgs = bundle.getSerializable("args");
            if (intentArgs instanceof HashMap) {
                args = (HashMap<String, Object>)intentArgs;
            }
        }
        HybridStackPlugin.getInstance().showFlutterPage(pageId, args, new MethodChannel.Result() {
            @Override
            public void success(Object o) {

            }

            @Override
            public void error(String s, String s1, Object o) {

            }

            @Override
            public void notImplemented() {

            }
        });
    }
}
