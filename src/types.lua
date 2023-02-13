---@meta

---@class lest.MatcherContext
---@field inverted boolean -- True if the condition was inverted

---@class lest.TestResult
---@field pass boolean
---@field message string

---@alias lest.Matcher fun(ctx: lest.MatcherContext, received: any, ...: any): lest.TestResult

---@class lest.MockResult
---@field type "return" | "throw"
---@field value any

---@class lest.Test
---@field name string
---@field func fun()
---@field isDescribe false

---@class lest.TestSuite: { [number]: lest.Describe | lest.Test }
---@field beforeEach fun()[]
---@field beforeAll fun()[]
---@field afterEach fun()[]
---@field afterAll fun()[]

---@class lest.Describe: lest.TestSuite
---@field name string
---@field isDescribe true

---@class lest.TestResults: { [string]: lest.TestResult | lest.TestResults }
