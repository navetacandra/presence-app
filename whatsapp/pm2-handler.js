const { readFileSync } = require("fs");
const { execSync, exec } = require("child_process");
const { cwd, stdout } = require("process");
const processName = "admin";

const list = execSync("npx pm2 list", { cwd: cwd() });
let listArr = list
  .toString()
  .replace(/ /g, "")
  .replace(/(┌|─|┬|┐|├|┼|┤|└|┴|┘)/g, "")
  .replace(/\n\n/g, "\n")
  .split("\n")
  .filter((e) => e.includes("│"));
listArr.shift();

listArr = listArr.map((e) => e.split("│").filter((e) => e)[1]);

if (listArr.join("").includes(processName)) {
  execSync("npx pm2 restart " + processName);
} else {
  execSync(
    "npx pm2 start " +
      JSON.parse(readFileSync("./package.json")).main +
      " --name " +
      processName
  );
}

execSync("npx pm2 save");

const logs = exec("npx pm2 logs");
logs.stdout.pipe(stdout);
