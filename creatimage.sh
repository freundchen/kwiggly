#!/bin/zsh
# this script will create an internet-enabled disk image of Kwiggly.app
# just call it with a version number X.YY, then the disk image will be
# called Kwiggly-VX.YY.dmg

function tmplist() {
	tmpname=$(tempfile --suffix=.plist --directory=$HOME/Library/Preferences | sed "s:$HOME/Library/Preferences/\(.*\).plist:\1:")
}


if [ -z "$1" ]; then
	echo please specify version number
	echo \"e.g. creatimage.sh 0.5\" will create an image name Kwiggly-V0.5.dmg
	exit 1
fi

imgname="Kwiggly-V$1"
dirname="{$imgname}.tmpdir"

if [ -f ${imgname}.dmg ]; then
	echo $imgname.dmg already exists. Remove it\?
	read -q
	test "$REPLY" = "y" || exit 1 
	echo removing ${imgname}.dmg
	rm ${imgname}.dmg
fi

if [ -d ${dirname} ]; then
	echo Directory $dirname already exists. Remove it\?
	read -q
	test "$REPLY" = "y" || exit 1 
	echo removing ${dirname}
	rm -rf ${dirname}
fi

xcodebuild clean
xcodebuild -buildstyle Deployment 
mkdir $dirname
cp -r build/Kwiggly.app $dirname
hdiutil create -fs HFS+ -srcdir $dirname -volname "Kwiggly V$1" $imgname
hdiutil internet-enable -yes ${imgname}.dmg
rm -rf $dirname
