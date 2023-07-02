import { lookpath } from "lookpath";
import { when } from "jest-when";
import { findLuaExecutable } from "../../src/helpers";
import luaExecutableNames from "../../src/helpers/lua-executable-names.json";

jest.mock("lookpath");

afterEach(() => {
	jest.resetAllMocks();
});

test("checks all lua executable names in order", async () => {
	jest.mocked(lookpath).mockResolvedValue("blah");

	await findLuaExecutable();

	expect(lookpath).toHaveBeenNthCalledWith(1, luaExecutableNames[0]);
	expect(lookpath).toHaveBeenNthCalledWith(2, luaExecutableNames[1]);
});

test("returns the first found path", async () => {
	const mockLookpath = jest.mocked(lookpath);

	mockLookpath.mockResolvedValueOnce(undefined);
	mockLookpath.mockResolvedValueOnce("first");
	mockLookpath.mockResolvedValueOnce("second");

	await expect(findLuaExecutable()).resolves.toBe("first");
});

test("throws an error if no path could be found", async () => {
	jest.mocked(lookpath).mockResolvedValue(undefined);

	await expect(findLuaExecutable()).rejects.toThrow(
		"Failed to detect Lua executable automatically. Use --luaCommand to manually specify an executable."
	);
});

describe("with --luaCommand", () => {
	test("returns the resolved path if found", async () => {
		when(lookpath).calledWith("lua1.2.3").mockResolvedValue("path/to/lua.exe");

		await expect(findLuaExecutable("lua1.2.3")).resolves.toBe("path/to/lua.exe");
	});

	test("throws an error if the given command could not be resolved", async () => {
		when(lookpath).calledWith("lua1.2.3").mockResolvedValue(undefined);

		await expect(findLuaExecutable("lua1.2.3")).rejects.toThrow(
			"Could not find Lua executable given by --luaCommand."
		);
	});
});
