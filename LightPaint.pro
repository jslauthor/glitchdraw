QT += quick quickcontrols2 widgets
CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS
DEFINES += "LED_WIDTH=\"96\""
DEFINES += "LED_HEIGHT=\"64\""
# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    appstate.cpp \
    main.cpp \
    qimageproxy.cpp \
    graphics/graphicsutils.cpp \
    renderthread.cpp \
    glitchtimer.cpp \
    glitchpainter.cpp \
    math/mathutils.cpp

RESOURCES += qml.qrc \
    imports/Theme/Theme.qml \
    imports/Theme/qmldir

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $$PWD/imports

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
target.path = /home/pi/Workspace/$${TARGET}/bin
INSTALLS += target

DISTFILES += \
    images/back.svg \
    images/app_bg.jpg \
    imports/Theme/qmldir \
    content/fonts/8-bit-pusab.ttf

HEADERS += \
    appstate.h \
    qimageproxy.h \
    graphics/graphicsutils.h \
    renderthread.h \
    glitchtimer.h \
    glitchpainter.h \
    math/mathutils.h

unix:!macx: LIBS += -L$$PWD/rpi-rgb-led-matrix/lib/ -lrgbmatrix

INCLUDEPATH += $$PWD/rpi-rgb-led-matrix/include
DEPENDPATH += $$PWD/rpi-rgb-led-matrix/include

unix:!macx: PRE_TARGETDEPS += $$PWD/rpi-rgb-led-matrix/lib/librgbmatrix.a
