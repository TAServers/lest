---@meta

---@class lest.MatcherContext
---@field inverted boolean -- True if the condition was inverted

---@class lest.MatcherResult
---@field pass boolean
---@field message string

---@alias lest.Matcher fun(ctx: lest.MatcherContext, received: any, ...: any): lest.MatcherResult

---@class lest.MockResult
---@field type "return" | "throw"
---@field value any

---@class lest.TestNode
---@field type lest.NodeType
---@field name string

---@class lest.Test: lest.TestNode
---@field type 0
---@field func fun()
---@field timeout number

---@class lest.Hook
---@field func fun()
---@field timeout number

---@class lest.Describe: lest.TestNode, { [number]: lest.Describe | lest.Test }
---@field type 1
---@field beforeEach lest.Hook[]
---@field beforeAll lest.Hook[]
---@field afterEach lest.Hook[]
---@field afterAll lest.Hook[]

---@class lest.TestSuite: lest.Describe
---@field type 2

---@class lest.TestResultNode
---@field type lest.NodeType
---@field pass boolean
---@field name string

---@class lest.TestResult: lest.TestResultNode
---@field type 0
---@field error? any

---@class lest.DescribeResults: { [number]: lest.TestResult | lest.DescribeResults }
---@field type 1
---@field name string

---@class lest.TestSuiteResults: lest.DescribeResults
---@field pass boolean
---@field type 2
