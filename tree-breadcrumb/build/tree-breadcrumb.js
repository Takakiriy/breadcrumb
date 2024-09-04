import * as fs from 'fs';
import * as readline from 'readline';
function help(inputFilePath) {
    console.log(`Help:`);
    console.log(`    $ tree-breadcrumb`);
    console.log(`        (Input log with breadcrumb tag)`);
    console.log(`        (Ctrl + D)`);
    console.log(`    $ tree-breadcrumb  __InputLogFilePath__  >  __OutputTreeFilePath__`);
    console.log(`ERROR: Not found \"${inputFilePath}\"`);
}
async function main() {
    // inputLines = ...
    if (process.argv.length <= 2) {
        console.log("Input text and push Ctrl + D.");
        var inputLines = await readStdInAll();
    }
    else {
        const inputFilePath = process.argv[2];
        if (fs.existsSync(inputFilePath)) {
            var inputLines = readFile(inputFilePath);
        }
        else {
            help(inputFilePath);
            return;
        }
    }
    LogIndent = `${TabSpace}`;
    ShallowFirstLog = true;
    LogIDs.push(0);
    CurrentPID = "";
    LineNum = 0;
    for (const nextLine of inputLines) {
        const nextLineNum = LineNum + 1;
        if (nextLineNum === 14 || nextLineNum === 15) {
            const a = "";
        }
        // Write normal log line
        if (nextLine.substring(0, 12) !== "#breadcrumb:" || nextLine.indexOf(">>") === NotFound) {
            const beginingPeriodIsNecessary = (ShallowFirstLog && nextLine[0] === " ");
            const isEmptyLine = (nextLine === "" || nextLine === "\r");
            consoleLogLogIdIfShallow();
            if (!beginingPeriodIsNecessary) { // Normal case
                if (!isEmptyLine) { // Normal case
                    console.log(`${LogIndent}${nextLine}`);
                }
                else { // if line === ""
                    console.log("");
                }
            }
            else { // If beginingPeriodIsNecessary
                console.log(`${LogIndent}.${nextLine.substring(1)}`);
            }
            LineNum = nextLineNum;
            continue;
        }
        // ...
        const match = /\(PID=([0-9]+)(,|\))/.exec(nextLine);
        const nextPID = _(() => (match[1])).elseIf(!match).then("");
        if (nextLineNum === 1) {
            CurrentPID = nextPID;
            MainPID = CurrentPID;
        }
        const breadcrumbsIndex = nextLine.indexOf(">>");
        if (breadcrumbsIndex === NotFound) {
            throw new Error(`Not found \">>\" separator in line ${nextLineNum} in input log.`);
        }
        const sep2 = 2; // ">>".length
        const currentBreadcrumbs = _(CurrentBreadcrumbsIn[nextPID]).elseIf(!(nextPID in CurrentBreadcrumbsIn)).then("");
        let nextBreadcrumbs = nextLine.substring(breadcrumbsIndex + sep2).trim();
        let nextBreadcrumbCount = countOccurrences(nextBreadcrumbs, ">>") + 1;
        let nextLogIndent = LogIndent;
        const currentBreadcrumbCount = _(() => (countOccurrences(currentBreadcrumbs, ">>") + 1)).elseIf(!currentBreadcrumbs).then(0);
        const processWasSwitched = (nextPID !== CurrentPID && nextPID !== "");
        let pidLabel = "";
        // ...
        if (processWasSwitched) { // processWasSwitched part 1
            if (ChildProcessRootLogIndent === "" && nextPID !== MainPID) { // first process switch
                ChildProcessRootLogIndent = LogIndent;
                MainProcessSwitcherBreadcrumb = CurrentBreadcrumbsIn[MainPID];
                LabelIdIn[MainPID] = 0;
                LabelIdIn[nextPID] = 0;
            }
            LabelIdIn[nextPID] += 1;
            const labelID = _(`(${LabelIdIn[nextPID]})`).elseIf(LabelIdIn[nextPID] === 1).then("");
            pidLabel = (nextPID === MainPID) ? "" : `(PID=${nextPID})${labelID} `;
            if (ChildProcessRootLogIndent !== "") {
                nextLogIndent = ChildProcessRootLogIndent;
            }
            if (nextBreadcrumbs.endsWith("(end)")) {
                LogIndent += TabSpace;
                const fieldIndent = LogIndent.substring(0, LogIndent.length - TabSpace.length * 2);
                if (nextPID === MainPID) {
                    const relativeIndex = currentBreadcrumbs.indexOf(">>", MainProcessSwitcherBreadcrumb.length);
                    const relativeBreadcrumbs = currentBreadcrumbs.substring(relativeIndex + sep2).trim();
                    var firstBreadcrumb = _(getLeftOfFirstKeyword(relativeBreadcrumbs, ">>").trim()).elseIf(!relativeBreadcrumbs.includes(">>")).then(relativeBreadcrumbs);
                }
                else {
                    var firstBreadcrumb = _(getLeftOfFirstKeyword(currentBreadcrumbs, ">>").trim()).elseIf(!currentBreadcrumbs.includes(">>")).then(currentBreadcrumbs);
                }
                // Output example:
                //     (PID=2222) MainBreadcrumb (end):
                console.log(`${fieldIndent}${pidLabel}${firstBreadcrumb} (end): |`);
            }
            if (CurrentPID === MainPID) {
                nextBreadcrumbCount = currentBreadcrumbCount + 1; // For next "if"
            }
            else {
                nextBreadcrumbCount = currentBreadcrumbCount; // For next "if"
            }
        }
        // If "nextBreadcrumbs" is deeper
        if (nextBreadcrumbCount > currentBreadcrumbCount) {
            // Variable example:
            //     nextBreadcrumbs == "Main >> Sub >> Part"
            //                              ^(currentSeparator)
            //                                     ^(nextSeparator)
            //     nextBreadcrumb == "Sub"
            const currentSeparator = nextBreadcrumbs.indexOf(">>", currentBreadcrumbs.length);
            let nextBreadcrumb = _(() => (nextBreadcrumbs.substring(currentSeparator + sep2).trim())).elseIf(currentSeparator === NotFound).then(nextBreadcrumbs);
            const nextSeparator = nextBreadcrumb.indexOf(">>");
            if (nextSeparator !== NotFound) {
                nextBreadcrumb = nextBreadcrumbs.substring(nextSeparator).trim();
            }
            const fieldIndent = LogIndent.substring(0, LogIndent.length - TabSpace.length);
            nextLogIndent = `${LogIndent}${TabSpace}`;
            ShallowFirstLog = false;
            LogIDs.push(1);
            // Output example:
            //     Bread1:
            //         1: |
            //             log
            console.log(`${fieldIndent}${pidLabel}${nextBreadcrumb}:`);
            console.log(`${fieldIndent}${TabSpace}1: |`);
            console.log(`${nextLogIndent}${nextLine}`);
        }
        // If "nextBreadcrumbs" is shallower
        // In normal case, nextBreadcrumbs has "end breadcrumb". See other code.
        else if (nextBreadcrumbCount < currentBreadcrumbCount) {
            if (nextBreadcrumbs.endsWith("(end)")) {
                nextBreadcrumbCount -= 1;
            }
            nextLogIndent = TabSpace.repeat(1 + nextBreadcrumbCount);
            // Output example:
            //     2:
            consoleLogLogIdIfShallow();
            // Output example:
            //         log
            console.log(`${nextLogIndent}${nextLine}`);
            if (nextBreadcrumbs.endsWith("(end)")) {
                nextBreadcrumbs = getLeftOfLastKeyword(nextBreadcrumbs, ">>").trim();
            }
            while (LogIDs.length > nextBreadcrumbCount + 1) {
                LogIDs.pop();
            }
            ShallowFirstLog = true;
        }
        // If "nextBreadcrumbs" is same depth
        else {
            // If end breadcrumb. Next line is shallower
            if (nextBreadcrumbs.endsWith("(end)")) {
                nextLogIndent = LogIndent;
                if (processWasSwitched) {
                    ShallowFirstLog = true;
                    nextLogIndent = nextLogIndent.substring(0, nextLogIndent.length - TabSpace.length);
                    LogIDs.pop();
                }
                // Output example:
                //     2:
                //         log (end)
                consoleLogLogIdIfShallow();
                console.log(`${nextLogIndent}${nextLine}`);
                // Set indent of log after (end) breadcrumb.
                nextLogIndent = nextLogIndent.substring(0, nextLogIndent.length - TabSpace.length);
                ShallowFirstLog = true;
                LogIDs.pop();
                nextBreadcrumbs = getLeftOfLastKeyword(nextBreadcrumbs, ">>").trim();
            }
            // If without end breadcrumb
            else {
                const parentSeparator = nextBreadcrumbs.lastIndexOf(">>");
                const nextBreadcrumb = _(() => (nextBreadcrumbs.substring(parentSeparator + sep2).trim())).elseIf(parentSeparator === NotFound).then(nextBreadcrumbs);
                const fieldIndent = LogIndent.substring(0, LogIndent.length - 2 * TabSpace.length);
                ShallowFirstLog = true;
                // Output example:
                //     Bread2:
                //         1: |
                //             log
                console.log(`${fieldIndent}${pidLabel}${nextBreadcrumb}:`);
                consoleLogLogIdIfShallow();
                console.log(`${LogIndent}${nextLine}`);
            }
        }
        if (processWasSwitched) { // processWasSwitched part 2
            if (nextBreadcrumbs.endsWith("(end)")) {
                if (nextBreadcrumbs.includes('>>')) {
                    delete CurrentBreadcrumbsIn[nextPID];
                    delete LabelIdIn[nextPID];
                    if (Object.keys(CurrentBreadcrumbsIn).length <= 1) {
                        nextLogIndent = ChildProcessRootLogIndent.substring(0, ChildProcessRootLogIndent.length - TabSpace.length);
                        ChildProcessRootLogIndent = "";
                    }
                }
                ShallowFirstLog = false;
                nextBreadcrumbs = nextBreadcrumbs.substring(0, nextBreadcrumbs.lastIndexOf(">>")).trim();
            }
        }
        // Update immutabled variables to the next line
        CurrentPID = nextPID;
        CurrentBreadcrumbsIn[nextPID] = nextBreadcrumbs;
        LogIndent = nextLogIndent;
        LineNum = nextLineNum;
    }
}
var LineNum = 0;
var TabSpace = "    ";
var LogIndent = `${TabSpace}`; // Not "log:" label "fieldIndent"
var ChildProcessRootLogIndent = "";
var MainProcessSwitcherBreadcrumb = "";
var MainPID = "";
var CurrentPID = "";
var CurrentBreadcrumbsIn = {};
var LogIDs = [];
var LabelIdIn = {};
var ShallowFirstLog = false;
const NotFound = -1;
function consoleLogLogIdIfShallow() {
    if (ShallowFirstLog) {
        const fieldIndent = LogIndent.substring(0, LogIndent.length - TabSpace.length);
        LogIDs[LogIDs.length - 1] += 1;
        ShallowFirstLog = false;
        // Output example:
        //     2:
        console.log(`${fieldIndent}${LogIDs[LogIDs.length - 1]}: |`);
    }
}
function countOccurrences(target, keywordRegExp) {
    return (target.match(new RegExp(keywordRegExp, 'gi')) || []).length;
}
function getLeftOfFirstKeyword(target, keyword) {
    return target.substring(0, target.indexOf(keyword));
}
function getLeftOfLastKeyword(target, keyword) {
    return target.substring(0, target.lastIndexOf(keyword));
}
function readFile(inputFilePath) {
    const fileContents = fs.readFileSync(inputFilePath, 'utf-8');
    const hasLastLF = (fileContents.slice(-1) === '\n');
    const lines = fileContents.split(/\r\n|\n|\r/);
    if (hasLastLF) {
        lines.pop(); // cut last empty line
    }
    return lines;
}
async function readStdInAll() {
    const reader = readline.createInterface({
        input: process.stdin,
        crlfDelay: Infinity
    });
    const lines = [];
    for await (const line of reader) {
        lines.push(line);
    }
    return lines;
}
// Readable ternary operator
//      Example:
//          const  value =_( data ).elseIf(data === "").then("empty");
//          const  value =_(()=>( object!.name )).elseIf(!object).then("");  // lazy evaluation
function _(value) {
    return new ElseIfMethodChain(value);
}
class ElseIfMethodChain {
    constructor(value) {
        this.value = value;
        this.elseIfCondition = true;
    }
    elseIf(condition) {
        this.elseIfCondition = condition;
        return this;
    }
    then(elseValue) {
        if (!this.elseIfCondition) {
            if (typeof this.value === 'function') {
                return this.value();
            }
            else {
                return this.value;
            }
        }
        else {
            if (typeof elseValue === 'function') {
                return elseValue();
            }
            else {
                return elseValue;
            }
        }
    }
}
main();
//# sourceMappingURL=tree-breadcrumb.js.map