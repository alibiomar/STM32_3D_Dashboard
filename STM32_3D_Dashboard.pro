QT += quick quickcontrols2 quick3d serialport gui qml
CONFIG += c++17

SOURCES += \
    main.cpp \
    SerialReader.cpp

HEADERS += \
    SerialReader.h

RESOURCES += qml.qrc


# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
RC_ICONS = drone.ico

FORMS +=
