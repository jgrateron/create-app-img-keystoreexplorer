#!/bin/bash


mkdir -p tmp

cp AppRun tmp

cd tmp

DIRWORK=$(pwd)

DIRAPPIMG=dirappimg
DIRWORKAPPIMG=$DIRWORK/$DIRAPPIMG

#clean DIRWORKAPPIMG

rm -rf $DIRWORKAPPIMG
mkdir -p $DIRWORKAPPIMG 

KSEVERSION=kse-5.5.0
#download java 11 if not exists

DIRJAVA=jdk-11.0.13+8

if [ ! -d $DIRJAVA ]; then
    wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz
    tar xvfz OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz
fi

export JAVA_HOME=$DIRWORK/$DIRJAVA
export PATH=$DIRWORK/$DIRJAVA/bin:$PATH

#clone keystore explorer or update repository

if [ ! -d keystore-explorer ]; then
    git clone https://github.com/kaikramer/keystore-explorer.git
    cd keystore-explorer/
else
    cd keystore-explorer/
    git pull https://github.com/kaikramer/keystore-explorer.git
fi

cd kse

./gradlew clean build

if [ ! -e build/distributions/$KSEVERSION.zip ]; then
    echo "build failed"
    exit -1
fi

cp res/kse.desktop $DIRWORKAPPIMG
cp res/splash.png $DIRWORKAPPIMG
cp icons/kse.png $DIRWORKAPPIMG
cp build/distributions/$KSEVERSION.zip $DIRWORKAPPIMG

cd $DIRWORK

#download jre 11 if not exist

DIRJRE=jdk-11.0.13+8-jre
if [ ! -e OpenJDK11U-jre_x64_linux_hotspot_11.0.13_8.tar.gz ]; then
    wget https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jre_x64_linux_hotspot_11.0.13_8.tar.gz
fi

tar xvfz OpenJDK11U-jre_x64_linux_hotspot_11.0.13_8.tar.gz

mv $DIRJRE $DIRWORKAPPIMG/jre

cd $DIRWORKAPPIMG

mkdir -p lib

unzip $KSEVERSION.zip

cp $KSEVERSION/lib/* lib

mv lib/kse.jar kse.jar

rm -rf $KSEVERSION
rm -f $KSEVERSION.zip

#download tool app img

cd $DIRWORK

mv AppRun $DIRWORKAPPIMG

if [ ! -e appimagetool-x86_64.AppImage ]; then
    wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod a+x appimagetool-x86_64.AppImage
fi

./appimagetool-x86_64.AppImage $DIRWORKAPPIMG

echo "end"
