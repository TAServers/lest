#!/usr/bin/env node

import minimist from "minimist";
import { LestProcess, LestEvent } from "../lest-process";

const { luaCommand } = minimist(process.argv.slice(2));

const lestProcess = new LestProcess(luaCommand);

lestProcess
	.addListener(LestEvent.StdOut, (data: Buffer) => {
		process.stdout.write(data);
	})
	.addListener(LestEvent.StdErr, (data: Buffer) => {
		process.stderr.write(data);
	})
	.addListener(LestEvent.Error, (error) => {
		console.error(`Failed to run command:\n${error.message}`);
	});

lestProcess
	.run(process.argv.slice(2))
	.then((success) => process.exit(success ? 0 : 1))
	.catch((error) => {
		console.error(`Unhandled error occurred:\n${error.message}`);
	});
