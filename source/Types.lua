export type FlagObject = {
	id: number,
	flagId: string,
	FeatureName: string,
	FeatureValue: string
}

export type FlagListObjects = {
	[number]: FlagObject
}

---------------------------------------------------------------------------

export type LogObject = {
	id: number,
	type: string,
	trace: string,
	message: string
}

export type LogListObjects = {
	[number]: LogObject
}

---------------------------------------------------------------------------

export type PromiseStatus = {
	Started: string,
	Resolved: string,
	Rejected: string,
	Cancelled: string,
}

export type Promise<T> = {
	andThen: (Promise<T>, successHandler: ((...T) -> ...any)?, failureHandler: ((...string) -> ...any)?) -> Promise<T>,
	catch: (Promise<T>, failureHandler: (...any) -> ...any) -> Promise<T>,
	await: (Promise<T>) -> (boolean, ...any),
	expect: (Promise<T>) -> ...any,
	cancel: (Promise<T>) -> (),
	now: (Promise<T>, rejectionValue: any) -> Promise<T>,
	andThenCall: (Promise<T>, callback: (...any) -> any) -> Promise<T>,
	andThenReturn: (Promise<T>, ...any) -> Promise<T>,
	awaitStatus: (Promise<T>) -> (PromiseStatus, ...any),
	finally: (Promise<T>, finallyHandler: (status: PromiseStatus) -> ...any) -> Promise<T>,
	finallyCall: (Promise<T>, callback: (...any) -> any, ...any?) -> Promise<T>,
	finallyReturn: (Promise<T>, ...any) -> Promise<T>,
	getStatus: (Promise<T>) -> PromiseStatus,
	tap: (Promise<T>, tapHandler: (...any) -> ...any) -> Promise<T>,
	timeout: (Promise<T>, seconds: number, rejectionValue: any?) -> Promise<T>,
}

---------------------------------------------------------------------------

export type InternalInterface = {
	getLocalVariable: (InternalInterface, variableName: string) -> any,
	setLocalVariable: (InternalInterface, variableName: string, variableValue: any) -> nil,

	getComponent: (InternalInterface, componentName: string) -> { }
}

export type EventInterface = {
	fireCustomEvent: (EventInterface, eventCategory: string, eventParameters: { [any]: any }) -> Promise<nil>,
	fireResourceEvent: (EventInterface) -> Promise<nil>,
	fireProgressionEvent: (EventInterface) -> Promise<nil>,
	fireEconomyEvent: (EventInterface) -> Promise<nil>
}

export type FlagInterface = {
	getAllFastFlagsAsync: (FlagInterface) -> Promise<FlagListObjects>,
	getFastIntAsync: (FlagInterface) -> Promise<number>,
	getFastFlagAsync: (FlagInterface) -> Promise<boolean>
}

export type LoggingInterface = {
	setLogLevel: (LoggingInterface, level: string) -> nil,
	setVerbosity: (LoggingInterface, state: boolean) -> nil,

	getExperienceLogsAsync: () -> Promise<LogListObjects>,
	getPlaceLogsAsync: () -> Promise<LogListObjects>,
	getLocalLogsAsync: () -> Promise<LogListObjects>,
	getLogAsync: (logId: number) -> Promise<LogObject>
}

---------------------------------------------------------------------------

export type DatalinkSchema = {
	Context: { placeServerId: number, placeServerJobId: string },

	Internal: InternalInterface,
	Logging: LoggingInterface,
	Event: EventInterface,
	Flag: FlagInterface,

	onHeartbeat: RBXScriptSignal,
	onThrottled: RBXScriptSignal,
	onAuthenticated: RBXScriptSignal,
	onDaemonInitiated: RBXScriptSignal,
	onMessageRequestSent: RBXScriptSignal,
	onMessageRequestFail: RBXScriptSignal,

	authenticateAsync: () -> Promise<nil>,
	isAuthenticated: () -> boolean,
	destroyAsync: () -> Promise<nil>
}

---------------------------------------------------------------------------

export type DatalinkInterface = {
	new: (datalinkSettings: {
		accountId: number,
	  	accountToken: string
	}) -> DatalinkSchema
}

return { }
