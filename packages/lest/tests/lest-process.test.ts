import { LestEvent, LestProcess } from "../src";
import { spawn } from "child_process";
import { findLuaExecutable } from "../src/helpers";

const mockStdOutOn = jest.fn();
const mockStdErrOn = jest.fn();
const mockOn = jest.fn();

const SCRIPT_PATH = expect.stringMatching(/.+[\/\\]lua[\/\\]lest\.lua/);

jest.mock("child_process", () => ({
	spawn: jest.fn(() => ({
		stdout: { on: mockStdOutOn },
		stderr: { on: mockStdErrOn },
		on: mockOn,
	})),
}));

jest.mock("../src/helpers", () => ({
	findLuaExecutable: jest.fn(),
}));

test("spawns the Lest process with the given args", async () => {
	const luaPath = "/path/to/lua.exe";
	const args = ["--testMatch", "1234"];

	jest.mocked(findLuaExecutable).mockResolvedValue(luaPath);
	const process = new LestProcess();

	await process.run(args);

	expect(jest.mocked(spawn)).toHaveBeenCalledWith(luaPath, [SCRIPT_PATH, ...args]);
});

test("spawns the Lest process with the given luaCommand", async () => {
	jest.mocked(findLuaExecutable).mockImplementation((cmd = "") => Promise.resolve(cmd));
	const luaCommand = "/path/to/lua.exe";

	const process = new LestProcess(luaCommand);

	await process.run();

	expect(jest.mocked(spawn)).toHaveBeenCalledWith(luaCommand, [SCRIPT_PATH]);
});

interface ListenerTestCase {
	event: keyof typeof LestEvent;
	onMock: jest.Mock;
	args: any[];
	expected: any[];
}

const listenerTestCases: ListenerTestCase[] = [
	{
		event: "StdOut",
		onMock: mockStdOutOn,
		args: [Buffer.from("blah")],
		expected: [Buffer.from("blah")],
	},
	{
		event: "StdErr",
		onMock: mockStdErrOn,
		args: [Buffer.from("blah")],
		expected: [Buffer.from("blah")],
	},
	{
		event: "Error",
		onMock: mockOn,
		args: [new Error("blah")],
		expected: [new Error("blah")],
	},
];

describe.each(listenerTestCases)("event: $event", ({ event, onMock, args, expected }) => {
	test("calls listeners", async () => {
		onMock.mockImplementation((_, callback) => callback(...args));
		const listener1 = jest.fn();
		const listener2 = jest.fn();

		const process = new LestProcess();

		process.addListener(LestEvent[event], listener1);
		process.addListener(LestEvent[event], listener2);
		await process.run();

		expect(listener1).toHaveBeenCalledWith(...expected);
		expect(listener2).toHaveBeenCalledWith(...expected);
	});

	test("doesn't call listeners that have been removed", async () => {
		onMock.mockImplementation((_, callback) => callback(...args));
		const listener = jest.fn();

		const process = new LestProcess();

		process.addListener(LestEvent.StdOut, listener);
		process.removeListener(LestEvent.StdOut, listener);
		await process.run();

		expect(listener).not.toHaveBeenCalled();
	});
});
