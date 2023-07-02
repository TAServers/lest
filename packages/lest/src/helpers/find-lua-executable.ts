import { lookpath } from "lookpath";
import luaExecutableNames from "./lua-executable-names.json";

export const findLuaExecutable = async (luaCommand?: string): Promise<string> => {
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

	throw new Error(
		"Failed to detect Lua executable automatically. Use --luaCommand to manually specify an executable."
	);
};
