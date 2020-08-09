package com.everettjf.remotekb;


import android.app.Activity;

import java.util.Stack;

public class ActivityManager {
    private static final Stack<Activity> sActivityStack = new Stack<>();
    private static ActivityManager sActivityManager;

    private ActivityManager() {
    }

    public Stack<Activity> getActivityStack() {
        return sActivityStack;
    }

    /**
     * 单一实例
     */
    public static ActivityManager getInstance() {
        if (sActivityManager == null) {
            synchronized (ActivityManager.class) {
                sActivityManager = new ActivityManager();
            }
        }
        return sActivityManager;
    }

    /**
     * 添加Activity到堆栈
     */
    public void addActivity(Activity activity) {
        sActivityStack.add(activity);
    }

    /**
     * 删除堆栈中的Activity
     */
    public void removeActivity(Activity activity) {
        if (sActivityStack.isEmpty()) {
            return;
        }
        sActivityStack.remove(activity);
    }

    /**
     * 获取当前Activity（堆栈中最后一个压入的）
     */
    public Activity currentActivity() {

        Activity activity = sActivityStack.lastElement();
        return activity;
    }

    /**
     * 结束当前Activity（堆栈中最后一个压入的）
     */
    public void finishActivity() {
        Activity activity = sActivityStack.lastElement();
        finishActivity(activity);
    }

    /**
     * 结束指定的Activity
     */
    public void finishActivity(Activity activity) {
        if (activity != null) {
            sActivityStack.remove(activity);
            activity.finish();
        }
    }

    /**
     * 结束指定类名的Activity
     */
    public void finishActivity(Class<?> cls) {
        for (Activity activity : sActivityStack) {
            if (activity.getClass().equals(cls)) {
                finishActivity(activity);
                return;
            }
        }

    }

    //获取指定类名的Activity
    public Activity getActivity(Class<?> cls) {
        for (Activity activity : sActivityStack) {
            if (activity.getClass().equals(cls)) {
                return activity;
            }
        }
        return null;
    }

    /**
     * 结束所有Activity
     */
    public void finishAllActivity() {
        for (int i = 0, size = sActivityStack.size(); i < size; i++) {
            if (null != sActivityStack.get(i)) {
                sActivityStack.get(i).finish();
            }
        }
        sActivityStack.clear();
    }

    public void finishAllOtherActivity(Activity activity) {
        for (int i = 0, size = sActivityStack.size(); i < size; i++) {
            if (null != sActivityStack.get(i) && sActivityStack.get(i) != activity) {
                sActivityStack.get(i).finish();
            }
        }
        sActivityStack.clear();
    }

    public void recreateAllOtherActivity(Activity activity) {
        for (int i = 0, size = sActivityStack.size(); i < size; i++) {
            if (null != sActivityStack.get(i) && sActivityStack.get(i) != activity) {
                sActivityStack.get(i).recreate();
            }
        }
    }

    /**
     * 退出应用程序
     */
    public void AppExit() {
        try {
            finishAllActivity();
            System.exit(0);
        } catch (Exception e) {
        }
    }
}

