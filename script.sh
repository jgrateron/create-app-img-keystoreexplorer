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

#download java 11 if not exists

DIRJAVA=jdk-11.0.11+9

if [ ! -d $DIRJAVA ]; then
    wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.11_9.tar.gz
    tar xvfz OpenJDK11U-jdk_x64_linux_hotspot_11.0.11_9.tar.gz
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

if [ ! -e build/distributions/kse-5.4.4.zip ]; then
    echo "build failed"
    exit -1
fi
cp res/kse.desktop $DIRWORKAPPIMG
cp res/icons/kse.png $DIRWORKAPPIMG
cp build/distributions/kse-5.4.4.zip $DIRWORKAPPIMG

cd $DIRWORK

#download jre 11 if not exist

DIRJRE=jdk-11.0.11+9-jre
if [ ! -d $DIRJRE ]; then
    wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jre_x64_linux_hotspot_11.0.11_9.tar.gz
fi

tar xvfz OpenJDK11U-jre_x64_linux_hotspot_11.0.11_9.tar.gz

mv $DIRJRE $DIRWORKAPPIMG/jre

cd $DIRWORKAPPIMG

mkdir -p lib

unzip kse-5.4.4.zip

cp kse-5.4.4/lib/* lib

mv lib/kse-5.4.4.jar kse.jar

rm -rf kse-5.4.4
rm -f kse-5.4.4.zip

#download tool app img

cd $DIRWORK

mv AppRun $DIRWORKAPPIMG

if [ ! -e appimagetool-x86_64.AppImage ]; then
    wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod a+x appimagetool-x86_64.AppImage
fi

./appimagetool-x86_64.AppImage $DIRWORKAPPIMG

echo "end"
