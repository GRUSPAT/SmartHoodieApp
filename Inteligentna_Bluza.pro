QT += quick bluetooth svg

SOURCES += \
        bledevice.cpp \
        deviceinfo.cpp \
        main.cpp

resources.files = main.qml 
resources.prefix = /$${TARGET}
RESOURCES += resources \
    resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    DialBG.svg \
    DialBackground.png \
    Info.plist \
    Info.qmake.macos.plist \
    appicon.png

HEADERS += \
    bledevice.h \
    deviceinfo.h

ICON = appicon.png
ios: QMAKE_INFO_PLIST = Info.plist
macos: QMAKE_INFO_PLIST = Info.qmake.macos.plist
