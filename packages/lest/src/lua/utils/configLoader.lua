local parseCliOptions = require("src.lua.utils.cliParser")

---@class ConfigProperty
---@field default any
---@field type type
---@field cliOnly? boolean

local CLI_ARGUMENT_CASTS_BY_TYPE = {
	number = tonumber,
	string = function(arg)
		return arg
	end,
	boolean = function(arg)
		return arg == "true"
	end,
	table = function(arg)
		local tbl = {}
		for match in arg:gmatch("([^,]+)") do
			table.insert(tbl, match)
		end
		return tbl
	end,
}

--- Returns the appropriate value for a property given a CLI and config file value
---@param property ConfigProperty
---@param cliValue string?
---@param configFileValue any?
---@return any
local function getPropertyValue(property, cliValue, configFileValue)
	if cliValue ~= nil then
		local cast = CLI_ARGUMENT_CASTS_BY_TYPE[property.type]
			or CLI_ARGUMENT_CASTS_BY_TYPE.string
		return cast(cliValue)
	end

	if configFileValue ~= nil and not property.cliOnly then
		return configFileValue
	end

	return property.default
end

---@class ConfigLoader
---@field properties table<string, ConfigProperty>
local ConfigLoader = {}
ConfigLoader.__index = ConfigLoader

--- Create a new config loader
---@return ConfigLoader
function ConfigLoader.new()
	return setmetatable({ properties = {} }, ConfigLoader)
end

--- Registers a new configuration property
---@param name string
---@param options? ConfigProperty
---@return self
function ConfigLoader:registerProperty(name, options)
	self.properties[name] = options
	return self
end

--- Loads a config with the registered properties
---@param cliArgs string[]
---@return table<string, any>
function ConfigLoader:load(cliArgs)
	local cliOptions = parseCliOptions(cliArgs)

	local configPath = cliOptions.config or cliOptions.c or "lest.config.lua"
	local configLoaded, configFile = pcall(dofile, configPath)
	if not configLoaded then
		configFile = {}
	end

	local mergedConfig = {}
	for propertyName, property in pairs(self.properties) do
		local propertyValue = getPropertyValue(
			property,
			cliOptions[propertyName],
			configFile[propertyName]
		)

		if type(propertyValue) ~= property.type then
			print(
				string.format(
					"Invalid config: Expected %s to be a %s",
					propertyName,
					property.type
				)
			)
			os.exit(1)
		end

		mergedConfig[propertyName] = propertyValue
	end

	return mergedConfig
end

return ConfigLoader
