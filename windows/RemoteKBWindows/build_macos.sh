
rm -rf build-macos
mkdir build-macos
cd build-macos

# compile
$HOME/Qt/5.13.0/clang_64/bin/qmake "CONFIG+=hide_symbols" ../remotekb/remotekb.pro
make

# create temp dmg
$HOME/Qt/5.13.0/clang_64/bin/macdeployqt ./RemoteKeyboard.app -dmg


# repack dmg
rm -rf dist
mkdir dist
hdiutil detach /Volumes/RemoteKeyboard
hdiutil attach RemoteKeyboard.dmg
cp -R /Volumes/RemoteKeyboard/RemoteKeyboard.app ./dist/RemoteKeyboard.app
hdiutil detach /Volumes/RemoteKeyboard

# remove 

cd dist
cp ../../pack/appdmg.json ./
cp ../../pack/background.png ./
appdmg appdmg.json ./RemoteKeyboard.dmg

cd ..
cd .. 

rm -rf dist
mkdir dist
rm dist/RemoteKeyboard.dmg
cp -f build-macos/dist/RemoteKeyboard.dmg dist/

#cp -R dist/* ../release/

echo "---------"
echo "done :)"
echo "---------"
