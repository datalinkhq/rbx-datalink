local SchemaType = require(script.Parent.Parent.Enums.SchemaType)

return table.freeze({
	[SchemaType.Model] = "%s%s",
	[SchemaType.ModelUrlOnline] = "https://datalink.dev/api",
	[SchemaType.ModelUrlOffline] = "http://localhost:3000/api"
})