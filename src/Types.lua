--!nocheck

export type PromiseClass = {
	Get: () -> ... any,
	Cancel: () -> nil,
	Retry: () -> ... any,
	Await: () -> ... any,

	Resolve: (... any) -> nil,
	Reject: (... any) -> nil,

	Finally: (callback: (Promise: PromiseClass, ... any) -> any) -> PromiseClass,
	Catch: (callback: (Promise: PromiseClass, ... any) -> any) -> PromiseClass,
	Then: (callback: (Promise: PromiseClass, ... any) -> any) -> PromiseClass
}

export type ScriptConnection = {
	Connected: boolean,
	Disconnect: () -> nil
}

export type ScriptSignal = {
	Wait: () -> ...any,
	Connect: (Callback: (... any) -> any) -> ScriptConnection
}

export type AuthenticatorClass = {
	key: string,
	id: number,

	new: (id: number, key: string) -> AuthenticatorClass
}

export type DataLinkClass = {
	Authenticator: AuthenticatorClass,

	isAuthenticated: boolean,

	onAuthenticated: ScriptSignal,
	onRequestFailed: ScriptSignal,
	onRequestSuccess: ScriptSignal,

	YieldUntilDataLinkIsAuthenticated: () -> nil,

    Initialize: (developerId: number, developerKey: string) -> nil
	FireCustomEvent: (eventCategory: string, ... any) -> PromiseClass,
	FireLogEvent: (logLevel: Enum, message: string, ... any) -> PromiseClass,
	FireEconomyEvent: (player: Player, economyAction: Enum, ... any) -> PromiseClass,
	FireProgressionEvent: (player: Player, category: string, progressionStatus: Enum, ... any) -> PromiseClass
}

return "DataLinkTypes"