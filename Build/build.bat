@echo off
pushd ..

REM The begin, build and end steps need to be launched from the same folder
set MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
%MSBUILD% "Src\ConsoleApp1\ConsoleApp1.sln" -t:Rebuild -p:Configuration=Release -m -nr:False -restore

popd