---@meta

---@class lest.MessageContext
---@field inverted boolean -- True if the condition was inverted

---@class lest.TestResult
---@field pass boolean
---@field message string | fun(context: lest.MessageContext): string

---@alias lest.Matcher fun(received: any, ...: any): lest.TestResult

---@class lest.MockResult
---@field type "return" | "throw"
---@field value any
