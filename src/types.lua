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

---@class lest.TestNode
---@field type lest.TestNodeType
---@field name string

---@class lest.Test: lest.TestNode
---@field type 0
---@field func fun()

---@class lest.Describe: lest.TestNode, { [number]: lest.Describe | lest.Test }
---@field type 1
---@field beforeEach fun()[]
---@field beforeAll fun()[]
---@field afterEach fun()[]
---@field afterAll fun()[]

---@class lest.TestSuite: lest.Describe
---@field type 2

---@class lest.Tests: { [number]: lest.TestSuite }

---@class lest.TestResults: { [string]: lest.TestResult | lest.TestResults }
