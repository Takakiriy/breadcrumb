import * as fs from 'fs';
import * as child_process from 'child_process';

const  scriptPath = '../build/tree-breadcrumb.js';

async function  main() {  // Test main
    await testStdIn();
    await testInputFile("../test/2.log.txt", readTextFile("../test/2.log.answer.yaml"));
    await testInputFile("../test/CR_LF.txt", readTextFile("../test/CR_LF.answer.yaml"));
    console.log(`Error count = ${ErrorCount}`);
}

var  ErrorCount = 0;

async function  testStdIn() {
    const  inputLog =  readFile("../test/1.log.txt");
    const  answerLog = "Input text and push Ctrl + D.\n" + readTextFile("../test/1.log.answer.yaml");

    const  process = await callChildProccess(`node ${scriptPath}`, {inputLines: inputLog});
    assertEq('answer ========================================:', answerLog,
        'stdout ========================================:', process.stdout);
}

async function  testInputFile(inputLogPath: string, answerLog: string) {

    const  process = await callChildProccess(`node ${scriptPath} "${inputLogPath}"`);
    assertEq('answer ========================================:', answerLog.replace(/\r/g, ""),
        'stdout ========================================:', process.stdout.replace(/\r/g, ""));
}

async function  callChildProccess(commandLine: string,  option?: ProcessOption): Promise<ProcessReturns> {
    return   new Promise( async (resolveFunction, rejectFunction) => {
        const  returnValue = new ProcessReturns();
        try {
            const  childProcess = child_process.exec( commandLine,

                // on close the "childProcess" (2)
                (error: child_process.ExecException | null, stdout: string, stderr: string) => {
                    returnValue.stdout = stdout;
                    returnValue.stderr = stderr;
                    resolveFunction(returnValue);
                }
            );
            if (option && childProcess.stdin) {

                if (option.inputLines) {
                    await new Promise(resolve => setTimeout(resolve, 300));
                    for (const inputLine of option.inputLines) {
                        // console.log(inputLine);
                        childProcess.stdin.write(inputLine + "\n");
                        await new Promise(resolve => setTimeout(resolve, 200));
                    }
                }
                childProcess.stdin.end();
            }

            // on close the "childProcess" (1)
            childProcess.on('close', (exitCode: number) => {
                returnValue.exitCode = exitCode;
            });
            childProcess.on('exit', (exitCode: number) => {
                returnValue.exitCode = exitCode;
            });
        } catch (e) {
            throw Error(`Error in the command line ${commandLine}`);
        }
    });
}

function  readFile(inputFilePath: string): string[] {
    const  fileContents = fs.readFileSync(inputFilePath, 'utf-8');
    const  hasLastLF = (fileContents.slice(-1) === '\n');
    const  lines: string[] = fileContents.split('\n');
    if (hasLastLF) {
        lines.pop();  // cut last empty line
    }
    return  lines
}

function  readTextFile(inputFilePath: string): string {
    return  fs.readFileSync(inputFilePath, 'utf-8').replace(/\r/g, "");
}

function  assertEq(leftLabel: string, leftContents: string, rightLabel: string, rightContents: string) {
    if (leftContents !== rightContents) {
        console.log(leftLabel);
        console.log(leftContents);
        console.log('');
        console.log(rightLabel);
        console.log(rightContents);
        console.log("ERROR: unexpected text.")
        ErrorCount += 1;
    }
}

// ProcessOption
class ProcessOption {
    inputLines?: string[];
}

// ProcessReturns
class ProcessReturns {
    exitCode: number = 0;
    stdout: string = '';
    stderr: string = '';
}

main();