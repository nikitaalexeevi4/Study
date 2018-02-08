TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.cpp
#QMAKE_CXXFLAGS_RELEASE -= -O1
#QMAKE_CXXFLAGS_RELEASE -= -O2

QMAKE_CXXFLAGS_RELEASE += -g -Wa,-adhlng=test-opt.asm -masm=intel
QMAKE_CXXFLAGS_DEBUG += -Wa,-adhlng=test.asm -masm=intel
