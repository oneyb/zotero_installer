#!/bin/bash
#
# Zotero installer
# Copyright 2011-2018 Sebastiaan Mathot
# <http://www.cogsci.nl/>
#
# This file is part of qnotero.
#
# qnotero is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# qnotero is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with qnotero.  If not, see <http://www.gnu.org/licenses/>.

VERSION="5.0.70"
if [ `uname -m` == "x86_64" ]; then
	ARCH="x86_64"
  VERSION_SHA256_HASH=7cb871894f1de168c0e486d2d48fc8524d23453198a2b834c23d958abd63443d
else
	ARCH="i686"
  VERSION_SHA256_HASH=24f66641bc0bebc9e7e1414bdb03050e6fde7d6939307b17afc3d1f349d5646d
fi
TMP="/tmp/zotero.tar.bz2"
DEST_FOLDER=zotero
EXEC=zotero

echo ">>> This script will download and install Zotero standalone on your system."
echo ">>> Do you want to continue?"
echo ">>> y/n (default=y)"
read INPUT
if [ "$INPUT" = "n" ]; then
	echo ">>> Aborting installation"
	exit 0
fi

echo ">>> Do you want to install Zotero globally (g) or locally (l)."
echo ">>> Root access is required for a global installation."
echo ">>> g/l (default=l)"
read INPUT
if [ "$INPUT" != "g" ]; then
	echo ">>> Installing locally"
	DEST="$HOME"
	MENU_PATH="$HOME/.local/share/applications/zotero.desktop"
	MENU_DIR="$HOME/.local/share/applications"
else
	echo ">>> Installing globally"
	DEST="/opt"
	MENU_PATH="/usr/share/applications/zotero.desktop"
	MENU_DIR="/usr/share/applications"
fi


echo ">>> Please input the version of Zotero."
echo ">>> (default=$VERSION)"
read INPUT
if [ "$INPUT" != "" ]; then
	VERSION=$INPUT
fi

echo ">>> Please input your systems architecture (i686 or x86_64)."
echo ">>> (default=$ARCH)"
read INPUT
if [ "$INPUT" != "" ]; then
	ARCH=$INPUT
fi

URL="https://download.zotero.org/client/release/${VERSION}/Zotero-${VERSION}_linux-${ARCH}.tar.bz2"

echo ">>> Downloading Zotero standalone $VERSION for $ARCH"
echo ">>> URL: $URL"

[[ ! -f $TMP ]] && wget $URL -O $TMP
if [ $? -ne 0 ]; then
	echo ">>> Failed to download Zotero"
	echo ">>> Aborting installation, sorry!"
	exit 1
fi
# Check integrity

NEW_HASH=$(sha256sum $TMP | awk '{print $1}')
if [ $VERSION_SHA256_HASH != $NEW_HASH ]; then
  echo ">>> Zotero download file corrupted"
	echo ">>> Aborting installation, sorry!"
	exit 1
fi

if [ -d $DEST/$DEST_FOLDER ]; then
	echo ">>> The destination folder ($DEST/$DEST_FOLDER) exists. Do you want to remove it?"
	echo ">>> y/n (default=n)"
	read INPUT
	if [ "$INPUT" = "y" ]; then
		echo ">>> Removing old Zotero installation"
		rm -Rf $DEST/$DEST_FOLDER
		if [ $? -ne 0 ]; then
			echo ">>> Failed to remove old Zotero installation"
			echo ">>> Aborting installation, sorry!"
			exit 1
		fi
	else
		echo ">>> Aborting installation"
		exit 0
	fi
fi

echo ">>> Extracting Zotero"
echo ">>> Target folder: $DEST/$DEST_FOLDER"

tar -xpf $TMP -C $DEST
if [ $? -ne 0 ]; then
	echo ">>> Failed to extract Zotero"
	echo ">>> Aborting installation, sorry!"
	exit 1
fi

mv $DEST/Zotero_linux-$ARCH $DEST/$DEST_FOLDER
if [ $? -ne 0 ]; then
	echo ">>> Failed to move Zotero to $DEST/$DEST_FOLDER"
	echo ">>> Aborting installation, sorry!"
	exit 1
fi

if [ -f $MENU_DIR ]; then
	echo ">>> Creating $MENU_DIR"
	mkdir $MENU_DIR
fi

echo ">>> Creating menu entry"
echo "[Desktop Entry]
Name=Zotero
Comment=Open-source reference manager (standalone version)
Exec=$DEST/$DEST_FOLDER/zotero
Icon=$DEST/$DEST_FOLDER/chrome/icons/default/default48.png
Type=Application
StartupNotify=true" > $MENU_PATH
if [ $? -ne 0 ]; then
	echo ">>> Failed to create menu entry"
	echo ">>> Aborting installation, sorry!"
	exit 1
fi

echo ">>> Done!"
echo
echo ">>> Don't forget to check out Qnotero, the Zotero sidekick!"
echo ">>> URL: http://www.cogsci.nl/qnotero"
