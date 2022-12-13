export type DatalinkSDK = {
	new: (settings: {
		datalinkUserAccountId: number,
		datalinkUserToken: string,
		branchType: string
	}) -> DatalinkInstance
}

export type DatalinkInstance = {
	-- METHODS
	isAuthenticated: () -> boolean,
	authenticateAsync: () -> Promise,
	getFastFlagAsync: (flagId: string | number) -> boolean,
	getFastIntAsync: (flagId: string | number) -> number,
	fireCustomEvent: (eventCategory: string, eventParameters: { [string]: any }) -> Promise,
	getGameLogAsync: (logId: number) -> Promise,
	getAllGameLogsAsync: () -> Promise,
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