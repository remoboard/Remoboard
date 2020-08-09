#-------------------------------------------------
#
# Project created by QtCreator 2019-06-20T23:20:05
#
#-------------------------------------------------

QT       += core gui widgets network bluetooth

TARGET = Remoboard
TEMPLATE = app

ICON = remotekb.icns
win32 {
RC_ICONS = remotekb.ico
}

CONFIG += c++14

win32 {
DEFINES += QT_DEPRECATED_WARNINGS BOOST_DATE_TIME_NO_LIB BOOST_REGEX_NO_LIB
INCLUDEPATH += C:\Users\evere\thirdparty\boost_1_70_0 ..\..\..\dep
}

unix {
DEFINES += QT_DEPRECATED_WARNINGS
INCLUDEPATH += $$(HOME)/local/src/boost_1_70_0 /usr/local/include ../../../dep
}

ProjectHeaderFiles_h = $$files(src/*.h,true)
ProjectHeaderFiles_hpp = $$files(src/*.hpp,true)
ProjectSourceFiles_cpp = $$files(src/*.cpp,true)
ProjectSourceFiles_cc = $$files(src/*.cc,true)
ProjectSourceFiles_c = $$files(src/*.c,true)
ProjectUiFiles = $$files(src/*.ui,true)

HEADERS += $$ProjectHeaderFiles_h $$ProjectHeaderFiles_hpp $$files(../../../dep/*.hpp,true)

SOURCES += $$ProjectSourceFiles_cpp $$ProjectSourceFiles_cc $$ProjectSourceFiles_c

FORMS += $$ProjectUiFiles


# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    remotekb.qrc

TRANSLATIONS += en.ts zh.ts
