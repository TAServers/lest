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
