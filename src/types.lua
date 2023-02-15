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

---@class lest.Describe: lest.TestNode, { [number]: lest.Describe | lest.Test }
---@field type 1
---@field beforeEach fun()[]
---@field beforeAll fun()[]
---@field afterEach fun()[]
---@field afterAll fun()[]

---@class lest.TestSuite: lest.Describe
---@field type 2

---@class lest.Tests: { [number]: lest.TestSuite }

---@class lest.TestResultNode
---@field type lest.NodeType
---@field name string

---@class lest.TestResult: lest.TestResultNode
---@field type 0
---@field pass boolean
---@field error? any

---@class lest.DescribeResults: { [number]: lest.TestResult | lest.DescribeResults }
---@field type 1
---@field name string

---@class lest.TestSuiteResults: lest.DescribeResults
---@field type 2

---@class lest.TestResults: { [number]: lest.TestSuiteResults }
