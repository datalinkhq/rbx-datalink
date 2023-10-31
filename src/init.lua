--[[
	Datalink SDK - https://github.com/datalinkhq/rbx-datalink

	...
]]

local Loader = require(script.Packages.Loader)
local Promise = require(script.Packages.Promise)
local Console = require(script.Packages.Console)
local Sift = require(script.Packages.Sift)

local Error = require(script.Enums.Error)
 
local ErrorFormats = require(script.Data.ErrorFormats)

local ON_INIT_LIFECYCLE_NAME = "OnInit"
local ON_START_LIFECYCLE_NAME = "OnStart"

local DatalinkSDK = { }

DatalinkSDK.Public = { }
DatalinkSDK.Private = { }

DatalinkSDK.Public.Private = DatalinkSDK.Private
DatalinkSDK.Private.Public = DatalinkSDK.Public

DatalinkSDK.Private.IsInitialized = false
DatalinkSDK.Private.Reporter = Console.new("🕙 DatalinkSDK-Reporter")

function DatalinkSDK.Private.FromError(_: DatalinkPrivateAPI, errorEnum:string, ...: string)
	return string.format(ErrorFormats[errorEnum], ...)
end

function DatalinkSDK.Public.SetAccountToken(self: DatalinkPublicAPI)

end

function DatalinkSDK.Public.SetAccountId(self: DatalinkPublicAPI)

end

function DatalinkSDK.Public.InitializeAsync(self: DatalinkPublicAPI)
	return Promise.new(function(resolve, reject)
		if self.Private.IsInitialized then
			return reject(self.Private:FromError(Error.AlreadyInitializedError))
		end
		
		local runtimeClockSnapshot = os.clock()
		local datalinkServices = Sift.Dictionary.values(Loader.LoadChildren(script.Services, function(moduleInstance)
			self.Private.Reporter:Debug(`Loading DatalinkSDK Service module: '{moduleInstance.Name}'`)

			return true
		end))

		table.sort(datalinkServices, function(serviceA, serviceB)
			return (serviceA.Priority or 0) > (serviceB.Priority or 0)
		end)

		Loader.SpawnAll(datalinkServices, ON_INIT_LIFECYCLE_NAME)
		Loader.SpawnAll(datalinkServices, ON_START_LIFECYCLE_NAME)

		self.Private.IsInitialized = true

		self.Private.Reporter:Debug(`Loaded all DatalinkSDK Services ({os.clock() - runtimeClockSnapshot}ms)`)

		return resolve()
	end)
end

type DatalinkPublicAPI = typeof(DatalinkSDK.Public)
type DatalinkPrivateAPI = typeof(DatalinkSDK.Private)

export type DatalinkSDK = DatalinkPublicAPI & { Private: nil }

return DatalinkSDK.Public