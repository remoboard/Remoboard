

REM build before run this script


cd build-release
cd release

rmdir /s /q dist
mkdir dist
copy Remoboard.exe dist\Remoboard.exe

cd dist
C:\Qt\5.13.0\msvc2017_64\bin\windeployqt.exe Remoboard.exe

cd ..
cd ..
cd ..

mkdir dist
rmdir dist\Remoboard_Windows
xcopy build-release\release\dist dist\Remoboard_Windows\ /s /e /c /y /h /r
