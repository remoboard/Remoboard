#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $DIR


#ios
rm -rf $DIR/ios/remotekb/dep/bifrost
rm -rf $DIR/ios/remotekb/dep/logic
ln -s $DIR/dep/bifrost/bifrost/ $DIR/ios/remotekb/dep/
ln -s $DIR/dep/logic/ $DIR/ios/remotekb/dep/

#android
rm -rf $DIR/android/remotekb/app/src/main/cpp/dep/bifrost
rm -rf $DIR/android/remotekb/app/src/main/cpp/dep/logic
ln -s $DIR/dep/bifrost/bifrost/ $DIR/android/remotekb/app/src/main/cpp/dep/
ln -s $DIR/dep/logic/ $DIR/android/remotekb/app/src/main/cpp/dep/

#macos
rm -rf $DIR/macos/RemoteKBMac/dep/bifrost
rm -rf $DIR/macos/RemoteKBMac/dep/logic
ln -s $DIR/dep/bifrost/bifrost/ $DIR/macos/RemoteKBMac/dep/
ln -s $DIR/dep/logic/ $DIR/macos/RemoteKBMac/dep/

#windows
rm -rf $DIR/windows/RemoteKBWindows/remotekb/src/dep/bifrost
rm -rf $DIR/windows/RemoteKBWindows/remotekb/src/dep/logic
ln -s $DIR/dep/bifrost/bifrost/ $DIR/windows/RemoteKBWindows/remotekb/src/dep/
ln -s $DIR/dep/logic/ $DIR/windows/RemoteKBWindows/remotekb/src/dep/
