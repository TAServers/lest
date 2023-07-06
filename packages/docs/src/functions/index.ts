import { Function } from "../interfaces";
import _afterAll from "./afterAll.json";
import _afterEach from "./afterEach.json";
import _beforeAll from "./beforeAll.json";
import _beforeEach from "./beforeEach.json";
import _describe from "./describe.json";
import _describeEach from "./describe-each.json";
import _describeSkip from "./describe-skip.json";
import _describeSkipEach from "./describe-skip-each.json";
import _expect from "./expect.json";
import _lestFn from "./fn.json";
import _test from "./test.json";
import _testEach from "./test-each.json";
import _testSkip from "./test-skip.json";
import _testSkipEach from "./test-skip-each.json";

export const afterAll: Function = _afterAll;
export const afterEach: Function = _afterEach;
export const beforeAll: Function = _beforeAll;
export const beforeEach: Function = _beforeEach;
export const describe: Function = _describe;
export const describeEach: Function = _describeEach;
export const describeSkip: Function = _describeSkip;
export const describeSkipEach: Function = _describeSkipEach;
export const expect: Function = _expect;
export const lestFn: Function = _lestFn;
export const test: Function = _test;
export const testEach: Function = _testEach;
export const testSkip: Function = _testSkip;
export const testSkipEach: Function = _testSkipEach;
