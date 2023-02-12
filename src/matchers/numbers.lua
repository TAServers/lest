---@type lest.Matcher
local function toBeCloseTo(ctx, received, expected, numDigits) end

---@type lest.Matcher
local function toBeGreaterThan(ctx, received, expected) end

---@type lest.Matcher
local function toBeGreaterThanOrEqual(ctx, received, expected) end

---@type lest.Matcher
local function toBeLessThan(ctx, received, expected) end

---@type lest.Matcher
local function toBeLessThanOrEqual(ctx, received, expected) end

---@type lest.Matcher
local function toBeNaN(ctx, received) end

---@type lest.Matcher
local function toBeInfinity(ctx, received) end

return {}
