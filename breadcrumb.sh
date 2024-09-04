#!/bin/bash
if echo "$0" | grep "/" | grep -E -v "bash-debug|systemd" > /dev/null; then  cd "${0%/*}"  ;fi  # cd this file folder

PositionalArgs=()
while [[ $# -gt 0 ]]; do
    case $1 in
        #// Start of breadcrumb options
        --start-at)     Options_StartAt="$2"; shift; shift;;
        --step)         Options_Step="yes"; shift;;
        --step-after)   Options_StepAfter="yes"; shift;;
        --parent)       Options_Parent="$2"; ParentPIDLabel=", ParentPID=${Options_Parent}"; shift; shift;;  #// Parent script PID. Not ${PPID}
        --silent-breadcrumb)  Options_SilentBreadcrumb="yes"; shift;;
        #// End of breadcrumb options
        --without-log)  Options_WithoutLog="yes"; shift;;
        --target)       Options_Target="$2"; shift; shift;;
        -*) echo "Unknown option $1"; exit 1;;
        *) PositionalArgs+=("$1"); shift;;
    esac
done
set -- "${PositionalArgs[@]}"  #// set $1, $2, ...
unset PositionalArgs

ThisScriptName="./breadcrumb.sh"
# ThisScriptFullPath="$( readlink -f "${0##*/}" )"
# RootBreadcrumb="${ThisScriptFullPath}"
RootBreadcrumb="${ThisScriptName}"  #// In old specification, ParentBreadcrumb instead of RootBreadcrumb.

function  Main() {
    PushBreadcrumb  " >> Main"
    if [ "${Options_Target}" == "" ]; then  #// Main case
        PushBreadcrumb  " >> Tests"

        TestOfExample
        TestOfStartAt
        TestOfTestResult
        TestOfEachBreadcrumb
        PopBreadcrumb  " >> Tests"
    else
        if [ "${Options_Target}" == "StartAtTargetA" ]; then
            StartAtTargetA
        elif [ "${Options_Target}" == "StartAtTargetB" ]; then
            StartAtTargetB
        elif [ "${Options_Target}" == "StartAtTargetC" ]; then
            StartAtTargetC
        else
            echo  "ERROR: not found --target option function. (target = ${Options_Target})" >&2
        fi
    fi
    PopBreadcrumb  " >> Main"
}

function  TestOfExample() {
    TestOfExample2
    TestOfExample3
    TestOfExample4
}

#// Test of Example1 is donw in Main function.

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
    echo  "******* Test of --start-at \"${startAtOption}\""
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

function  PushBreadcrumb() {
    #//     Example1:
    #//         PushBreadcrumb  " >> First"
    #//     Example2:
    #//         if PushBreadcrumb  " >> First"  "HasStarted"; then
    #//     Example3:
    #//         PushBreadcrumb  " >> First"  "HasStarted"  ||  return  0
    #//     Example4:
    #//         if PushBreadcrumb  " >> First"  "HasStarted"  -o  "${Options_First}" != ""; then  #// See Linux test command
    local  breadcrumb="$1"  #// e.g. " >> First"
    local  option="$2"  #// "" or "HasStarted"
    shift  2
    local  additionalCondition=( "$@" )  #// "" or condition.  e.g.) -o  "${var}" != ""
    local  dateTime="$( date +"%Y-%m-%dT%H:%M:%S.%N%z" )"
    if [ "${HasStartedFlag}" == "" ]; then
        #// Old specification warning
        if [ "${ParentBreadcrumb}" != ""  -a  "${RootBreadcrumb}" == "" ]; then
            echo  "WARNING: In new version, set RootBreadcrumb to old version ParentBreadcrumb initial value."
        fi
    fi

    ParentBreadcrumb="${ParentBreadcrumb}${breadcrumb}"
    CurrentBreadcrumb="${ParentBreadcrumb}"  #// This is also changed by SetBreadcrumb function

    SetStartAt

    if [ "${Options_SilentBreadcrumb}" == "" ]; then
        echo  "#breadcrumb: ${dateTime}$( OnEachBreadcrumb ) (PID=$$${ParentPIDLabel}) ${ParentProcessBreadcrumb}${CurrentBreadcrumb}"
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

    if [ "${option}" == "HasStarted" ]; then
        HasStarted
        local  exitCode=$?
        if [ "${exitCode}" == 0  "${additionalCondition[@]}" ]; then
            return  0  #// true
        else
            PopBreadcrumb  "${breadcrumb}"
            return  1  #// false
        fi
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

    if [ "${Options_SilentBreadcrumb}" == "" ]; then
        echo  "#breadcrumb: ${dateTime}$( OnEachBreadcrumb ) (PID=$$${ParentPIDLabel}) ${ParentProcessBreadcrumb}${CurrentBreadcrumb}${breadcrumb} (end)"
    fi
    if [ "${HasStartedFlag}" == "true" ]; then
        StartAt=""
            #// Clear start at point in child process.
            #// If start at point in child process was not matched, "Not matched breadcrumb" error occurrs in child process.
    elif [ "${StartAt}" != ""  -a  "${CurrentBreadcrumb}" == "" ]; then
        local  notFoundBreadCrumb="${StartAt%%${tab}*}"  #// left of "${tab}"
        local  startAtOption="$( echo "${Options_StartAt}"  |  sed "s/->>/>>/g" )"

        Error  "ERROR: Breadcrumb \"${notFoundBreadCrumb}\" in --start-at \"${startAtOption}\" is not matched with any PushBreadcrumb parameter."
    fi
    if [ "${StepMode}" != ""  -o  "${StepAfterMode}" != "" ]; then
        if [ "${HasStartedFlag}" == "true" ]; then
            StepPrompt
        fi
    fi
}

function  SetBreadcrumb() {
    local  breadcrumb="$1"  #// e.g. " >> First"
    local  dateTime="$( date +"%Y-%m-%dT%H:%M:%S.%N%z" )"

    CurrentBreadcrumb="${ParentBreadcrumb}${breadcrumb}"

    echo  "#breadcrumb: ${dateTime} (PID=$$${ParentPIDLabel}) ${ParentProcessBreadcrumb}${CurrentBreadcrumb}$( OnEachBreadcrumb )"
    SetStartAt
}

function  SetStartAt() {
    local  tab=$'\t'

    #// Initialize "HasStartedFlag"
    if [ "${HasStartedFlag}" == "" ]; then
        if echo "${Options_StartAt}"  |  grep  "\->>" > /dev/null; then  #// "\" in "\-->" escape character. If --start-at option contains "->>".
            ParentProcessBreadcrumb="${RootBreadcrumb}$( echo "${Options_StartAt}"  |  sed -E 's/^(.*)->>.*$/\1/'  |  sed -E 's/ *$//' )"
        else
            ParentProcessBreadcrumb="${RootBreadcrumb}"
        fi
        local  currentProcessStartAt="$( echo "${Options_StartAt}"  |  sed "s/.*->> *//" )"
        if [ "${currentProcessStartAt}" == "" ]; then
            HasStartedFlag="true"
        else
            HasStartedFlag="false"
        fi
        StepMode="${Options_Step}"
        StepAfterMode="${Options_StepAfter}"
        StartAt="$( echo  "${currentProcessStartAt}"  |  sed  "s/ >> /${tab}/g" )"
        if [ "${StartAt:0:1}" == "${tab}" ]; then
            StartAt="${StartAt:1}"
        fi
    fi

    #// Update "HasStartedFlag"
    if [ "${HasStartedFlag}" == "false"  -o  "${StartAt}" != "" ]; then
        local  startAt0="${StartAt%%${tab}*}"

        if echo  "${CurrentBreadcrumb}"  |  grep -F "${startAt0}" > /dev/null; then  #// "Options_StartAt" and "startAt0" are NOT regular expression.

            HasStartedFlag="true"
            local  nextStartAt="${StartAt#*${tab}*}"  #// right of "${tab}"
            if [ "${nextStartAt}" == "${StartAt}" ]; then
                StartAt=""
            else
                StartAt="${nextStartAt}"
            fi
            echo  "#breadcrumb: Step in ${startAt0} (PID=$$${ParentPIDLabel})"
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
        echo  "#breadcrumb: Skipped until ${StartAt} (PID=$$${ParentPIDLabel})"  |  sed  "s/${tab}/ >> /g"
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
    #//         #breadcrumb: 2023-10-10T10:00:00.1234568+0900 /home/user1/this-script.sh >> Start
    #//         Pass.  #breadcrumb: 2023-10-10T11:11:22.789456145+0900 /home/user1/this-script.sh >> Start
    local  message="$1"
    local  dateTime="$2"  #// optional
    if [ "${dateTime}" == "" ]; then
        local  dateTime="$( date +"%Y-%m-%dT%H:%M:%S.%N%z" )"
    fi
    if [ "${ParentProcessBreadcrumb}${CurrentBreadcrumb}" == "" ]; then
        local  breadcrumb=""
    else
        local  breadcrumb=" ${ParentProcessBreadcrumb}${CurrentBreadcrumb}"
    fi
    if [ "${message}" != "" ]; then
        local  message="${message}  "
    fi

    echo  "${message}#breadcrumb: ${dateTime} (PID=$$${ParentPIDLabel})${breadcrumb}$( OnEachBreadcrumb )"
}

function  OnEachBreadcrumb() {
    #// You can edit this function.
    if [ "${EACH_BREADCRUMB}" != "" ]; then
        ${EACH_BREADCRUMB}  #// e.g. Script file path to watch a file contents
    fi
}

function  StepPrompt() {
    if [ "${StepMode}" != ""  -o  "${StepAfterMode}" != "" ]; then
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
    #//     EchoTestResultBreadcrumb  "Pass."
    #//     EchoTestResultBreadcrumb  "ERROR: __Message__."
    #//     EchoTestResultBreadcrumb  "$?"
    #//     EchoEndOfTest
    local  exitCode="$?"
    local  message="$1"
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
    else
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
    for message in "${TestResults[@]}";do
        echo  "${message}"
    done
    echo  ""

    EchoWithBreadcrumb  "ErrorCount: ${ErrorCount}"
    if [ "${ErrorCount}" == 0 ]; then
        EchoWithBreadcrumb  "Pass."
    else
        EchoEndOfTestMessage
    fi
}

function  TestError() {
    local  errorMessage="$1"
    local  dateTime="$2"  #// optional
    if [ "${errorMessage}" == "" ]; then
        errorMessage="ERROR: a test error"
    fi
    if [ "${ErrorCountBeforeStart}" == "${NotInErrorTest}" ]; then

        EchoWithBreadcrumb  "${errorMessage}"  "${dateTime}"
    fi
    LastErrorMessage="${errorMessage}"
    ErrorCount=$(( ${ErrorCount} + 1 ))
}
ErrorCount=0
LastErrorMessage=""

function  EscapeRegularExpression() {
    echo "$1" | sed -E 's/([$^.*+?\(){}|\/[])/\\\1/g' | sed -E 's/]/\\]/g'
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

    EchoWithBreadcrumb  "${errorMessage}"  >&2
    exit  "${exitCode}"
}

if [ "${Options_WithoutLog}" != "" ]; then

    Main
else
    Main  2>&1  |  tee  "_output.txt"
    sed -i -E 's/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{9}\+[0-9]{4}/0000-00-00T00:00:00.000000000+0000/'  "_output.txt"
    sed -i -E 's/\(PID=[0-9]+\)/(PID=1111)/'  "_output.txt"
    sed -i -E 's/\(PID=[0-9]+\, ParentPID=[0-9]+\)/(PID=2222, ParentPID=1111)/'  "_output.txt"

    if diff  "_output.txt"  "log"  >  /dev/null; then
        rm  "_output.txt"
        echo  "Pass."
    else
        echo  "ERROR. Output is not same as expected log. Please input the command: diff \"_output.txt\"  \"log\""
    fi
fi
