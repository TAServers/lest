import minimist from "minimist";
import path from "path";
import { findLuaExecutable } from "./helpers";

const { luaCommand } = minimist(process.argv.slice(2));

const getLestLuaPath = () => path.join(__dirname, "lest.lua");

findLuaExecutable(luaCommand).then((executablePath) => {
	const scriptPath = getLestLuaPath();

	console.log(`${executablePath} ${scriptPath}`);
});
