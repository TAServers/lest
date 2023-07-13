import path from "path";
import { findLuaExecutable } from "./helpers";
import { spawn } from "child_process";

export enum LestEvent {
	StdOut,
	StdErr,
	Error,
}

export type LestEventListener<Event extends LestEvent> = Event extends LestEvent.StdOut
	? (data: Buffer) => void
	: Event extends LestEvent.StdErr
	? (data: Buffer) => void
	: Event extends LestEvent.Error
	? (error: Error) => void
	: never;

export class LestProcess {
	private eventListeners: { [K in LestEvent]: Set<LestEventListener<K>> } = {
		[LestEvent.StdOut]: new Set(),
		[LestEvent.StdErr]: new Set(),
		[LestEvent.Error]: new Set(),
	};

	readonly scriptPath: string;

	constructor(readonly luaCommand?: string) {
		this.scriptPath = path.join(__dirname, "lua", "lest.lua");
	}

	async run(args: string[] = []): Promise<boolean> {
		const executablePath = await findLuaExecutable(this.luaCommand);
		const process = spawn(executablePath, [this.scriptPath, ...args]);

		process.stdout.on("data", (data: Buffer) => {
			this.triggerEvent(LestEvent.StdOut, data);
		});

		process.stderr.on("data", (data: Buffer) => {
			this.triggerEvent(LestEvent.StdErr, data);
		});

		process.on("error", (error) => {
			this.triggerEvent(LestEvent.Error, error);
		});

		return new Promise((resolve) => {
			process.on("exit", (code) => {
				resolve(code === 0);
			});
		});
	}

	private triggerEvent<Event extends LestEvent>(event: Event, ...args: Parameters<LestEventListener<Event>>) {
		this.eventListeners[event].forEach((listener: LestEventListener<Event>) =>
			listener(
				// @ts-expect-error
				...args
			)
		);
	}

	addListener<Event extends LestEvent>(event: Event, listener: LestEventListener<Event>): this {
		this.eventListeners[event].add(listener);
		return this;
	}

	removeListener<Event extends LestEvent>(event: Event, listener: LestEventListener<Event>): this {
		this.eventListeners[event].delete(listener);
		return this;
	}
}
