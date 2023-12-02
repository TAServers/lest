---@meta
---@class lest.Mock
--- Class representing mocked functions.
--- Data relating to the mocked function such as call arguments and return values.
--- You shouldn't need to access this directly. Instead, a range of mock function matchers are provided as abstractions.
---@field mock {calls:any[][],lastCall?:any[],results:lest.MockResult[],lastResult?:lest.MockResult}
lest.Mock = {}
--- Sets the name that will be used for the mock in test output (or other prints).
---@param name string
---@return self 
function lest.Mock:mockName(name) end
--- Gets the name that will be used for the mock in test output (or other prints).
---@return string 
function lest.Mock:getMockName() end
--- Mocks the function's implementation.
--- This is the same as passing a function to `lest.fn()`, and will override any function that was passed there.
--- 
--- If you've pushed a one-time implementation with `mockImplementationOnce`, then this function will not override it.
--- This is because the persistent implementation is a fallback and stored separately.
---@param fn fun(...:any):any
---@return self 
function lest.Mock:mockImplementation(fn) end
--- Gets the mock function's implementation.
--- This is the function that's called whenever the mock is called.
--- 
--- If you've pushed a one-time implementation with `mockImplementationOnce`,
--- then this function will still return the persistent implementation.
--- This is because the persistent implementation is a fallback and stored separately.
---@return fun(...:any):any 
function lest.Mock:getMockImplementation() end
--- Mocks the function's implementation for one call.
--- The one-time implementations will be consumed in the order they were given (first in, first out).
--- 
--- `getMockImplementation` will still return the persistent implementation regardless of any one-time implementations pushed.
--- This is because the persistent implementation is a fallback and stored separately.
---@param fn fun(...:any):any
---@return self 
function lest.Mock:mockImplementationOnce(fn) end
--- Mocks the function's return value.
--- This is shorthand for `mockFn:mockImplementation(function() return ... end)`
--- 
--- See `mockImplementation`'s documentation for more information.
---@param ... any
---@return self 
function lest.Mock:mockReturnValue(...) end
--- Mocks the function's return value for a single call.
--- This is shorthand for `mockFn:mockImplementationOnce(function() return ... end)`
--- 
--- See `mockImplementationOnce`'s documentation for more information.
---@param ... any
---@return self 
function lest.Mock:mockReturnValueOnce(...) end
--- Mocks the function's implementation to return `self`.
--- This is shorthand for `mockFn:mockImplementation(function(self) return self end)`
--- 
--- This is useful for mocking functions that chain.
--- See `mockImplementation`'s documentation for more information.
---@param ... any
---@return self 
function lest.Mock:mockReturnThis(...) end
--- Clears all information stored in the `mockFn.mock` table (calls and results).
--- 
--- Note that this replaces `mockFn.mock`, not its contents.
--- Make sure you're not storing a stale reference to the old table.
--- 
--- To also reset mocked implementations and return values, call `mockFn:mockReset()`.
function lest.Mock:mockClear() end
--- Clears all information stored in the `mockFn.mock` table (calls and results) _and_ removes all mocked implementations and return values.
--- 
--- Note that this replaces `mockFn.mock`, not its contents.
--- Make sure you're not storing a stale reference to the old table.
--- 
--- To only reset the calls and results of the mock, use `mockFn:mockClear()` instead.
function lest.Mock:mockReset() end
---@class lest.MockResult
--- When a mock function returns or throws, an instance of `lest.MockResult` is added to the mock's data containing information about the result.
--- - If the mock function ran successfully when it was last called, then this will be `"return"`.
--- - If the function threw an error, then this will be `"throw"`.
---@field type "return" | "throw"
--- - If the result type is `"return"`, then this will be an array of the values returned by the mock function.
--- - If the result type is `"throw"`, then this will be the error that was thrown.
---@field value any
lest.MockResult = {}
--- Runs a function after all tests in this file have completed.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param fn fun()
---@param timeout? number
function afterAll(fn, timeout) end
--- Runs a function after each tests in this file completes.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param fn fun()
---@param timeout? number
function afterEach(fn, timeout) end
--- Runs a function before running the tests in this file.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param fn fun()
---@param timeout? number
function beforeAll(fn, timeout) end
--- Runs a function before running each test in this file.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param fn fun()
---@param timeout? number
function beforeEach(fn, timeout) end
--- Creates a block that groups related tests together.
--- 
--- If you register a function for any of the setup/teardown hooks (`afterAll`, `afterEach`, `beforeAll` and `beforeEach`)
--- inside the `describe`, they'll only exist while running tests defined in that `describe` block (or any nested `describe`s).
---@param name string
---@param fn fun()
function describe(name, fn) end
--- Data driven variant of `describe` to reduce duplication when testing the same code with different data.
--- 
--- The returned function matches regular `describe`, except the callback you pass to it will be run for each test case you define.
--- The value of each test case will be unpacked and passed to your callback.
--- 
--- This is essentially the same as calling `describe` in a for loop.
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any)) 
function describe.each(testCases) end
--- Dummy version of `describe()` which doesn't run the given test suite.
--- It will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param name string
---@param fn fun()
function describe.skip(name, fn) end
--- Dummy version of `describe()` which doesn't run the given test suite.
--- It will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param name string
---@param fn fun()
function xdescribe(name, fn) end
--- Dummy version of `describe.each()` which doesn't run the given test suite cases.
--- They will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any)) 
function describe.skip.each(testCases) end
--- Dummy version of `describe.each()` which doesn't run the given test suite cases.
--- They will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any)) 
function xdescribe.each(testCases) end
--- The `expect` function is used to assert the result(s) of any unit of code being tested.
--- Pass in the value received from the code to be tested, then call one of the matchers returned by the function.
--- 
--- The returned matchers are bound to the received value internally, and should be called by using `.` instead of `:`.
---@param received any
---@return lest.Matchers 
function expect(received) end
--- Creates a new mock function, optionally giving it an implementation if passed.
---@param implementation? fun()
---@return lest.Mock 
function lest.fn(implementation) end
--- Registers a new test with the given name.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param name string
---@param fn fun()
---@param timeout? number
function test(name, fn, timeout) end
--- Registers a new test with the given name.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param name string
---@param fn fun()
---@param timeout? number
function it(name, fn, timeout) end
--- Data driven variant of `test` to reduce duplication when testing the same code with different data.
--- 
--- The returned function matches regular `test`, except the callback you pass to it will be run for each test case you define.
--- The value of each test case will be unpacked and passed to your callback.
--- 
--- This is essentially the same as calling `test` in a for loop.
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any),timeout?:number) 
function test.each(testCases) end
--- Data driven variant of `test` to reduce duplication when testing the same code with different data.
--- 
--- The returned function matches regular `test`, except the callback you pass to it will be run for each test case you define.
--- The value of each test case will be unpacked and passed to your callback.
--- 
--- This is essentially the same as calling `test` in a for loop.
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any),timeout?:number) 
function it.each(testCases) end
--- Dummy version of `test()` which doesn't run the given test.
--- It will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param name string
---@param fn fun()
---@param timeout? number
function test.skip(name, fn, timeout) end
--- Dummy version of `test()` which doesn't run the given test.
--- It will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param name string
---@param fn fun()
---@param timeout? number
function it.skip(name, fn, timeout) end
--- Dummy version of `test()` which doesn't run the given test.
--- It will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param name string
---@param fn fun()
---@param timeout? number
function xtest(name, fn, timeout) end
--- Dummy version of `test()` which doesn't run the given test.
--- It will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param name string
---@param fn fun()
---@param timeout? number
function xit(name, fn, timeout) end
--- Dummy version of `test.each()` which doesn't run the given test cases.
--- They will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any),timeout?:number) 
function test.skip.each(testCases) end
--- Dummy version of `test.each()` which doesn't run the given test cases.
--- They will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any),timeout?:number) 
function it.skip.each(testCases) end
--- Dummy version of `test.each()` which doesn't run the given test cases.
--- They will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any),timeout?:number) 
function xtest.each(testCases) end
--- Dummy version of `test.each()` which doesn't run the given test cases.
--- They will appear in test results as being skipped (this is not implemented yet, see LEST-88).
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any),timeout?:number) 
function xit.each(testCases) end
---@class lest.Matchers
--- Matchers for expect()
--- Inverse matchers
---@field never lest.InverseMatchers
lest.Matchers = {}
--- Performs a referential equality test between the received and expected values.
--- 
--- Two different tables with identical contents are not referentially equal, as the reference to the table stored in the variable is different.
--- If you want to perform a deep equality test between tables, use `.toEqual()` instead.
---@param expected any
function lest.Matchers.toBe(expected) end
--- Use `toBeCloseTo` to compare floating point numbers for approximate equality.
--- 
--- You can optionally specify `numDigits` to set the precision to compare at (default is `2`).
--- Internally it performs the following comparison: `math.abs(expected - received) <  math.pow(10, -numDigits) / 2`.
---@param expected number
---@param numDigits? number
function lest.Matchers.toBeCloseTo(expected, numDigits) end
--- Tests whether the value is defined (not equal to `nil`).
function lest.Matchers.toBeDefined() end
--- Tests whether the value is falsy. In Lua, the only falsy values are `nil` and `false`.
function lest.Matchers.toBeFalsy() end
--- Tests whether the received value is greater than the expected value.
---@param expected number
function lest.Matchers.toBeGreaterThan(expected) end
--- Tests whether the received value is greater than or equal to the expected value.
---@param expected number
function lest.Matchers.toBeGreaterThanOrEqual(expected) end
--- Tests if the received value is positive or negative infinity.
--- Internally this checks that the type of the received value is `number`, and that `math.abs(received)` equals `math.huge`.
function lest.Matchers.toBeInfinity() end
--- Tests whether the received value is an instance of the given metatable.
--- Under the hood, this does `getmetatable(received) == metatable`.
---@param metatable table
function lest.Matchers.toBeInstanceOf(metatable) end
--- Tests whether the received value is less than the expected value.
---@param expected number
function lest.Matchers.toBeLessThan(expected) end
--- Tests whether the received value is less than or equal to the expected value.
---@param expected number
function lest.Matchers.toBeLessThanOrEqual(expected) end
--- Tests if the received value is `NaN` (not a number).
--- Internally this checks if the value is not equal to itself, and also if its type is `number`.
function lest.Matchers.toBeNaN() end
--- Tests whether the value is truthy. In Lua, all values are truthy except `nil` and `false`.
function lest.Matchers.toBeTruthy() end
--- Tests whether the value is undefined (equal to `nil`).
function lest.Matchers.toBeUndefined() end
--- Tests whether the value is undefined (equal to `nil`).
function lest.Matchers.toBeNil() end
--- Tests that the received value contains the given item.
--- 
--- If the received value is a string, this tests whether the substring `item` is contained within the string.
--- 
--- If the received value is a table, this enumerates all properties of the table and passes if any are referentially equal to `item`.
--- If you want to test if any of the table's properties are _deeply equal_ to `item`, use `.toContainEqual()` instead
--- which performs the same equality test as `.toEqual()` on each property.
---@param item any
function lest.Matchers.toContain(item) end
--- Tests that the received value contains the given item.
--- Unlike `.toContain()`, this only works with tables.
--- 
--- This enumerates all properties of the table and passes if any are deeply equal to `item`.
--- It performs the same deep equality test on each property as `.toEqual()`.
--- If you want to test if any of the table's properties are _referentially equal_ to `item`, use `.toContain()` instead.
---@param item any
function lest.Matchers.toContainEqual(item) end
--- Performs a deep equality test between the received and expected values. This only affects table comparison.
--- 
--- If you want to check that two variables contain a reference to the _same_ table
--- and not that they have the same _contents_, use `.toBe()`.
---@param expected any
function lest.Matchers.toEqual(expected) end
--- Tests that a mock function has been called.
--- If you want to test that it was called with specific arguments, or a certain number of times, see the other mock function matchers.
function lest.Matchers.toHaveBeenCalled() end
--- Tests that a mock function has been called.
--- If you want to test that it was called with specific arguments, or a certain number of times, see the other mock function matchers.
function lest.Matchers.toBeCalled() end
--- Tests that a mock function was called a specific number of times.
---@param times number
function lest.Matchers.toHaveBeenCalledTimes(times) end
--- Tests that a mock function was called a specific number of times.
---@param times number
function lest.Matchers.toBeCalledTimes(times) end
--- Tests that a mock function was called with a specific set of arguments.
--- Performs a deep equality test when comparing arguments.
--- 
--- If the mock was called multiple times, this will pass as long as it was called with the given argument(s) _any_ of those times.
--- If you want to test that it was called with certain arguments on a _specific_ call, see `.toHaveBeenLastCalledWith()` and `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.Matchers.toHaveBeenCalledWith(...) end
--- Tests that a mock function was called with a specific set of arguments.
--- Performs a deep equality test when comparing arguments.
--- 
--- If the mock was called multiple times, this will pass as long as it was called with the given argument(s) _any_ of those times.
--- If you want to test that it was called with certain arguments on a _specific_ call, see `.toHaveBeenLastCalledWith()` and `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.Matchers.toBeCalledWith(...) end
--- Tests that a mock function was called with specific arguments on its _most recent_ call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on a _specific call_, see `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.Matchers.toHaveBeenLastCalledWith(...) end
--- Tests that a mock function was called with specific arguments on its _most recent_ call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on a _specific call_, see `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.Matchers.lastCalledWith(...) end
--- Tests that a function was called with specific arguments on its Nth call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on its _most recent_ call, see `.toHaveBeenLastCalledWith()`.
---@param nthCall number
---@param ... any
function lest.Matchers.toHaveBeenNthCalledWith(nthCall, ...) end
--- Tests that a function was called with specific arguments on its Nth call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on its _most recent_ call, see `.toHaveBeenLastCalledWith()`.
---@param nthCall number
---@param ... any
function lest.Matchers.nthCalledWith(nthCall, ...) end
--- Tests that a mock function returned.
--- If you want to test that it returned specific values, or a certain number of times, see the other mock function matchers.
function lest.Matchers.toHaveReturned() end
--- Tests that a mock function returned.
--- If you want to test that it returned specific values, or a certain number of times, see the other mock function matchers.
function lest.Matchers.toReturn() end
--- Tests that a mock function returned a specific number of times.
---@param times number
function lest.Matchers.toHaveReturnedTimes(times) end
--- Tests that a mock function returned a specific number of times.
---@param times number
function lest.Matchers.toReturnTimes(times) end
--- Tests that a mock function returned a specific set of values.
--- Performs a deep equality test when comparing values.
--- 
--- If the mock returned multiple times, this will pass as long as it returned the given value(s) _any_ of those times.
--- If you want to test that it returned certain values on a _specific_ call, see `.toHaveLastReturnedWith()` and `.toHaveNthReturnedWith()`.
---@param ... any
function lest.Matchers.toHaveReturnedWith(...) end
--- Tests that a mock function returned a specific set of values.
--- Performs a deep equality test when comparing values.
--- 
--- If the mock returned multiple times, this will pass as long as it returned the given value(s) _any_ of those times.
--- If you want to test that it returned certain values on a _specific_ call, see `.toHaveLastReturnedWith()` and `.toHaveNthReturnedWith()`.
---@param ... any
function lest.Matchers.toReturnWith(...) end
--- Tests that a mock function returned specific values on its _most recent_ call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on a _specific call_, see `.toHaveNthReturnedWith()`.
---@param ... any
function lest.Matchers.toHaveLastReturnedWith(...) end
--- Tests that a mock function returned specific values on its _most recent_ call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on a _specific call_, see `.toHaveNthReturnedWith()`.
---@param ... any
function lest.Matchers.lastReturnedWith(...) end
--- Tests that a function returned specific values on its Nth call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on its _most recent_ call, see `.toHaveLastReturnedWith()`.
---@param nthCall number
---@param ... any
function lest.Matchers.toHaveNthReturnedWith(nthCall, ...) end
--- Tests that a function returned specific values on its Nth call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on its _most recent_ call, see `.toHaveLastReturnedWith()`.
---@param nthCall number
---@param ... any
function lest.Matchers.nthReturnedWith(nthCall, ...) end
--- Tests that the received value is of the given length.
--- This works with strings, tables and any other value that supports the Lua length operator (`#`).
---@param length number
function lest.Matchers.toHaveLength(length) end
--- Tests that the value matches the given Lua pattern.
---@param pattern string
function lest.Matchers.toMatch(pattern) end
--- Tests whether the received table's properties are a superset of the properties defined in `object`.
--- 
--- For example, if the received table is `{ a = 1, b = 2 }` and `object` is `{ b = 2 }`,
--- then the test passes as `{ a = 1, b = 2 }` is a superset of `{ b = 2 }`.
--- However, if `object` was `{ b = 2, c = 3 }` then the test would fail as
--- the received table does not contain the property `c = 3`.
--- 
--- If the length of the received table does not equal `object`'s then this test will fail.
--- This is useful for matching an array of tables without allowing additional tables to be present.
---@param object table
function lest.Matchers.toMatchObject(object) end
--- Tests whether the received table's properties are a superset of the properties defined in `object`.
--- 
--- For example, if the received table is `{ a = 1, b = 2 }` and `object` is `{ b = 2 }`,
--- then the test passes as `{ a = 1, b = 2 }` is a superset of `{ b = 2 }`.
--- However, if `object` was `{ b = 2, c = 3 }` then the test would fail as
--- the received table does not contain the property `c = 3`.
--- 
--- If the length of the received table does not equal `object`'s then this test will fail.
--- This is useful for matching an array of tables without allowing additional tables to be present.
---@param object table
function lest.Matchers.toMatchTable(object) end
--- Tests whether the received function throws when called.
--- 
--- By default, this will pass as long as the function throws an error.
--- You can additionally pass a value for `message` which will cause the test to pass only if the thrown error matches.
--- 
--- Internally this does `string.match(tostring(error), message)`, so you can use Lua patterns to test more dynamic errors reliably.
---@param message? string
function lest.Matchers.toThrow(message) end
--- Tests whether the received function throws when called.
--- 
--- By default, this will pass as long as the function throws an error.
--- You can additionally pass a value for `message` which will cause the test to pass only if the thrown error matches.
--- 
--- Internally this does `string.match(tostring(error), message)`, so you can use Lua patterns to test more dynamic errors reliably.
---@param message? string
function lest.Matchers.toThrowError(message) end
---@class lest.InverseMatchers
--- Inverse matchers for expect()
lest.InverseMatchers = {}
--- Performs a referential equality test between the received and expected values.
--- 
--- Two different tables with identical contents are not referentially equal, as the reference to the table stored in the variable is different.
--- If you want to perform a deep equality test between tables, use `.toEqual()` instead.
---@param expected any
function lest.InverseMatchers.toBe(expected) end
--- Use `toBeCloseTo` to compare floating point numbers for approximate equality.
--- 
--- You can optionally specify `numDigits` to set the precision to compare at (default is `2`).
--- Internally it performs the following comparison: `math.abs(expected - received) <  math.pow(10, -numDigits) / 2`.
---@param expected number
---@param numDigits? number
function lest.InverseMatchers.toBeCloseTo(expected, numDigits) end
--- Tests whether the value is defined (not equal to `nil`).
function lest.InverseMatchers.toBeDefined() end
--- Tests whether the value is falsy. In Lua, the only falsy values are `nil` and `false`.
function lest.InverseMatchers.toBeFalsy() end
--- Tests whether the received value is greater than the expected value.
---@param expected number
function lest.InverseMatchers.toBeGreaterThan(expected) end
--- Tests whether the received value is greater than or equal to the expected value.
---@param expected number
function lest.InverseMatchers.toBeGreaterThanOrEqual(expected) end
--- Tests if the received value is positive or negative infinity.
--- Internally this checks that the type of the received value is `number`, and that `math.abs(received)` equals `math.huge`.
function lest.InverseMatchers.toBeInfinity() end
--- Tests whether the received value is an instance of the given metatable.
--- Under the hood, this does `getmetatable(received) == metatable`.
---@param metatable table
function lest.InverseMatchers.toBeInstanceOf(metatable) end
--- Tests whether the received value is less than the expected value.
---@param expected number
function lest.InverseMatchers.toBeLessThan(expected) end
--- Tests whether the received value is less than or equal to the expected value.
---@param expected number
function lest.InverseMatchers.toBeLessThanOrEqual(expected) end
--- Tests if the received value is `NaN` (not a number).
--- Internally this checks if the value is not equal to itself, and also if its type is `number`.
function lest.InverseMatchers.toBeNaN() end
--- Tests whether the value is truthy. In Lua, all values are truthy except `nil` and `false`.
function lest.InverseMatchers.toBeTruthy() end
--- Tests whether the value is undefined (equal to `nil`).
function lest.InverseMatchers.toBeUndefined() end
--- Tests whether the value is undefined (equal to `nil`).
function lest.InverseMatchers.toBeNil() end
--- Tests that the received value contains the given item.
--- 
--- If the received value is a string, this tests whether the substring `item` is contained within the string.
--- 
--- If the received value is a table, this enumerates all properties of the table and passes if any are referentially equal to `item`.
--- If you want to test if any of the table's properties are _deeply equal_ to `item`, use `.toContainEqual()` instead
--- which performs the same equality test as `.toEqual()` on each property.
---@param item any
function lest.InverseMatchers.toContain(item) end
--- Tests that the received value contains the given item.
--- Unlike `.toContain()`, this only works with tables.
--- 
--- This enumerates all properties of the table and passes if any are deeply equal to `item`.
--- It performs the same deep equality test on each property as `.toEqual()`.
--- If you want to test if any of the table's properties are _referentially equal_ to `item`, use `.toContain()` instead.
---@param item any
function lest.InverseMatchers.toContainEqual(item) end
--- Performs a deep equality test between the received and expected values. This only affects table comparison.
--- 
--- If you want to check that two variables contain a reference to the _same_ table
--- and not that they have the same _contents_, use `.toBe()`.
---@param expected any
function lest.InverseMatchers.toEqual(expected) end
--- Tests that a mock function has been called.
--- If you want to test that it was called with specific arguments, or a certain number of times, see the other mock function matchers.
function lest.InverseMatchers.toHaveBeenCalled() end
--- Tests that a mock function has been called.
--- If you want to test that it was called with specific arguments, or a certain number of times, see the other mock function matchers.
function lest.InverseMatchers.toBeCalled() end
--- Tests that a mock function was called a specific number of times.
---@param times number
function lest.InverseMatchers.toHaveBeenCalledTimes(times) end
--- Tests that a mock function was called a specific number of times.
---@param times number
function lest.InverseMatchers.toBeCalledTimes(times) end
--- Tests that a mock function was called with a specific set of arguments.
--- Performs a deep equality test when comparing arguments.
--- 
--- If the mock was called multiple times, this will pass as long as it was called with the given argument(s) _any_ of those times.
--- If you want to test that it was called with certain arguments on a _specific_ call, see `.toHaveBeenLastCalledWith()` and `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.InverseMatchers.toHaveBeenCalledWith(...) end
--- Tests that a mock function was called with a specific set of arguments.
--- Performs a deep equality test when comparing arguments.
--- 
--- If the mock was called multiple times, this will pass as long as it was called with the given argument(s) _any_ of those times.
--- If you want to test that it was called with certain arguments on a _specific_ call, see `.toHaveBeenLastCalledWith()` and `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.InverseMatchers.toBeCalledWith(...) end
--- Tests that a mock function was called with specific arguments on its _most recent_ call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on a _specific call_, see `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.InverseMatchers.toHaveBeenLastCalledWith(...) end
--- Tests that a mock function was called with specific arguments on its _most recent_ call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on a _specific call_, see `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.InverseMatchers.lastCalledWith(...) end
--- Tests that a function was called with specific arguments on its Nth call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on its _most recent_ call, see `.toHaveBeenLastCalledWith()`.
---@param nthCall number
---@param ... any
function lest.InverseMatchers.toHaveBeenNthCalledWith(nthCall, ...) end
--- Tests that a function was called with specific arguments on its Nth call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on its _most recent_ call, see `.toHaveBeenLastCalledWith()`.
---@param nthCall number
---@param ... any
function lest.InverseMatchers.nthCalledWith(nthCall, ...) end
--- Tests that a mock function returned.
--- If you want to test that it returned specific values, or a certain number of times, see the other mock function matchers.
function lest.InverseMatchers.toHaveReturned() end
--- Tests that a mock function returned.
--- If you want to test that it returned specific values, or a certain number of times, see the other mock function matchers.
function lest.InverseMatchers.toReturn() end
--- Tests that a mock function returned a specific number of times.
---@param times number
function lest.InverseMatchers.toHaveReturnedTimes(times) end
--- Tests that a mock function returned a specific number of times.
---@param times number
function lest.InverseMatchers.toReturnTimes(times) end
--- Tests that a mock function returned a specific set of values.
--- Performs a deep equality test when comparing values.
--- 
--- If the mock returned multiple times, this will pass as long as it returned the given value(s) _any_ of those times.
--- If you want to test that it returned certain values on a _specific_ call, see `.toHaveLastReturnedWith()` and `.toHaveNthReturnedWith()`.
---@param ... any
function lest.InverseMatchers.toHaveReturnedWith(...) end
--- Tests that a mock function returned a specific set of values.
--- Performs a deep equality test when comparing values.
--- 
--- If the mock returned multiple times, this will pass as long as it returned the given value(s) _any_ of those times.
--- If you want to test that it returned certain values on a _specific_ call, see `.toHaveLastReturnedWith()` and `.toHaveNthReturnedWith()`.
---@param ... any
function lest.InverseMatchers.toReturnWith(...) end
--- Tests that a mock function returned specific values on its _most recent_ call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on a _specific call_, see `.toHaveNthReturnedWith()`.
---@param ... any
function lest.InverseMatchers.toHaveLastReturnedWith(...) end
--- Tests that a mock function returned specific values on its _most recent_ call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on a _specific call_, see `.toHaveNthReturnedWith()`.
---@param ... any
function lest.InverseMatchers.lastReturnedWith(...) end
--- Tests that a function returned specific values on its Nth call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on its _most recent_ call, see `.toHaveLastReturnedWith()`.
---@param nthCall number
---@param ... any
function lest.InverseMatchers.toHaveNthReturnedWith(nthCall, ...) end
--- Tests that a function returned specific values on its Nth call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on its _most recent_ call, see `.toHaveLastReturnedWith()`.
---@param nthCall number
---@param ... any
function lest.InverseMatchers.nthReturnedWith(nthCall, ...) end
--- Tests that the received value is of the given length.
--- This works with strings, tables and any other value that supports the Lua length operator (`#`).
---@param length number
function lest.InverseMatchers.toHaveLength(length) end
--- Tests that the value matches the given Lua pattern.
---@param pattern string
function lest.InverseMatchers.toMatch(pattern) end
--- Tests whether the received table's properties are a superset of the properties defined in `object`.
--- 
--- For example, if the received table is `{ a = 1, b = 2 }` and `object` is `{ b = 2 }`,
--- then the test passes as `{ a = 1, b = 2 }` is a superset of `{ b = 2 }`.
--- However, if `object` was `{ b = 2, c = 3 }` then the test would fail as
--- the received table does not contain the property `c = 3`.
--- 
--- If the length of the received table does not equal `object`'s then this test will fail.
--- This is useful for matching an array of tables without allowing additional tables to be present.
---@param object table
function lest.InverseMatchers.toMatchObject(object) end
--- Tests whether the received table's properties are a superset of the properties defined in `object`.
--- 
--- For example, if the received table is `{ a = 1, b = 2 }` and `object` is `{ b = 2 }`,
--- then the test passes as `{ a = 1, b = 2 }` is a superset of `{ b = 2 }`.
--- However, if `object` was `{ b = 2, c = 3 }` then the test would fail as
--- the received table does not contain the property `c = 3`.
--- 
--- If the length of the received table does not equal `object`'s then this test will fail.
--- This is useful for matching an array of tables without allowing additional tables to be present.
---@param object table
function lest.InverseMatchers.toMatchTable(object) end
--- Tests whether the received function throws when called.
--- 
--- By default, this will pass as long as the function throws an error.
--- You can additionally pass a value for `message` which will cause the test to pass only if the thrown error matches.
--- 
--- Internally this does `string.match(tostring(error), message)`, so you can use Lua patterns to test more dynamic errors reliably.
---@param message? string
function lest.InverseMatchers.toThrow(message) end
--- Tests whether the received function throws when called.
--- 
--- By default, this will pass as long as the function throws an error.
--- You can additionally pass a value for `message` which will cause the test to pass only if the thrown error matches.
--- 
--- Internally this does `string.match(tostring(error), message)`, so you can use Lua patterns to test more dynamic errors reliably.
---@param message? string
function lest.InverseMatchers.toThrowError(message) end