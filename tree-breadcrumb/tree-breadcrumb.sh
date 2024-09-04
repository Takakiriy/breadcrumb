#!/bin/bash
# chmod +x tree-breadcrumb.sh
ThisScriptPath="$0"
ThisFolder="${ThisScriptPath%/*}"  #// left of last "/" 
export  NODE_PATH=${ThisFolder}/node_modules

NodeJsVersion="16"
if [ "${WINDIR}" == "" ]; then  #// Linux
    source $HOME/.nvm/nvm.sh  #// set up nvm alias
    NvmExec="nvm exec --silent v${NodeJsVersion}  "
else  #// Windows
    NodeJSPath="${HOME}/AppData/Roaming/nvm/v${NodeJsVersion}"
    PATH="${NodeJSPath}:${PATH}"
    NvmExec=""  #// NVM for Windows does not support nvm exec command
fi

if [ ! -e "${ThisFolder}/node_modules" ]; then
    pushd  "${ThisFolder}"  > /dev/null

    ${NvmExec}npm ci  >&2
    echo  "Restored ${PWD}/node_modules."  >&2
    popd  > /dev/null
    echo  "----------------------"  >&2
fi

${NvmExec}node "${ThisFolder}/build/tree-breadcrumb.js" "$@"
