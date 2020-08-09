package com.everettjf.remotekb.logic;


import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Enumeration;

public class Util {
    /**
     * gps获取ip
     * @return
     */
    public static String getLocalIpAddress()
    {
        try
        {
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();)
            {
                NetworkInterface intf = en.nextElement();
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();)
                {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    if (!inetAddress.isLoopbackAddress())
                    {
                        return inetAddress.getHostAddress().toString();
                    }
                }
            }
        }
        catch (Exception ex) {

        }
        return null;
    }

    /**
     * wifi获取ip
     * @param context
     * @return
     */
    public static String getIp(Context context){
        try {
            //获取wifi服务
            WifiManager wifiManager = (WifiManager)context. getSystemService(Context.WIFI_SERVICE);
            //判断wifi是否开启
            if (!wifiManager.isWifiEnabled()) {
                wifiManager.setWifiEnabled(true);
            }
            WifiInfo wifiInfo = wifiManager.getConnectionInfo();
            int ipAddress = wifiInfo.getIpAddress();
            String ip = intToIp(ipAddress);
            return ip;
        } catch (Exception e) {

        }
        return null;
    }

    /**
     * 格式化ip地址（192.168.11.1）
     * @param i
     * @return
     */
    private static String intToIp(int i) {

        return (i & 0xFF ) + "." +
                ((i >> 8 ) & 0xFF) + "." +
                ((i >> 16 ) & 0xFF) + "." +
                ( i >> 24 & 0xFF) ;
    }
    /**
     *  3G/4g网络IP
     */
    public static String getIpAddress() {
        try {
            for (Enumeration<NetworkInterface> en = NetworkInterface
                    .getNetworkInterfaces(); en.hasMoreElements();) {
                NetworkInterface intf = en.nextElement();
                for (Enumeration<InetAddress> enumIpAddr = intf
                        .getInetAddresses(); enumIpAddr.hasMoreElements();) {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    if (!inetAddress.isLoopbackAddress()
                            && inetAddress instanceof Inet4Address) {
                        // if (!inetAddress.isLoopbackAddress() && inetAddress
                        // instanceof Inet6Address) {
                        return inetAddress.getHostAddress().toString();
                    }
                }
            }
        } catch (Exception e) {

        }
        return null;
    }

    /**
     * 获取本机的ip地址（3中方法都包括）
     * @param context
     * @return
     */
    public static String getIpAddress(Context context){
        String ip = null;
        try {
            ip=getIp(context);
            if (ip==null){
                ip = getIpAddress();
                if (ip==null){
                    ip = getLocalIpAddress();
                }
            }
        } catch (Exception e) {

        }

        return ip;
    }


    public static String readFileContent(final String filePath) {
        File file = new File(filePath);
        if (!file.exists()) {
            return "";
        }

        try {
            BufferedReader reader = new BufferedReader(new FileReader(filePath));
            String line = reader.readLine();
            reader.close();
            return line;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return "";
    }

    public static boolean writeFileContent(final String filePath, String content) {
        try {
            FileWriter writer = new FileWriter(filePath);
            writer.write(content);
            writer.flush();
            writer.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean copyFileFromRaw(final String outputFile, final Context context, final Integer inputRawResource) {
        try {
            final OutputStream outputStream = new FileOutputStream(outputFile);

            final Resources resources = context.getResources();
            final byte[] largeBuffer = new byte[1024 * 4];
            int totalBytes = 0;
            int bytesRead = 0;

            final InputStream inputStream = resources.openRawResource(inputRawResource);
            while ((bytesRead = inputStream.read(largeBuffer)) > 0) {
                if (largeBuffer.length == bytesRead) {
                    outputStream.write(largeBuffer);
                } else {
                    final byte[] shortBuffer = new byte[bytesRead];
                    System.arraycopy(largeBuffer, 0, shortBuffer, 0, bytesRead);
                    outputStream.write(shortBuffer);
                }
                totalBytes += bytesRead;
            }
            inputStream.close();

            outputStream.flush();
            outputStream.close();
        } catch (IOException ex) {
            return false;
        }
        return true;
    }

    public static String getAppVersion(Context context) {
        String appVersion = "";
        try {
            PackageManager manager = context.getPackageManager();
            PackageInfo info = manager.getPackageInfo(context.getPackageName(), PackageManager.GET_ACTIVITIES);
            appVersion = info.versionName;
        } catch (Exception ex) {
        }
        return appVersion;
    }
}