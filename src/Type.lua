export type DatalinkSDK = {
	new: (settings: {
		datalinkUserAccountId: number,
		datalinkUserToken: string
	}) -> DatalinkInstance
}

export type DatalinkInstance = {
	-- METHODS
	isAuthenticated: () -> boolean,
	authenticateAsync: () -> Promise,
	getFastFlagAsync: (flagId: string | number) -> boolean,
	getFastIntAsync: (flagId: string | number) -> number,
	getAllFastFlagsAsync: () -> {
		{
			flagName: string,
			flagValue: boolean,
			flagInt: number
		}
	},

	getLocalVariables: () -> { [string] : any },
	getLocalVariable: (variableName: string) -> any,
	setLocalVariable: (variableName: string, variableValue: any) -> nil,

	setVerboseLogging: (state: boolean) -> nil,
	getPlayerHash: (player: Player) -> string | nil,

	-- SIGNALS
	onAuthenticated: RBXScriptSignal,

	-- PROPERTIES
}

return { }