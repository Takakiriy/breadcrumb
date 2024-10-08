import * as fs from "fs";
import * as path from "path";
import { globby } from 'globby';
import * as readline from 'readline';
try {
    var snapshots = require("./__snapshots__/main.test.ts.snap");
}
catch (e) {
}
const inputDefault = [
//    'test.json'
];
// copyFolderSync
// #keyword: copyFolderSync
// sourceFolder/1.txt => destinationFolderPath/1.txt
export async function copyFolderSync(sourceFolderPath, destinationFolderPath) {
    const currentFolderPath = process.cwd();
    const destinationFolderFullPath = getFullPath(destinationFolderPath, currentFolderPath);
    process.chdir(sourceFolderPath);
    const paths = await globby(['**/*']);
    for await (const path_ of paths) {
        const sourceFilePath = path_;
        const destinationFilePath = path.resolve(destinationFolderFullPath + '/' + path_);
        copyFileSync(sourceFilePath, destinationFilePath);
    }
    process.chdir(currentFolderPath);
}
// copyFileSync
// #keyword: copyFileSync
// This also makes the copy target folder.
export function copyFileSync(sourceFilePath, destinationFilePath) {
    const destinationFolderPath = path.dirname(destinationFilePath);
    fs.mkdirSync(destinationFolderPath, { recursive: true });
    fs.copyFileSync(sourceFilePath, destinationFilePath);
}
// getFullPath
// #keyword: JavaScript (js) library getFullPath
// If "basePath" is current directory, you can call "path.resolve"
// If the variable has full path and litteral relative path, write `${___FullPath}/relative_path}`
export function getFullPath(relativePath, basePath) {
    var fullPath = '';
    const slashRelativePath = relativePath.replace(/\\/g, '/');
    const colonSlashIndex = slashRelativePath.indexOf(':/');
    const slashFirstIndex = slashRelativePath.indexOf('/');
    const withProtocol = (colonSlashIndex + 1 === slashFirstIndex); // e.g.) C:/, http://
    if (relativePath.substr(0, 1) === '/') {
        fullPath = relativePath;
    }
    else if (relativePath.substr(0, 1) === '~') {
        fullPath = relativePath.replace('~', getHomePath());
    }
    else if (withProtocol) {
        fullPath = relativePath;
    }
    else {
        fullPath = path.join(basePath, relativePath);
    }
    return fullPath;
}
// getHomePath
// #keyword: getHomePath
export function getHomePath() {
    if (process.env.HOME) {
        return process.env.HOME;
    }
    else if (process.env.USERPROFILE) {
        return process.env.USERPROFILE;
    }
    else {
        throw new Error('unexpected');
    }
}
// StandardInputBuffer
class StandardInputBuffer {
    constructor() {
        this.inputBuffer = [];
        this.inputResolver = undefined;
    }
    delayedConstructor() {
        this.readlines = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
        this.readlines.on('line', async (line) => {
            if (this.inputResolver) {
                this.inputResolver(line); // inputResolver() is resolve() in input()
                this.inputResolver = undefined;
            }
            else {
                this.inputBuffer.push(line);
            }
        });
        this.readlines.setPrompt('');
        this.readlines.prompt();
    }
    async input(guide) {
        if (!this.readlines) {
            this.delayedConstructor();
        }
        return new Promise((resolve, reject) => {
            const nextLine = this.inputBuffer.shift();
            if (nextLine) {
                console.log(guide + nextLine);
                resolve(nextLine);
            }
            else {
                process.stdout.write(guide);
                this.inputResolver = resolve;
            }
        });
    }
    close() {
        if (this.readlines) {
            this.readlines.close();
        }
    }
}
// InputOption
class InputOption {
    constructor(inputLines) {
        this.inputLines = inputLines;
        this.nextLineIndex = 0;
        this.nextParameterIndex = 2;
    }
}
// inputOption
const inputOption = new InputOption(inputDefault);
// input
// Example: const name = await input('What is your name? ');
export async function input(guide) {
    // Input emulation
    if (inputOption.inputLines) {
        if (inputOption.nextLineIndex < inputOption.inputLines.length) {
            const value = inputOption.inputLines[inputOption.nextLineIndex];
            inputOption.nextLineIndex += 1;
            console.log(guide + value);
            return value;
        }
    }
    // Read the starting process parameters
    while (inputOption.nextParameterIndex < process.argv.length) {
        const value = process.argv[inputOption.nextParameterIndex];
        inputOption.nextParameterIndex += 1;
        if (value.substr(0, 1) !== '-') {
            console.log(guide + value);
            return value;
        }
        if (value !== '--test') {
            inputOption.nextParameterIndex += 1;
        }
    }
    // input
    return InputObject.input(guide);
}
const InputObject = new StandardInputBuffer();
export function getInputObject() {
    return InputObject;
}
// inputPath
// Example: const name = await input('What is your name? ');
export async function inputPath(guide) {
    const key = await input(guide);
    if (key.endsWith('()')) {
        return key;
    }
    else {
        return pathResolve(key);
    }
}
// inputSkip
export function inputSkip(count) {
    inputOption.nextParameterIndex += count;
}
// pathResolve
export function pathResolve(path_) {
    // '/c/home' format to current OS format
    if (path_.length >= 3) {
        if (path_[0] === '/' && path_[2] === '/') {
            path_ = path_[1] + ':' + path_.substr(2);
        }
    }
    // Replace separators to OS format
    path_ = path.resolve(path_);
    return path_;
}
// checkNotInGitWorking
export function checkNotInGitWorking() {
    var path_ = process.cwd();
    if (!path_.includes('extract_git_branches')) {
        throw new Error('This is not in project folder.');
    }
    while (path_.includes('extract_git_branches')) {
        path_ = path.dirname(path_);
    }
    while (path_ !== '/') {
        if (fs.existsSync(`${path_}/.git`)) {
            throw new Error('This test is not supported with git submodule.');
        }
        path_ = path.dirname(path_);
    }
}
// getTestWorkFolderFullPath
export function getTestWorkFolderFullPath() {
    var path_ = process.cwd();
    if (!path_.includes('extract_git_branches')) {
        throw new Error('This is not in project folder.');
    }
    while (path_.includes('extract_git_branches')) {
        path_ = path.dirname(path_);
    }
    return `${path_}/_test_of_extract_git_branches`;
}
// getSnapshot
export function getSnapshot(label) {
    if (!(label in snapshots)) {
        throw new Error(`not found snapshot label "${label}" in "__Project__/src/__snapshots__/main.test.ts.snap" file.`);
    }
    const snapshot = snapshots[label];
    return snapshot.substr(2, snapshot.length - 4).replace('\\"', '"');
}
// pp
// Debug print.
// #keyword: pp
// Example:
//    pp(var);
// Example:
//    var d = pp(var);
//    d = d;  // Set break point here and watch the variable d
// Example:
//    try {
//
//        await main();
//    } finally {
//        var d = pp('');
//        d = [];  // Set break point here and watch the variable d
//    }
export function pp(message) {
    if (typeof message === 'object') {
        message = JSON.stringify(message);
    }
    debugOut.push(message.toString());
    return debugOut;
}
export const debugOut = [];
// cc
// Through counter.
// #keyword: cc
// Example:
//   cc();
// Example:
//   var c = cc().debugOut;  // Set break point here and watch the variable c
// Example:
//   if ( cc(2).isTarget )
//   var d = pp('');  // Set break point here and watch the variable d
export function cc(targetCount = 9999999, label = '0') {
    if (!(label in gCount)) {
        gCount[label] = 0;
    }
    gCount[label] += 1;
    pp(`${label}:countThrough[${label}] = ${gCount[label]}`);
    const isTarget = (gCount[label] === targetCount);
    if (isTarget) {
        pp('    **** It is before the target! ****');
    }
    return { isTarget, debugOut };
}
const gCount = {};
//# sourceMappingURL=lib.js.map