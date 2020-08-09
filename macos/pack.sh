
mkdir dist
cd dist

cp ../pack/appdmg.json ./
cp ../pack/background.png ./
appdmg appdmg.json ./Remoboard.dmg

open .
