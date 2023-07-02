import minimist from "minimist";
import { lookpath } from "lookpath";
import path from "path";
import luaExecutableNames from "./lua-executable-names.json";

const getCliArgs = () => minimist(process.argv.slice(2));

const getLestLuaPath = () => path.join(__dirname, "lest.lua");

const getLuaExecutablePath = async (): Promise<string> => {
	const { luaCommand } = getCliArgs();

	if (luaCommand) {
		const foundPath = await lookpath(luaCommand);

		if (foundPath) {
			return foundPath;
		}

		throw new Error("Could not find Lua executable given by --luaCommand.");
	}

	const paths = await Promise.all(luaExecutableNames.map((name) => lookpath(name)));
	const foundPath = paths.filter((path) => path !== undefined)[0];

	if (foundPath) {
		return foundPath;
	}

	throw new Error("Failed to detect Lua executable. Use --luaCommand to manually specify an executable.");
};

getLuaExecutablePath().then((executablePath) => {
	const scriptPath = getLestLuaPath();

	console.log(`${executablePath} ${scriptPath}`);
});
