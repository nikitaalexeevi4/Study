TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

INCLUDEPATH += /usr/include/mpich/
SOURCES += main.cpp \
    main2.cpp
LIBS += -lmpich -lopa -lpthread -lrt
QMAKE_CXXFLAGS += -Bsymbolic-functions

