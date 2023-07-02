import minimist from "minimist";
import path from "path";
import { findLuaExecutable } from "./helpers";
import { spawn } from "child_process";

const { luaCommand } = minimist(process.argv.slice(2));

const getLestLuaPath = () => path.join(__dirname, "lua", "lest.lua");

findLuaExecutable(luaCommand).then((executablePath) => {
	const scriptPath = getLestLuaPath();

	const lestProcess = spawn(executablePath, [scriptPath, ...process.argv.slice(2)]);

	lestProcess.stdout.on("data", (data: Buffer) => {
		process.stdout.write(data);
	});

	lestProcess.stderr.on("data", (data: Buffer) => {
		process.stderr.write(data);
	});

	lestProcess.on("error", (error) => {
		console.error(`Failed to run command:\n${error.message}`);
	});
});
