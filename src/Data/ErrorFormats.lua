local Error = require(script.Parent.Parent.Enums.Error)

return table.freeze({
	[Error.AlreadyInitializedError] = "DatalinkSDK has already been initialized."
})