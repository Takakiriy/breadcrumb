#!/bin/bash
if echo "$0" | grep "/" | grep -E -v "bash-debug|systemd" > /dev/null; then  cd "${0%/*}"  ;fi  # cd this file folder

#// breadcrumb test and code
Tests=(  #// --test option parameters
    "TestOfExample"
    "TestOfStartAt"
    "TestOfTestResult"
    "TestOfEachBreadcrumb"
)

PositionalArgs=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--list)  Options_List="yes"; shift;;
        -t|--test)  Options_Test="$2"; shift; shift;;
        #// Start of breadcrumb options
        --start-at)     Options_StartAt="$2"; shift; shift;;
        --step)         Options_Step="yes"; shift;;
        --step-after)   Options_StepAfter="yes"; shift;;
        --parent)       Options_Parent="$2"; ParentPIDLabel=", ParentPID=${Options_Parent}"; shift; shift;;  #// Parent script PID. Not ${PPID}
        --silent-breadcrumb)  Options_SilentBreadcrumb="yes"; shift;;
        --start-at-sub-job)  Options_StartAtSubJob="$2"; shift; shift;;
        #// End of breadcrumb options
        --without-log)  Options_WithoutLog="yes"; shift;;
        --target)       Options_Target="$2"; shift; shift;;
        --) shift;  PositionalArgs+=("$@"); set --;;
        --*) echo "Unknown option $1"; exit 1;;
        *) PositionalArgs+=("$1"); shift;;
    esac
done
set -- "${PositionalArgs[@]}"  #// set $1, $2, ...
unset PositionalArgs

ThisScriptName="./breadcrumb.sh"
# ThisScriptFullPath="$( readlink -f "${0##*/}" )"
# RootBreadcrumb="${ThisScriptFullPath}"
RootBreadcrumb="${ThisScriptName}"  #// In old specification, ParentBreadcrumb instead of RootBreadcrumb.

#section: Main

function  Main() {
    if [ "${Options_List}" != "" ]; then
        echo  "${Tests[@]}" | sed "s/ /\n/g"
    elif !( TestOptionIsValid ); then
        echo  "ERROR: Not found test name \"${Options_Test}\". See Tests variable in \"${ThisScriptFullPath}\"." >&2
    else
        PushBreadcrumb  " >> Main"
        if [ "${Options_Target}" == "" ]; then  #// Main case
            PushBreadcrumb  " >> Tests"
            if ShouldRunTest "TestOfExample"; then
                TestOfExample
            fi
            if ShouldRunTest "TestOfStartAt"; then
                TestOfStartAt
            fi
            if ShouldRunTest "TestOfTestResult"; then
                TestOfTestResult
            fi
            if ShouldRunTest "TestOfEachBreadcrumb"; then
                TestOfEachBreadcrumb
            fi
            PopBreadcrumb  " >> Tests"
        else
            if [ "${Options_Target}" == "StartAtTargetA" ]; then
                StartAtTargetA
            elif [ "${Options_Target}" == "StartAtTargetB" ]; then
                StartAtTargetB
            elif [ "${Options_Target}" == "StartAtTargetC" ]; then
                StartAtTargetC
            elif [ "${Options_Target}" == "MainJobSubJob" ]; then
                MainJobSubJob
            elif [ "${Options_Target}" == "SubJob" ]; then
                SubJob
            else
                echo  "ERROR: not found --target option function. (target = ${Options_Target})" >&2
            fi
        fi
        PopBreadcrumb  " >> Main"
    fi
}

function  TestOfExample() {
    TestOfExample2
    TestOfExample3
    TestOfExample4
}

#// Test of Example1 is done in Main function.

function  TestOfExample2() {
    PushBreadcrumb  " >> TestOfExample2"  "HasStarted"  ||  return  0

    echo  "Do in TestOfExample2"
    PopBreadcrumb  " >> TestOfExample2"
}

function  TestOfExample3() {
    if PushBreadcrumb  " >> TestOfExample3"  "HasStarted"; then

        echo  "Do in TestOfExample3"
        PopBreadcrumb  " >> TestOfExample3"
    fi
}

function  TestOfExample4() {
    PushBreadcrumb  " >> TestOfExample4"  "HasStarted"  ||  return  0

    if PushBreadcrumb  " >> o1"  "HasStarted"  -o  "1" == "1"; then
        echo  "Do in TestOfExample4 a"
        PopBreadcrumb  " >> o1"
    fi

    if PushBreadcrumb  " >> o0"  "HasStarted"  -o  "1" == "0"; then
        echo  "Do in TestOfExample4 b"
        PopBreadcrumb  " >> o0"
    fi

    if PushBreadcrumb  " >> a1"  "HasStarted"  -a  "1" == "1"; then
        echo  "Do in TestOfExample4 a"
        PopBreadcrumb  " >> a1"
    fi

    if PushBreadcrumb  " >> a0"  "HasStarted"  -a  "1" == "0"; then
        echo  "Do in TestOfExample4 b"
        PopBreadcrumb  " >> a0"
    fi
    PopBreadcrumb  " >> TestOfExample4"
}

function  TestOfStartAt() {
    TestOfStartAt1
    TestOfStartAtSubProcess
    TestOfStartAtSubJob
}

function  TestOfStartAt1() {
    PushBreadcrumb  " >> TestOfStartAt1"  "HasStarted"  ||  return  0
    if PushBreadcrumb  " >> StartAtTarget2"  "HasStarted"; then

        local  startAtOption=" >> Main >> StartAtTarget2"
        EchoTestOfStartAtOption  "${startAtOption}"
        "${ThisScriptName}"  --without-log  --target "StartAtTargetA"  --start-at "${startAtOption}"  ||  Error
        PopBreadcrumb  " >> StartAtTarget2"
    fi
    if PushBreadcrumb  " >> StartAtTarget1"  "HasStarted"; then

        local  startAtOption=" >> Main >> StartAtTarget1"
        EchoTestOfStartAtOption  "${startAtOption}"
        "${ThisScriptName}"  --without-log  --target "StartAtTargetA"  --start-at "${startAtOption}"  ||  Error
        PopBreadcrumb  " >> StartAtTarget1"
    fi
    if PushBreadcrumb  " >> StartAtTarget3"  "HasStarted"; then

        local  startAtOption=" >> Main >> StartAtTarget3"
        EchoTestOfStartAtOption  "${startAtOption}"
        "${ThisScriptName}"  --without-log  --target "StartAtTargetA"  --start-at "${startAtOption}"  ||  Error
        PopBreadcrumb  " >> StartAtTarget3"
    fi
    if PushBreadcrumb  " >> NotFoundCase"  "HasStarted"; then

        local  startAtOption=" >> Main >> NotFoundCase"
        EchoTestOfStartAtOption  "${startAtOption}"
        "${ThisScriptName}"  --without-log  --target "StartAtTargetA"  --start-at "${startAtOption}"  &&  Error
        echo  "OK. It is error case test."
        PopBreadcrumb  " >> NotFoundCase"
    fi
    PopBreadcrumb  " >> TestOfStartAt1"
}

function  StartAtTargetA() {
    StartAtTarget1
    StartAtTarget2
    StartAtTarget3
}

function  StartAtTarget1() {
    PushBreadcrumb  " >> StartAtTarget1"  "HasStarted"  ||  return  0
    echo  "Do in StartAtTarget1"
    PopBreadcrumb  " >> StartAtTarget1"
}

function  StartAtTarget2() {
    PushBreadcrumb  " >> StartAtTarget2"  "HasStarted"  ||  return  0
    echo  "Do in StartAtTarget2"
    PopBreadcrumb  " >> StartAtTarget2"
}

function  StartAtTarget3() {
    PushBreadcrumb  " >> StartAtTarget3"  "HasStarted"  ||  return  0
    echo  "Do in StartAtTarget3"
    PopBreadcrumb  " >> StartAtTarget3"
}

function  TestOfStartAtSubProcess() {
    PushBreadcrumb  " >> TestOfStartAtSubProcess"  "HasStarted"  ||  return  0
    if PushBreadcrumb  " >> FirstCase"  "HasStarted"; then

        local  startAtOption=" >> Main >> StartAtTargetB2 >> Main >> StartAtTarget2"
        EchoTestOfStartAtOption  "${startAtOption}"
        "${ThisScriptName}"  --without-log  --target "StartAtTargetB"  --start-at "${startAtOption}"  ||  Error
        PopBreadcrumb  " >> FirstCase"
    fi
    if PushBreadcrumb  " >> NotFoundCase"  "HasStarted"; then

        local  startAtOption=" >> Main >> StartAtTargetB2 >> Main >> NotFoundCase"
        EchoTestOfStartAtOption  "${startAtOption}"
        "${ThisScriptName}"  --without-log  --target "StartAtTargetB"  --start-at "${startAtOption}"  &&  Error
        echo  "OK. It is error case test."
        PopBreadcrumb  " >> NotFoundCase"
    fi
    PopBreadcrumb  " >> TestOfStartAtSubProcess"
}

function  StartAtTargetB() {
    if PushBreadcrumb  " >> StartAtTargetB1"  "HasStarted"; then
        echo  "Do in StartAtTargetB1"
        PopBreadcrumb  " >> StartAtTargetB1"
    fi
    if PushBreadcrumb  " >> StartAtTargetB2"  "HasStarted"; then

        "${ThisScriptName}"  --without-log  --start-at "$( GetStartAtOption )"  $( GetStepOptions )  --target "StartAtTargetA"  ||  Error
        PopBreadcrumb  " >> StartAtTargetB2"
    fi
    if PushBreadcrumb  " >> StartAtTargetB3"  "HasStarted"; then
        echo  "Do in StartAtTargetB3"
        PopBreadcrumb  " >> StartAtTargetB3"
    fi
}

function  TestOfStartAtSubJob() {
    PushBreadcrumb  " >> TestOfStartAtSubJob"  "HasStarted"  ||  return  0

    if PushBreadcrumb  " >> StartAtSubJob"  "HasStarted"; then

        local  startAtOption=""
        local  startAtSubJobOption=" >> Main >> SubJob2"
        EchoTestOfStartAtOption  "${startAtOption}"  "${startAtSubJobOption}"
        "${ThisScriptName}"  --without-log  --start-at "${startAtOption}"  --start-at-sub-job "${startAtSubJobOption}"  --target "MainJobSubJob"  ||  Error
        PopBreadcrumb  " >> StartAtSubJob"
    fi

    if PushBreadcrumb  " >> StartAtMainJobAfterSubJob"  "HasStarted"; then

        local  startAtOption=" >> Main >> MainJob2"
        local  startAtSubJobOption=""
        EchoTestOfStartAtOption  "${startAtOption}"  "${startAtSubJobOption}"
        "${ThisScriptName}"  --without-log  --start-at "${startAtOption}"  --start-at-sub-job "${startAtSubJobOption}"  --target "MainJobSubJob"  ||  Error
        PopBreadcrumb  " >> StartAtMainJobAfterSubJob"
    fi

    if PushBreadcrumb  " >> StartAtMainAndSubJob"  "HasStarted"; then

        local  startAtOption=" >> Main >> MainJob2"
        local  startAtSubJobOption=" >> Main >> SubJob2"
        EchoTestOfStartAtOption  "${startAtOption}"  "${startAtSubJobOption}"
        "${ThisScriptName}"  --without-log  --start-at "${startAtOption}"  --start-at-sub-job "${startAtSubJobOption}"  --target "MainJobSubJob"  ||  Error
        PopBreadcrumb  " >> StartAtMainAndSubJob"
    fi

    # if PushBreadcrumb  " >> StartAt2ndSubJob"  "HasStarted"; then
    #     PopBreadcrumb  " >> StartAt2ndSubJob"
    # fi
    PopBreadcrumb  " >> TestOfStartAtSubJob"
}

function  MainJobSubJob() {
    StartSubJob
    sleep  1s
    echo  "$ sleep 1s"
    MainJob
}

function  StartSubJob() {

    local  commandLine="\"${ThisScriptName}\"  --without-log  --target \"SubJob\""
    commandLine="${commandLine}  $( GetSubJobStartAtOption )  $( GetStepOptions )"
    echo  "$ $( GetArgumentsString ${commandLine} )  &"

    bash -c  "${commandLine}"  &
        #// Go to "SubJob" function.
    ContinueAfterStartSubJob
}

function  SubJob() {
    if PushBreadcrumb  " >> SubJob1"  "HasStarted"; then
        echo  "Do in SubJob1"
        PopBreadcrumb  " >> SubJob1"
    fi
    if PushBreadcrumb  " >> SubJob2"  "HasStarted"; then
        echo  "Do in SubJob2"
        PopBreadcrumb  " >> SubJob2"
    fi
}

function  MainJob() {
    if PushBreadcrumb  " >> MainJob1"  "HasStarted"; then
        echo  "Do in MainJob1"
        PopBreadcrumb  " >> MainJob1"
    fi
    if PushBreadcrumb  " >> MainJob2"  "HasStarted"; then
        echo  "Do in MainJob2"
        PopBreadcrumb  " >> MainJob2"
    fi
}

function  TestOfTestResult() {
    PushBreadcrumb  " >> TestOfTestResult"  "HasStarted"  ||  return  0

    EchoTestResultBreadcrumb  "Pass."

    EchoTestResultBreadcrumb  "ERROR: __Message__."

    true
    EchoTestResultBreadcrumb  "$?"

    false
    EchoTestResultBreadcrumb  "$?"

    EchoEndOfTest
    PopBreadcrumb  " >> TestOfTestResult"
}

function  EchoTestOfStartAtOption() {
    local  startAtOption="$1"
    local  startAtSubJobOption="$2"
    local  options=""
    if [ "${startAtSubJobOption}" != "" ]; then
        options="${options}  --start-at-sub-job \"${startAtSubJobOption}\""
    fi

    echo  "******* Test of --start-at \"${startAtOption}\"${options}"
}

function  EchoEndOfTestMessage() {
    echo  "(EchoEndOfTestMessage) This is an example."
}

function  TestOfEachBreadcrumb() {
    EACH_BREADCRUMB="bash  ${PWD}/watch.sh"  "${ThisScriptName}"  --without-log  --target "StartAtTargetC"
}

function  StartAtTargetC() {
    if PushBreadcrumb  " >> StartAtTargetC1"  "HasStarted"; then
        echo  "Do in StartAtTargetC1"
        PopBreadcrumb  " >> StartAtTargetC1"
    fi
}

#section: Breadcrumb

function  PushBreadcrumb() {
    #//     Example1:
    #//         PushBreadcrumb  " >> First"
    #//     Example2:
    #//         if PushBreadcrumb  " >> First"  "HasStarted"; then
    #//     Example3:
    #//         PushBreadcrumb  " >> Download (libraryA, libraryB)"  "HasStarted"  ||  return  0
    #//     Example4:
    #//         if PushBreadcrumb  " >> First"  "HasStarted"  -o  "${Options_First}" != ""; then  #// See Linux test command
    #//     Example5:
    #//         if PushBreadcrumb  " >> First"  "ChildProcessWillBeStarted"; then
    #//             call_breadcrumb_supported_command
    local  breadcrumb="$1"  #// e.g. " >> First"
    local  option="${2-""}"  #// "", "HasStarted" or "ChildProcessWillBeStarted".  "${1-""}" means that "$1" default is "".
    local  additionalCondition0="${3-""}"  #// "" or condition.  e.g.) -o.  "${1-""}" means that "$1" default is "".
    shift  3  ||  true
    local  additionalCondition=( "$@" )  #// "" or condition.  e.g.) "${var}" != ""
    local  dateTime="$( date +"%Y-%m-%dT%H:%M:%S.%N%z" )"

    #// Set default values. "! -v" means that variable is not defined.
    if ! [[ -v HasStartedFlag ]]; then  HasStartedFlag=""  ;fi
    if ! [[ -v ParentBreadcrumb ]]; then  ParentBreadcrumb=""  ;fi
    if ! [[ -v RootBreadcrumb ]]; then  RootBreadcrumb=""  ;fi
    if ! [[ -v ParentPIDLabel ]]; then  ParentPIDLabel=""  ;fi
    if ! [[ -v Options_StartAtSubJob ]]; then  Options_StartAtSubJob=""  ;fi
    if ! [[ -v Options_SilentBreadcrumb ]]; then  Options_SilentBreadcrumb=""  ;fi
    if ! [[ -v SilentBreadcrumb ]]; then
        if [ "${Options_SilentBreadcrumb}" == "" ]; then
            SilentBreadcrumb="false"
        else
            SilentBreadcrumb="true"
        fi
    fi
    if [ "${HasStartedFlag}" == "" ]; then
        #// Old specification warning
        if [ "${ParentBreadcrumb}" != ""  -a  "${RootBreadcrumb}" == "" ]; then
            echo  "WARNING: In new version, set RootBreadcrumb to old version ParentBreadcrumb initial value."
        fi
    fi

    ParentBreadcrumb="${ParentBreadcrumb}${breadcrumb}"
    CurrentBreadcrumb="${ParentBreadcrumb}"  #// This is also changed by SetBreadcrumb function

    SetStartAt

    if [ "${SilentBreadcrumb}" == "false" ]; then
        local  parentProcessOf=""
        if [ "${ParentPIDLabel}" != "" ]; then
            parentProcessOf="(parent process of)"
        fi

        echo  "#breadcrumb: ${dateTime}$( OnEachBreadcrumb ) $( GetCodePosition 1 ) (PID=$$${ParentPIDLabel}) ${parentProcessOf}${ParentProcessBreadcrumb}${CurrentBreadcrumb}"
    fi
    test  "${breadcrumb:0:4}" == " >> "  ||  Error  "ERROR: bad breadcrumb \"${breadcrumb}\" in PushBreadcrumb."
    if [ "$( echo "${breadcrumb:4}"  |  grep -E ' >> ' )" != "" ]; then
        Error  "ERROR: bad breadcrumb (2) \"${breadcrumb}\" in PushBreadcrumb."
    fi
    if [ "${StepMode}" != "" ]; then
        if [ "${StartAt}" == "" ]; then
            StepPrompt
        fi
    fi

    if [ "${option}" == "HasStarted" ] || [ "${option}" == "ChildProcessWillBeStarted" ]; then
        if [ "${option}" == "ChildProcessWillBeStarted" ]; then
            InChildProcess="yes"
        fi
        HasStarted
        local  exitCode=$?
        if [ "${additionalCondition0}" == "" ]; then
            if [ "${exitCode}" == 0 ]; then
                return  0  #// true
            fi
        else
            test  "${additionalCondition[@]}"
            local  additionalResult=$?
            if [ "${additionalCondition0}" == "-o" ]; then
                if [ "${exitCode}" == 0 ] || [ "${additionalResult}" == 0 ]; then
                    return  0  #// true
                fi
            elif [ "${additionalCondition0}" == "-a" ]; then
                if [ "${exitCode}" == 0 ] && [ "${additionalResult}" == 0 ]; then
                    return  0  #// true
                fi
            fi
        fi
        PopBreadcrumb  "${breadcrumb}"
        return  1  #// false
    else
        test  "${option}" == ""  ||  Error  "If ${option} is PushBreadcrumb additionalCondition, specify HasStarted parameter."
        return
    fi
}

function  PopBreadcrumb() {
    local  breadcrumb="$1"  #// e.g. " >> First"
    local  dateTime="$( date +"%Y-%m-%dT%H:%M:%S.%N%z" )"
    local  breadcrumbPattern="$(EscapeRegularExpression  "${breadcrumb}" )"
    local  tab=$'\t'

    ParentBreadcrumb="$( echo  "${ParentBreadcrumb}"  |  sed -E  "s^(.*)${breadcrumbPattern}"'.*^\1^' )"
    CurrentBreadcrumb="${ParentBreadcrumb}"  #// This is also changed by SetBreadcrumb function

    if [ "${SilentBreadcrumb}" == "false" ]; then
        local  parentProcessOf=""
        if [ "${ParentPIDLabel}" != "" ]; then
            parentProcessOf="(parent process of)"
        fi

        echo  "#breadcrumb: ${dateTime}$( OnEachBreadcrumb ) $( GetCodePosition 1 ) (PID=$$${ParentPIDLabel}) ${parentProcessOf}${ParentProcessBreadcrumb}${CurrentBreadcrumb}${breadcrumb} (end)"
    fi
    if [ "${HasStartedFlag}" == "true" ]; then
        StartAt=""
            #// Clear start at point in child process.
            #// If start at point in child process was not matched, "Not matched breadcrumb" error occurrs in child process.
    elif [ "${StartAt}" != "" ] && [ "${CurrentBreadcrumb}" == "" ]; then
        local  notFoundBreadCrumb="${StartAt%%${tab}*}"  #// left of "${tab}"
        local  startAtOption="$( echo "${Options_StartAt}"  |  sed "s/->>/>>/g" )"
        local  mainBreadcrumb="$( echo "${startAtOption}"  |  sed "s/^ >> //"  |  sed "s/ *>>.*//" )"
        local  currentStartAt="$( echo "${StartAt}"  |  sed -E "s/${tab}/ >> /" )"
        local  thisProcessStartAt="$( echo "${Options_StartAt}"  |  sed -E "s/.*->> +//"  |  sed -E "s/ *>> */ >> /" )"

        local  errorMessage="ERROR: Breadcrumb \"${notFoundBreadCrumb}\" in --start-at '${startAtOption}' is not matched with any PushBreadcrumb parameter or same name was REPEATED in parent breadcrumb."
        local  breadcrumb0
        echo  ""
        echo  "SkippedBreadcrumb:"
        for breadcrumb0 in  "${SkippedBreadcrumb[@]}" ;do     #// for elem in  ( "ABC" "DEF" "GHI" ) ;do とは書けません
            echo  "    \"${breadcrumb0}\""
        done
        echo  "ExpectedBreadcrumb:"
        echo  "    \"${StartAt}\""  |  sed  "s/${tab}.*/\"/"
        echo  ""
        if [ "${notFoundBreadCrumb}" == "${mainBreadcrumb}" ]; then
            errorMessage="${errorMessage} Not supported --start-at option, if \"${notFoundBreadCrumb}\" is main breadcrumb. Please add root breadcrumb."
        fi
        if [ "${ParentPIDLabel}" == "" ] || [ "${currentStartAt}" != "${thisProcessStartAt}" ]; then  #// If root process or first breadcrumb was matched
            Error  "${errorMessage}"
        fi
    fi
    if [ "${StepMode}" != "" ] || [ "${StepAfterMode}" != "" ]; then
        if [ "${HasStartedFlag}" == "true" ]; then
            StepPrompt
        fi
    fi
    InChildProcess=""
}

function  SetBreadcrumb() {
    local  breadcrumb="$1"  #// e.g. " >> First"
    local  dateTime="$( date +"%Y-%m-%dT%H:%M:%S.%N%z" )"

    CurrentBreadcrumb="${ParentBreadcrumb}${breadcrumb}"

    echo  "#breadcrumb: ${dateTime} $( GetCodePosition 1 ) (PID=$$${ParentPIDLabel}) ${ParentProcessBreadcrumb}${CurrentBreadcrumb}$( OnEachBreadcrumb )"
    SetStartAt
}

#// Add the following code at option parser
    #// Standard:
    #//    --start-at)   Options_StartAt="$2"; shift; shift;;
    #//    --step)       Options_Step="yes"; shift;;
    #//    --step-after) Options_StepAfter="yes"; shift;;
    #//    --parent)     Options_Parent="$2"; ParentPIDLabel=", ParentPID=${Options_Parent}"; shift; shift;;  #// Parent script PID. Not ${PPID}
    #// With Options_AllArguments:
    #//    --start-at)   Options_StartAt="$2"; Options_AllArguments+=("$2"); shift; shift;;
    #//    --step)       Options_Step="yes"; shift;;
    #//    --step-after) Options_StepAfter="yes"; shift;;
    #//    --parent)     Options_Parent="$2"; ParentPIDLabel=", ParentPID=${Options_Parent}"; Options_AllArguments+=("$2"); shift; shift;;  #// Parent script PID. Not ${PPID}

function  SetStartAt() {
    local  tab=$'\t'

    #// Initialize "HasStartedFlag"
    if [ "${HasStartedFlag}" == "" ]; then
        if [ "${Options_StartAt}" == "" ] && [ "${Options_StartAtSubJob}" != "" ]; then
            local  startAt="${Options_StartAtSubJob}"
        else
            local  startAt="${Options_StartAt}"
        fi
        if echo "${startAt}"  |  grep  "\->>" > /dev/null; then  #// "\" in "\-->" escape character. If --start-at option contains "->>".
            ParentProcessBreadcrumb="${RootBreadcrumb}$( echo "${startAt}"  |  sed -E 's/^(.*)->>.*$/\1/'  |  sed -E 's/ *$//' )"
            if [ "${ParentPIDLabel}" == "" ]; then
                ParentPIDLabel=", Parent=true"
            fi
        else
            ParentProcessBreadcrumb="${RootBreadcrumb}"
        fi
        local  currentProcessStartAt="$( echo "${startAt}"  |  sed "s/.*->> *//" )"

        if [ "${currentProcessStartAt}" == "" ]; then
            HasStartedFlag="true"
        else
            HasStartedFlag="false"
        fi
        StepMode="${Options_Step}"
        StepAfterMode="${Options_StepAfter}"
        SkippedBreadcrumb=()

        StartAt="$( echo  "${currentProcessStartAt}"  |  sed  "s/ >> /${tab}/g" )"
        if [ "${StartAt:0:1}" == "${tab}" ]; then
            StartAt="${StartAt:1}"
        fi
    fi

    #// Update "HasStartedFlag"
    if [ "${HasStartedFlag}" == "false" ] || [ "${StartAt}" != "" ]; then
        local  startAt0="${StartAt%%${tab}*}"  #// left of "${tab}"

        if echo  "${CurrentBreadcrumb}"  |  grep -F "${startAt0}" > /dev/null; then  #// "Options_StartAt" and "startAt0" are NOT regular expression.

            HasStartedFlag="true"
            local  nextStartAt="${StartAt#*${tab}*}"  #// right of "${tab}"
            if [ "${nextStartAt}" == "${StartAt}" ]; then
                StartAt=""
            else
                StartAt="${nextStartAt}"
            fi
            echo  "#breadcrumb: --start-at step in: ${startAt0}"
            SkippedBreadcrumb=()
        else
            HasStartedFlag="false"
        fi
    fi
}

function  GetStartAtOption() {
    #//     Example code 1:
    #//         child-process-command  --start-at "$( GetStartAtOption )"  $( GetStepOptions )
    #//     Example code 2:
    #//         ssh user@host  remote-process-command  --start-at "'$( GetStartAtOption )'"  $( GetStepOptions )
    #//     Continue command:  #// This behavior is restart and skiping until breadcrumb.
    #//         parent-process-command  --start-at  "__Breadcrumb__"
    local  tab=$'\t'
    local  startAt="$( echo "${StartAt}" | sed -E "s/${tab}/ >> /g" )"
    local  parent="${ParentProcessBreadcrumb}${ParentBreadcrumb} ->>"  #// ->> is parent process separator.
    local  parent="${parent: ${#RootBreadcrumb}}"  #// Cut RootBreadcrumb
    if [ "${startAt}" == "" ]; then
        echo  "${parent}"
    else
        if [ "${parent}" != "" ]; then
            parent="${parent} "
        fi

        echo "${parent}${startAt}"
    fi
    # notice:
    #     Command option
    #         --start-at $( GetStartAtOption )
    #     is not working, even if the implementation is
    #         echo  "--start-at  \"'$( echo "${StartAt}" | sed -E "s/${tab}/ >> /g" )'\""
}

function  GetStepOptions() {
    local  options=""
    if [ "${Options_Step}" != "" ]; then
        options="${options}  --step"
    fi
    if [ "${Options_StepAfter}" != "" ]; then
        options="${options}  --step-after"
    fi
    options="${options}  --parent $$"  #// PID
    echo  "${options}"
}

function  GetSubJobStartAtOption() {
    if [ "${Options_StartAtSubJob}" != "" ]; then
        echo  "--start-at '${Options_StartAtSubJob}'"
    else
        echo  ""
    fi
}

function  ContinueAfterStartSubJob() {
    if [ "${Options_StartAt}" == "" ]; then
        HasStartedFlag="true"
        StartAt=""
        echo  "#breadcrumb:  Started main job (PID=$$${ParentPIDLabel})"
    fi
}

function  HasStarted() {
    #//     Example:
    #//         if HasStarted; then
    #//             echo "Running the operation"
    #//         elif ! HasStarted; then
    #//             echo "Skipped the operation"
    #//         fi
    #//     Appendix:
    #//         In operations right after step in, "HasStarted" returns true but "${StartAt}" != "".
    test  "${HasStartedFlag}" != ""  ||  Error  "ERROR: PushBreadcrumb or SetBreadcrumb is not called yet."
    local  tab=$'\t'
    if [ "${HasStartedFlag}" == "false" ]; then
        local  currentBreadcrumb0="$( echo "${CurrentBreadcrumb}"  |  sed  "s/.* >> //" )"
        echo  "#breadcrumb: --start-at skipped: ${currentBreadcrumb0}"
        echo  "#breadcrumb: --start-at skips until: ${StartAt}"  |  sed  "s/${tab}.*//"
        SkippedBreadcrumb+=( "${currentBreadcrumb0}" )
    fi
    test  "${HasStartedFlag}" == "true"
    return  $?
}

function  EchoWithBreadcrumb() {
    #//     Example:
    #//         RootBreadcrumb="${ThisScriptFullPath}"
    #//         PushBreadcrumb  " >> Start"
    #//         EchoWithBreadcrumb  "Pass."
    #//     Output Example:
    #//         #breadcrumb: 2023-10-10T10:00:00.1234568+0900 ./example.sh:121 /home/user1/this-script.sh >> Start
    #//         Pass.  #breadcrumb: 2023-10-10T11:11:22.789456145+0900 ./example.sh:122 /home/user1/this-script.sh >> Start
    local  message="$1"
    local  dateTime="${2-""}"  #// "${1-""}" means that "$1" default is "".
    local  errorOption="${3-""}"  #// Optional. "" or "--error". See "Error" or "TestError" function. "${1-""}" means that "$1" default is "".
    if [ "${dateTime}" == "" ]; then
        local  dateTime="$( date +"%Y-%m-%dT%H:%M:%S.%N%z" )"
    fi
    if ! [[ -v HasStartedFlag ]]; then  HasStartedFlag=""  ;fi  #// Set default values. "! -v" means that variable is not defined.
    if [ "${HasStartedFlag}" == "" ]; then
        echo -e  "${message}"
        return
    fi

    if [ "${ParentProcessBreadcrumb}${CurrentBreadcrumb}" == "" ]; then
        local  breadcrumb=""
    else
        local  commandPath="${ParentProcessBreadcrumb%% >>*}"  #// left of " >>"
        local  commandAndFullBreadcrumb="${ParentProcessBreadcrumb}${CurrentBreadcrumb}"
        local  startAtOption=" >>${commandAndFullBreadcrumb#* >>*}"  #// right of " >>"
        local  parentProcessOf=""
        if [ "${ParentPIDLabel}" != "" ]; then
            parentProcessOf="(parent process of)"
        fi
        if [ "${errorOption}" == "--error" ]; then
            local  linkToRunbook=""
            if declare -f ShowLinkToRunbook > /dev/null 2>&1; then
                linkToRunbook="$( ShowLinkToRunbook )"
                if [ "${linkToRunbook}" != "" ]; then
                    linkToRunbook=$'\n'"${linkToRunbook}"$'\n'"    "
                fi
            fi
            local  breadcrumb=" ${linkToRunbook}To continue after fix, input the command like: ${parentProcessOf}${commandPath} __OtherOptions__  --start-at \"${startAtOption}\""
        else
            local  breadcrumb=" ${parentProcessOf}${ParentProcessBreadcrumb}${CurrentBreadcrumb}"
        fi
    fi
    if [ "${message}" != "" ]; then
        local  message="${message}  "
    fi

    echo -e  "${message}#breadcrumb: ${dateTime} $( GetCodePosition 1 ) (PID=$$${ParentPIDLabel})${breadcrumb}$( OnEachBreadcrumb )"
}

function  OnEachBreadcrumb() {
    #// You can edit this function.
    if ! [[ -v EACH_BREADCRUMB ]]; then  EACH_BREADCRUMB=""  ;fi  #// Set default values. "! -v" means that variable is not defined.
    if [ "${EACH_BREADCRUMB}" != "" ]; then
        ${EACH_BREADCRUMB}  #// e.g. Echo script file path to watch a file contents. EACH_BREADCRUMB="__FullPathOf__/_watch.sh"  __Command__ __Parameters__
    fi
}

function  StartBreadcrumbStepExecution() {
    StepMode="yes"
}

function  StepPrompt() {
    if [ "${StepMode}" != ""  -o  "${StepAfterMode}" != "" ]; then
        if ! [[ -v _Dbg_DEBUGGER_LEVEL ]]; then  _Dbg_DEBUGGER_LEVEL=""  ;fi  #// Set default values. "! -v" means that variable is not defined.
        if [ "${_Dbg_DEBUGGER_LEVEL}" != "" ]; then
            echo  "WARNING: --step option is disabled, because debugger will stop, when keyoboard input."
            StepMode=""
            StepAfterMode=""
        else
            local  key_=""

            while [ "${key_}" == "" ]; do
                read  -p "(N)o/(y)es/(c)ontinue: "  key_
            done

            if [ "${key_}" == "n"  -o  "${key_}" == "N" ]; then
                Error  "User exit."
            elif [ "${key_}" == "c"  -o  "${key_}" == "C" ]; then
                StepMode=""
                StepAfterMode=""
            else
                if [ "${StepAfterMode}" != "" ]; then
                    StepMode="yes"
                    StepAfterMode=""
                fi
            fi
        fi
    fi
}

function  EchoTestResultBreadcrumb() {
    #// Example:
    #//     test  "${exitCode}" == 0;  EchoTestResultBreadcrumb  #// See pass condition in __FunctionName__ function.
    #//     EchoTestResultBreadcrumb  "Pass."  #// ErrorCount variable is NOT incrementing
    #//     EchoTestResultBreadcrumb  "ERROR: __Message__."
    #//     EchoTestResultBreadcrumb  "Skip: __Message__."  #// SkipCount variable is incrementing
    #//     EchoTestResultBreadcrumb  "$?"
    #//     EchoEndOfTest  |  tee "${TestSummaryFile}"
    #//     return  $( GetFirstNonZeroValue "${PIPESTATUS[@]}" )
    local  exitCode="$?"
    local  message="${1-""}"  #// "${1-""}" means that "$1" default is "".
    local  dateTime="$( date +"%Y-%m-%dT%H:%M:%S.%N%z" )"
    if echo "${message}"  |  grep -E '^[0-9]+$' > /dev/null; then
        local  exitCode="${message}"
        local  message=""
    fi
    if [ "${message}" == "" ]; then
        if [ "${exitCode}" == "0" ]; then
            local  message="Pass."
        else
            local  message="ERROR: Exit code = ${exitCode}"
        fi
    fi
    local  fullMessage="$( EchoWithBreadcrumb  "${message}"  "${dateTime}" )"

    if echo "${message}"  |  grep 'Pass\.' > /dev/null; then
        echo  "${fullMessage}"
    elif echo "${message}"  |  grep 'Skip:' > /dev/null; then
        SkipEcho  "${fullMessage}"
    else
        local  fullMessage="$( EchoWithBreadcrumb  "${message}"  "${dateTime}"  --error )"
        TestError  "${message}"  "${dateTime}"
    fi

    TestResults+=( "${fullMessage}" )
}
TestResults=( )

function  EchoEndOfTest() {
    local  message=""
    EchoWithBreadcrumb  ""
    echo  ""
    echo  "EchoEndOfTest: Test Summary ----------------------------------------------------"
    echo  "Current Git branch: $( GetCurrentGitBranch )"
    for message in "${TestResults[@]}";do
        echo  "${message}"
    done
    echo  ""
    if ! [[ -v SkipCount ]]; then  SkipCount=0  ;fi  #// Set default values. "! -v" means that variable is not defined.

    EchoWithBreadcrumb  "ErrorCount: ${ErrorCount}"
    if [ "${SkipCount}" != 0 ]; then
        EchoWithBreadcrumb  "SkipCount: ${SkipCount}"
    fi
    if [ "${ErrorCount}" == 0 ]; then
        EchoWithBreadcrumb  "Pass."
    else
        EchoEndOfTestMessage
    fi
    test  "${ErrorCount}" == 0  #// return
}

function  TestError() {
    local  errorMessage="$1"
    local  dateTime="$2"  #// optional
    if [ "${errorMessage}" == "" ]; then
        errorMessage="ERROR: a test error"
    fi
    if [ "${ErrorCountBeforeStart}" == "${NotInErrorTest}" ]; then

        EchoWithBreadcrumb  "${errorMessage}"  "${dateTime}"  --error
    fi
    LastErrorMessage="${errorMessage}"
    ErrorCount=$(( ${ErrorCount} + 1 ))
}
ErrorCount=0
LastErrorMessage=""

#section: String

function  EscapeRegularExpression() {
    echo "$1" | sed -E 's/([$^.*+?\(){}|\/[])/\\\1/g' | sed -E 's/]/\\]/g'
}

#section: Process

function  RunWithEcho() {
    echo  "$ $( GetArgumentsString  "$@" )"  >&2
    "$@"
}

function  GetArgumentsString() {
    local  arguments=""

    for argument in "$@"; do
        if [ "${argument:0:1}" == "-" ]; then
            arguments="${arguments} ${argument}"
        elif [ "${argument}" == ""  -o  "${argument}" == "&&"  -o  "${argument}" == "||" ]; then
            arguments="${arguments} \"${argument}\""
        elif [ "$( echo "${argument}" | sed -E 's- |\.|/--' )" != "${argument}" ]; then  #// has space, period or slash
            arguments="${arguments} \"${argument}\""
        else
            arguments="${arguments} ${argument}"
        fi
    done

    echo  "${arguments:1}"
}

#section: Test

function  ShouldRunTest() {
    local  thisTest="$1"
    if [ "${Options_Test}" == "" ]; then
        true
    else
        test  "${thisTest}" == "${Options_Test}"
    fi
}

function  TestOptionIsValid() {
    local  testName

    if [ "${Options_Test}" == "" ]; then
        true
    else
        for testName in "${Tests[@]}"; do
            if [ "${Options_Test}" == "${testName}" ]; then
                true
                return
            fi
        done
        false
    fi
}

#section: Debug

function  ShowLinkToRunbook() {
    if echo "${CurrentBreadcrumb}" | grep " >> AnsiblePlaybook" > /dev/null; then
        echo  "    To log in Ansible control host and fix the problem, #search: ansible command  #ref: ~/project/README.yaml"
        echo  "        e.g.) code --remote ssh-remote+vm-local-${hostNumber}  home/user1/ansible"
        echo  "    To log in Ansible target host, #search: ansible target  #ref: ~/project/README.yaml"
    fi
}

# pp
#     Debug print
# Example:
#     pp "$config"
#     pp "$config" config
#     pp "$array" array  ${#array[@]}  "${array[@]}"
#     pp "123"
#     $( pp "$config" >&2 )
function  pp() {
    local  value="$1"
    local  variableName="$2"
    if [ "${variableName}" != "" ]; then  variableName=" ${variableName} "  ;fi  #// Add spaces
    local  oldIFS="$IFS"
    IFS=$'\n'
    local  valueLines=( ${value} )
    IFS="$oldIFS"

    local  type=""
    if [ "${variableName}" != "" ]; then
        if [[ "$(declare -p ${variableName} 2>&1 )" =~ "declare -a" ]]; then
            local  type="array"
        fi
    fi
    if [ "${type}" == "" ]; then
        if [ "${#valueLines[@]}" == 1  -o  "${#valueLines[@]}" == 0 ]; then
            local  type="oneLine"
        else
            local  type="multiLine"
        fi
    fi

    if [[ "${type}" == "oneLine" ]]; then
        echo  "@@@${variableName}= \"${value}\" ---------------------------"  >&2
    elif [[ "${type}" == "multiLine" ]]; then
        echo  "@@@${variableName}---------------------------"  >&2
        echo  "\"${value}\"" >&2
    elif [[ "${type}" == "array" ]]; then
        echo  "@@@${variableName}---------------------------"  >&2
        local  count="$3"
        if [ "${count}" == "" ]; then
            echo  "[0]: \"$4\""  >&2
            echo  "[1]: ERROR: pp parameter is too few"  >&2
        else
            local  i=""
            for (( i = 0; i < ${count}; i += 1 ));do
                echo  "[${i}]: \"$4\""  >&2
                shift
            done
        fi
    else
        echo  "@@@${variableName}? ---------------------------"  >&2
    fi
}

function  Error() {
    local  errorMessage="$1"
    local  exitCode="$2"
    if [ "${errorMessage}" == "" ]; then
        errorMessage="ERROR"
    fi
    if [ "${exitCode}" == "" ]; then  exitCode=2  ;fi

    EchoWithBreadcrumb  "${errorMessage}"  ""  --error  >&2
    exit  "${exitCode}"
}

if [ "${Options_WithoutLog}" != "" ]; then

    Main
else
    Main  2>&1  |  tee  "_output.txt"
    sed -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{9}\+[0-9]{4}/0000-00-00T00:00:00.000000000+0000/'  -i "_output.txt"
    sed -E 's/\(PID=[0-9]+\)/(PID=1111)/'  -i "_output.txt"
    sed -E 's/\(PID=[0-9]+\, ParentPID=[0-9]+\)/(PID=2222, ParentPID=1111)/'  -i "_output.txt"
    sed -E 's/--parent [0-9]+/--parent 1111/'  -i "_output.txt"

    if diff  "_output.txt"  "log"  >  /dev/null; then
        rm  "_output.txt"
        echo  "Pass."
    else
        echo  "ERROR. Output is not same as expected log. Please input the command: diff \"_output.txt\"  \"log\""
    fi
fi
