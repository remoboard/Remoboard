#include <jni.h>
#include <string>
#include <thread>
#include <unistd.h>
#include "networkhandler.h"
#include "dep/logic/tinyformat.h"
#include <boost/algorithm/string.hpp>
#include <vector>
#include <boost/lexical_cast.hpp>
#include "utils.h"
#include "httphandler.h"

JavaVM *m_vm;
jmethodID m_onMessage;
jclass m_cls;

////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * call to java
 * @param type status|message
 * @param cmd
 * @param data
 */
void postNotification(const std::string & mode, const std::string & type, const std::string & cmd, const std::string & data) {
    JNIEnv *env = nullptr;
    if (m_vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) != JNI_OK) {
        m_vm->AttachCurrentThread(&env,0);
    }

    env->CallStaticVoidMethod(
            m_cls,
            m_onMessage,
            env->NewStringUTF(mode.c_str()),
            env->NewStringUTF(type.c_str()),
            env->NewStringUTF(cmd.c_str()),
            env->NewStringUTF(data.c_str())
    );
}
void postSocketNotification(const std::string & type, const std::string & cmd, const std::string & data) {
    postNotification("socket",type,cmd,data);
}
void postHttpNotification(const std::string & type, const std::string & cmd, const std::string & data) {
    postNotification("http",type,cmd,data);
}

////////////////////////////////////////////////////////////////////////////////////////////////////


JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    m_vm = vm;
    return JNI_VERSION_1_6;
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_everettjf_remotekb_channel_network_NetworkServerManager_getVersion(JNIEnv *env, jclass cls) {
    return env->NewStringUTF("0.2");
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_everettjf_remotekb_channel_network_NetworkServerManager_ip2code(JNIEnv *env, jclass cls, jstring ip){
    jboolean isCopy = false;
    const char *ipstr = env->GetStringUTFChars(ip, &isCopy);
    if (ipstr == NULL) {
        return NULL;
    }
    std::string ipString = ipstr;
    env->ReleaseStringUTFChars(ip, ipstr);

    std::string codestr = utils::ip2code(ipString);
    jstring code = env->NewStringUTF(codestr.c_str());
    return code;
}

extern "C" JNIEXPORT void JNICALL
Java_com_everettjf_remotekb_channel_network_NetworkServerManager_init(JNIEnv *env, jclass cls) {
    m_cls = reinterpret_cast<jclass>(env->NewGlobalRef(cls));
    m_onMessage = env->GetStaticMethodID(m_cls,"onMessage","(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
}

extern "C" JNIEXPORT void JNICALL
Java_com_everettjf_remotekb_channel_network_NetworkServerManager_socketServerStart(JNIEnv *env, jclass cls){
    rekb::NetworkHandler::instance().start();
}

extern "C" JNIEXPORT void JNICALL
Java_com_everettjf_remotekb_channel_network_NetworkServerManager_socketServerStop(JNIEnv *env, jclass cls) {
    rekb::NetworkHandler::instance().stop();
}

extern "C" JNIEXPORT void JNICALL
Java_com_everettjf_remotekb_channel_network_NetworkServerManager_httpServerStart(JNIEnv *env, jclass cls, jstring rootDir, jstring port) {
    jboolean isCopy = false;
    const char *rootDirStr = env->GetStringUTFChars(rootDir, &isCopy);
    if (rootDirStr == NULL) {
        return;
    }
    std::string rootDirString = rootDirStr;
    env->ReleaseStringUTFChars(rootDir, rootDirStr);

    const char *portStr = env->GetStringUTFChars(port, &isCopy);
    if (portStr == NULL) {
        return;
    }
    std::string portString = portStr;
    env->ReleaseStringUTFChars(port, portStr);

    rekb::HttpHandler::instance().setRootDir(rootDirString);
    rekb::HttpHandler::instance().setPort(portString);

    rekb::HttpHandler::instance().start();
}

extern "C" JNIEXPORT void JNICALL
Java_com_everettjf_remotekb_channel_network_NetworkServerManager_httpServerStop(JNIEnv *env, jclass cls) {
    rekb::HttpHandler::instance().stop();
}

