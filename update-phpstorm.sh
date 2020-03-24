#!/bin/bash

#
# Based on https://gist.github.com/olivertappin/e5920e131db9a451c91aa6e2bc24dc40
#

INSTALL_DIR=/opt/phpstorm

if [ "$(whoami)" != "root" ]
then
    echo "Sorry, you are not root. Use sudo!"
    exit 1
fi

echo "Downloading the latest PhpStorm to /tmp"
cd /tmp
curl -Lo PhpStorm.tar.gz "https://data.services.jetbrains.com/products/download?code=PS&platform=linux"
tar -xzf /tmp/PhpStorm.tar.gz
rm /tmp/PhpStorm.tar.gz

echo "Removing old PhpStorm..."
rm -rf $INSTALL_DIR

echo "Copying new PhpStorm..."
mv /tmp/PhpStorm* $INSTALL_DIR

echo "New PhpStorm has been installed!"

echo "Download java agent, that fixes bug using hot keys on russian layout."
mkdir -p /usr/local/lib/LinuxJavaFixes && cd /usr/local/lib/LinuxJavaFixes
wget -q https://github.com/zheludkovm/LinuxJavaFixes/raw/master/build/LinuxJavaFixes-1.0.0-SNAPSHOT.jar
wget -q https://github.com/zheludkovm/LinuxJavaFixes/raw/master/build/javassist-3.12.1.GA.jar

echo "Creating .vmoptions file..."
cp $INSTALL_DIR/bin/phpstorm64.vmoptions $INSTALL_DIR/bin/phpstorm64.vmoptions.default
cat > $INSTALL_DIR/bin/phpstorm64.vmoptions <<EOL
-Xms750m
-Xmx1500m
-XX:ReservedCodeCacheSize=240m
-XX:+UseConcMarkSweepGC
-XX:SoftRefLRUPolicyMSPerMB=50
-ea
-Dsun.io.useCanonCaches=false
-Djava.net.preferIPv4Stack=true
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-Dawt.useSystemAAFontSettings=lcd
-Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine
-javaagent:/usr/local/lib/LinuxJavaFixes/LinuxJavaFixes-1.0.0-SNAPSHOT.jar
EOL

echo "Creating jetbrains-phpstorm.desktop file..."
cat > /usr/share/applications/jetbrains-phpstorm.desktop <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=PhpStorm
Icon=$INSTALL_DIR/bin/phpstorm.png
Exec="$INSTALL_DIR/bin/phpstorm.sh" %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-phpstorm
EOL

echo "Done!"
