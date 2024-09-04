@echo off
echo This batch file is for GUI.
echo For CUI, call node command directly.

set NODE_PATH=%USERPROFILE%\AppData\Roaming\npm\node_modules
start "" "C:\Program Files\Git\git-bash.exe" -c "node ./build/tree-breadcrumb.js"
pause