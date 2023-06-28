import * as afterAll from "@lest/docs/functions/afterAll.json";
import * as afterEach from "@lest/docs/functions/afterEach.json";
import * as beforeAll from "@lest/docs/functions/beforeAll.json";
import * as beforeEach from "@lest/docs/functions/beforeEach.json";
import * as describe_each from "@lest/docs/functions/describe-each.json";
import * as describe from "@lest/docs/functions/describe.json";
import * as expect from "@lest/docs/functions/expect.json";
import * as fn from "@lest/docs/functions/fn.json";
import * as test_each from "@lest/docs/functions/test-each.json";
import * as test from "@lest/docs/functions/test.json";
import * as toBe from "@lest/docs/matchers/symmetric/toBe.json";
import * as toHaveBeenCalled from "@lest/docs/matchers/symmetric/toHaveBeenCalled.json";
import * as toHaveBeenCalledTimes from "@lest/docs/matchers/symmetric/toHaveBeenCalledTimes.json";
import * as toHaveBeenCalledWith from "@lest/docs/matchers/symmetric/toHaveBeenCalledWith.json";
import * as toHaveBeenLastCalledWith from "@lest/docs/matchers/symmetric/toHaveBeenLastCalledWith.json";
import * as toHaveBeenNthCalledWith from "@lest/docs/matchers/symmetric/toHaveBeenNthCalledWith.json";
import * as toHaveLastReturnedWith from "@lest/docs/matchers/symmetric/toHaveLastReturnedWith.json";
import * as toHaveNthReturnedWith from "@lest/docs/matchers/symmetric/toHaveNthReturnedWith.json";
import * as toHaveReturned from "@lest/docs/matchers/symmetric/toHaveReturned.json";
import * as toHaveReturnedTimes from "@lest/docs/matchers/symmetric/toHaveReturnedTimes.json";
import * as toHaveReturnedWith from "@lest/docs/matchers/symmetric/toHaveReturnedWith.json";
import * as mock_result from "@lest/docs/types/mock-result.json";
import * as mock from "@lest/docs/types/mock.json";

export namespace Docs {
	export interface Function {
		name: string;
		aliases?: string[];
		description?: string | string[];
		parameters?: Property[];
		returns?: Property[];
	}

	export interface Class {
		name: string;
		description?: string | string[];
		fields?: Property[];
		methods?: Function[];
	}

	export interface Property {
		type: string;
		name?: string;
		description?: string | string[];
		optional?: boolean;
	}

	export interface FunctionProperty extends Property {
		type: "function";
		static?: boolean;
		parameters?: Property[];
		returns?: Property[];
	}

	export type ArrayItems = string | { type: "array"; items: ArrayItems };

	export interface ArrayProperty extends Property {
		type: "array";
		items: ArrayItems;
	}

	export interface TableProperty extends Property {
		type: "table";
		fields: Property[];
	}
}

export const functions: Docs.Function[] = [
	afterAll,
	afterEach,
	beforeAll,
	beforeEach,
	describe_each,
	describe,
	expect,
	test_each,
	test,
	fn,
];
export const matchers: Docs.Function[] = [
	toBe,
	toHaveBeenCalled,
	toHaveBeenCalledTimes,
	toHaveBeenCalledWith,
	toHaveBeenLastCalledWith,
	toHaveBeenNthCalledWith,
	toHaveLastReturnedWith,
	toHaveNthReturnedWith,
	toHaveReturned,
	toHaveReturnedTimes,
	toHaveReturnedWith,
];
export const classes: Docs.Class[] = [mock, mock_result];
