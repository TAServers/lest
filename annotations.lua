---@meta
---@class lest.Mock
--- Class representing mocked functions.
---@field mock {calls:any[][],lastCall:any[],results:lest.MockResult[],lastResult:lest.MockResult} Data relating to the mocked function such as call arguments and return values. You shouldn't need to access this directly. Instead, a range of mock function matchers are provided as abstractions.
---@field mockName fun(name:string):self Sets the name that will be used for the mock in test output (or other prints).
---@field getMockName fun():string Gets the name that will be used for the mock in test output (or other prints).
---@field mockImplementation fun(fn:fun(...:any):any):self Mocks the function's implementation. This is the same as passing a function to `lest.fn()`, and will override any function that was passed there.  If you've pushed a one-time implementation with `mockImplementationOnce`, then this function will not override it. This is because the persistent implementation is a fallback and stored separately.
---@field getMockImplementation fun():fun(...:any):any Gets the mock function's implementation. This is the function that's called whenever the mock is called.  If you've pushed a one-time implementation with `mockImplementationOnce`, then this function will still return the persistent implementation. This is because the persistent implementation is a fallback and stored separately.
---@field mockImplementationOnce fun(fn:fun(...:any):any):self Mocks the function's implementation for one call. The one-time implementations will be consumed in the order they were given (first in, first out).  `getMockImplementation` will still return the persistent implementation regardless of any one-time implementations pushed. This is because the persistent implementation is a fallback and stored separately.
---@field mockReturnValue fun(...:any):self Mocks the function's return value. This is shorthand for `mockFn:mockImplementation(function() return ... end)`  See `mockImplementation`'s documentation for more information.
---@field mockReturnValueOnce fun(...:any):self Mocks the function's return value for a single call. This is shorthand for `mockFn:mockImplementationOnce(function() return ... end)`  See `mockImplementationOnce`'s documentation for more information.
---@field mockReturnThis fun(...:any):self Mocks the function's implementation to return `self`. This is shorthand for `mockFn:mockImplementation(function(self) return self end)`  This is useful for mocking functions that chain. See `mockImplementation`'s documentation for more information.
---@field mockClear fun() Clears all information stored in the `mockFn.mock` table (calls and results).  Note that this replaces `mockFn.mock`, not its contents. Make sure you're not storing a stale reference to the old table.  To also reset mocked implementations and return values, call `mockFn:mockReset()`.
---@field mockReset fun() Clears all information stored in the `mockFn.mock` table (calls and results) _and_ removes all mocked implementations and return values.  Note that this replaces `mockFn.mock`, not its contents. Make sure you're not storing a stale reference to the old table.  To only reset the calls and results of the mock, use `mockFn:mockClear()` instead.
lest.Mock = {}
---@class lest.MockResult
--- When a mock function returns or throws, an instance of `lest.MockResult` is added to the mock's data containing information about the result.
---@field type "return" | "throw" - If the mock function ran successfully when it was last called, then this will be `"return"`. - If the function threw an error, then this will be `"throw"`.
---@field value any - If the result type is `"return"`, then this will be an array of the values returned by the mock function. - If the result type is `"throw"`, then this will be the error that was thrown.
lest.MockResult = {}
--- Runs a function after all tests in this file have completed.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param fn fun()
---@param timeout? number
function afterAll(fn,timeout) end
--- Runs a function after each tests in this file completes.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param fn fun()
---@param timeout? number
function afterEach(fn,timeout) end
--- Runs a function before running the tests in this file.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param fn fun()
---@param timeout? number
function beforeAll(fn,timeout) end
--- Runs a function before running each test in this file.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param fn fun()
---@param timeout? number
function beforeEach(fn,timeout) end
--- Data driven variant of `describe` to reduce duplication when testing the same code with different data.
--- 
--- The returned function matches regular `describe`, except the callback you pass to it will be run for each test case you define.
--- The value of each test case will be unpacked and passed to your callback.
--- 
--- This is essentially the same as calling `describe` in a for loop.
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any)) 
function describe.each(testCases) end
--- Creates a block that groups related tests together.
--- 
--- If you register a function for any of the setup/teardown hooks (`afterAll`, `afterEach`, `beforeAll` and `beforeEach`)
--- inside the `describe`, they'll only exist while running tests defined in that `describe` block (or any nested `describe`s).
---@param name string
---@param fn fun()
function describe(name,fn) end
--- The `expect` function is used to assert the result(s) of any unit of code being tested.
--- Pass in the value received from the code to be tested, then call one of the matchers returned by the function.
--- 
--- The returned matchers are bound to the received value internally, and should be called by using `.` instead of `:`.
---@param received any
---@return lest.Matchers 
function expect(received) end
--- Data driven variant of `test` to reduce duplication when testing the same code with different data.
--- 
--- The returned function matches regular `test`, except the callback you pass to it will be run for each test case you define.
--- The value of each test case will be unpacked and passed to your callback.
--- 
--- This is essentially the same as calling `test` in a for loop.
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any),timeout?:number) 
function it.each(testCases) end
--- Data driven variant of `test` to reduce duplication when testing the same code with different data.
--- 
--- The returned function matches regular `test`, except the callback you pass to it will be run for each test case you define.
--- The value of each test case will be unpacked and passed to your callback.
--- 
--- This is essentially the same as calling `test` in a for loop.
---@param testCases any[]
---@return fun(name:string,fn:fun(...:any),timeout?:number) 
function test.each(testCases) end
--- Registers a new test with the given name.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param name string
---@param fn fun()
---@param timeout? number
function it(name,fn,timeout) end
--- Registers a new test with the given name.
--- 
--- You can provide an optional `timeout` (in milliseconds) to specify how long to wait before aborting the callback.
--- The default timeout is 5 seconds.
---@param name string
---@param fn fun()
---@param timeout? number
function test(name,fn,timeout) end
--- Creates a new mock function, optionally giving it an implementation if passed.
---@param implementation? fun()
---@return lest.Mock 
function lest.fn(implementation) end
---@class lest.Matchers
--- Matchers for expect()
---@field never lest.InverseMatchers Inverse matchers
lest.Matchers = {}
--- Performs a referential equality test between the received and expected values.
--- 
--- Two different tables with identical contents are not referentially equal, as the reference to the table stored in the variable is different.
--- If you want to perform a deep equality test between tables, use `.toEqual()` instead.
---@param expected any
function lest.Matchers.toBe(expected) end
--- Tests that a mock function has been called.
--- If you want to test that it was called with specific arguments, or a certain number of times, see the other mock function matchers.
function lest.Matchers.toBeCalled() end
--- Tests that a mock function has been called.
--- If you want to test that it was called with specific arguments, or a certain number of times, see the other mock function matchers.
function lest.Matchers.toHaveBeenCalled() end
--- Tests that a mock function was called a specific number of times.
---@param times number
function lest.Matchers.toBeCalledTimes(times) end
--- Tests that a mock function was called a specific number of times.
---@param times number
function lest.Matchers.toHaveBeenCalledTimes(times) end
--- Tests that a mock function was called with a specific set of arguments.
--- Performs a deep equality test when comparing arguments.
--- 
--- If the mock was called multiple times, this will pass as long as it was called with the given argument(s) _any_ of those times.
--- If you want to test that it was called with certain arguments on a _specific_ call, see `.toHaveBeenLastCalledWith()` and `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.Matchers.toBeCalledWith(...) end
--- Tests that a mock function was called with a specific set of arguments.
--- Performs a deep equality test when comparing arguments.
--- 
--- If the mock was called multiple times, this will pass as long as it was called with the given argument(s) _any_ of those times.
--- If you want to test that it was called with certain arguments on a _specific_ call, see `.toHaveBeenLastCalledWith()` and `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.Matchers.toHaveBeenCalledWith(...) end
--- Tests that a mock function was called with specific arguments on its _most recent_ call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on a _specific call_, see `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.Matchers.lastCalledWith(...) end
--- Tests that a mock function was called with specific arguments on its _most recent_ call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on a _specific call_, see `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.Matchers.toHaveBeenLastCalledWith(...) end
--- Tests that a function was called with specific arguments on its Nth call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on its _most recent_ call, see `.toHaveBeenLastCalledWith()`.
---@param nthCall number
---@param ... any
function lest.Matchers.nthCalledWith(nthCall,...) end
--- Tests that a function was called with specific arguments on its Nth call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on its _most recent_ call, see `.toHaveBeenLastCalledWith()`.
---@param nthCall number
---@param ... any
function lest.Matchers.toHaveBeenNthCalledWith(nthCall,...) end
--- Tests that a mock function returned specific values on its _most recent_ call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on a _specific call_, see `.toHaveNthReturnedWith()`.
---@param ... any
function lest.Matchers.lastReturnedWith(...) end
--- Tests that a mock function returned specific values on its _most recent_ call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on a _specific call_, see `.toHaveNthReturnedWith()`.
---@param ... any
function lest.Matchers.toHaveLastReturnedWith(...) end
--- Tests that a function returned specific values on its Nth call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on its _most recent_ call, see `.toHaveLastReturnedWith()`.
---@param nthCall number
---@param ... any
function lest.Matchers.nthReturnedWith(nthCall,...) end
--- Tests that a function returned specific values on its Nth call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on its _most recent_ call, see `.toHaveLastReturnedWith()`.
---@param nthCall number
---@param ... any
function lest.Matchers.toHaveNthReturnedWith(nthCall,...) end
--- Tests that a mock function returned.
--- If you want to test that it returned specific values, or a certain number of times, see the other mock function matchers.
function lest.Matchers.toReturn() end
--- Tests that a mock function returned.
--- If you want to test that it returned specific values, or a certain number of times, see the other mock function matchers.
function lest.Matchers.toHaveReturned() end
--- Tests that a mock function returned a specific number of times.
---@param times number
function lest.Matchers.toReturnTimes(times) end
--- Tests that a mock function returned a specific number of times.
---@param times number
function lest.Matchers.toHaveReturnedTimes(times) end
--- Tests that a mock function returned a specific set of values.
--- Performs a deep equality test when comparing values.
--- 
--- If the mock returned multiple times, this will pass as long as it returned the given value(s) _any_ of those times.
--- If you want to test that it returned certain values on a _specific_ call, see `.toHaveLastReturnedWith()` and `.toHaveNthReturnedWith()`.
---@param ... any
function lest.Matchers.toReturnWith(...) end
--- Tests that a mock function returned a specific set of values.
--- Performs a deep equality test when comparing values.
--- 
--- If the mock returned multiple times, this will pass as long as it returned the given value(s) _any_ of those times.
--- If you want to test that it returned certain values on a _specific_ call, see `.toHaveLastReturnedWith()` and `.toHaveNthReturnedWith()`.
---@param ... any
function lest.Matchers.toHaveReturnedWith(...) end
---@class lest.InverseMatchers
--- Inverse matchers
lest.InverseMatchers = {}
--- Performs a referential equality test between the received and expected values.
--- 
--- Two different tables with identical contents are not referentially equal, as the reference to the table stored in the variable is different.
--- If you want to perform a deep equality test between tables, use `.toEqual()` instead.
---@param expected any
function lest.InverseMatchers.toBe(expected) end
--- Tests that a mock function has been called.
--- If you want to test that it was called with specific arguments, or a certain number of times, see the other mock function matchers.
function lest.InverseMatchers.toBeCalled() end
--- Tests that a mock function has been called.
--- If you want to test that it was called with specific arguments, or a certain number of times, see the other mock function matchers.
function lest.InverseMatchers.toHaveBeenCalled() end
--- Tests that a mock function was called a specific number of times.
---@param times number
function lest.InverseMatchers.toBeCalledTimes(times) end
--- Tests that a mock function was called a specific number of times.
---@param times number
function lest.InverseMatchers.toHaveBeenCalledTimes(times) end
--- Tests that a mock function was called with a specific set of arguments.
--- Performs a deep equality test when comparing arguments.
--- 
--- If the mock was called multiple times, this will pass as long as it was called with the given argument(s) _any_ of those times.
--- If you want to test that it was called with certain arguments on a _specific_ call, see `.toHaveBeenLastCalledWith()` and `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.InverseMatchers.toBeCalledWith(...) end
--- Tests that a mock function was called with a specific set of arguments.
--- Performs a deep equality test when comparing arguments.
--- 
--- If the mock was called multiple times, this will pass as long as it was called with the given argument(s) _any_ of those times.
--- If you want to test that it was called with certain arguments on a _specific_ call, see `.toHaveBeenLastCalledWith()` and `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.InverseMatchers.toHaveBeenCalledWith(...) end
--- Tests that a mock function was called with specific arguments on its _most recent_ call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on a _specific call_, see `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.InverseMatchers.lastCalledWith(...) end
--- Tests that a mock function was called with specific arguments on its _most recent_ call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on a _specific call_, see `.toHaveBeenNthCalledWith()`.
---@param ... any
function lest.InverseMatchers.toHaveBeenLastCalledWith(...) end
--- Tests that a function was called with specific arguments on its Nth call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on its _most recent_ call, see `.toHaveBeenLastCalledWith()`.
---@param nthCall number
---@param ... any
function lest.InverseMatchers.nthCalledWith(nthCall,...) end
--- Tests that a function was called with specific arguments on its Nth call.
--- 
--- If you want to test that a mock function was called with specific arguments, but don't care when, see `.toHaveBeenCalledWith()`.
--- If you want to test that a mock function was called with arguments on its _most recent_ call, see `.toHaveBeenLastCalledWith()`.
---@param nthCall number
---@param ... any
function lest.InverseMatchers.toHaveBeenNthCalledWith(nthCall,...) end
--- Tests that a mock function returned specific values on its _most recent_ call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on a _specific call_, see `.toHaveNthReturnedWith()`.
---@param ... any
function lest.InverseMatchers.lastReturnedWith(...) end
--- Tests that a mock function returned specific values on its _most recent_ call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on a _specific call_, see `.toHaveNthReturnedWith()`.
---@param ... any
function lest.InverseMatchers.toHaveLastReturnedWith(...) end
--- Tests that a function returned specific values on its Nth call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on its _most recent_ call, see `.toHaveLastReturnedWith()`.
---@param nthCall number
---@param ... any
function lest.InverseMatchers.nthReturnedWith(nthCall,...) end
--- Tests that a function returned specific values on its Nth call.
--- 
--- If you want to test that a mock function returned specific values, but don't care when, see `.toHaveReturnedWith()`.
--- If you want to test that a mock function returned values on its _most recent_ call, see `.toHaveLastReturnedWith()`.
---@param nthCall number
---@param ... any
function lest.InverseMatchers.toHaveNthReturnedWith(nthCall,...) end
--- Tests that a mock function returned.
--- If you want to test that it returned specific values, or a certain number of times, see the other mock function matchers.
function lest.InverseMatchers.toReturn() end
--- Tests that a mock function returned.
--- If you want to test that it returned specific values, or a certain number of times, see the other mock function matchers.
function lest.InverseMatchers.toHaveReturned() end
--- Tests that a mock function returned a specific number of times.
---@param times number
function lest.InverseMatchers.toReturnTimes(times) end
--- Tests that a mock function returned a specific number of times.
---@param times number
function lest.InverseMatchers.toHaveReturnedTimes(times) end
--- Tests that a mock function returned a specific set of values.
--- Performs a deep equality test when comparing values.
--- 
--- If the mock returned multiple times, this will pass as long as it returned the given value(s) _any_ of those times.
--- If you want to test that it returned certain values on a _specific_ call, see `.toHaveLastReturnedWith()` and `.toHaveNthReturnedWith()`.
---@param ... any
function lest.InverseMatchers.toReturnWith(...) end
--- Tests that a mock function returned a specific set of values.
--- Performs a deep equality test when comparing values.
--- 
--- If the mock returned multiple times, this will pass as long as it returned the given value(s) _any_ of those times.
--- If you want to test that it returned certain values on a _specific_ call, see `.toHaveLastReturnedWith()` and `.toHaveNthReturnedWith()`.
---@param ... any
function lest.InverseMatchers.toHaveReturnedWith(...) end