declare class PromiseClass {
	public Get(): any
	public Cancel(): void
	public Retry(): any
	public Await(): any

	public Resolve(...arguments: any): any
	public Reject(...arguments: any): any

	public Finally(callback: (Promise: PromiseClass, ...arguments: any) => any): PromiseClass
	public Catch(callback: (Promise: PromiseClass, ...arguments: any) => any): PromiseClass
	public Then(callback: (Promise: PromiseClass, ...arguments: any) => any): PromiseClass
}

declare class ScriptConnection {
	public constructor(Connected: boolean)
	public Disconnect(): void
}

declare class ScriptSignal {
	public Wait(): any
	public Connect(Callback: (...parameters: any) => void): AuthenticatorClass
}

declare class AuthenticatorClass {
    public constructor(id: Number, key: String)
	public new(id: Number, key: String): AuthenticatorClass
}

declare namespace Datalink {
    const Authenticator: AuthenticatorClass

	var initialised: boolean
	
	const onInitialised: ScriptSignal
	const onRequestFailed: ScriptSignal
	const onRequestSuccess: ScriptSignal

    function initialise(authenticatorClass: AuthenticatorClass): true | LuaTuple<[false, string]>
	function fireCustomEvent(eventCategory: string, ...parameters: any): PromiseClass
	function fireLogEvent(logLevel: Enum.AnalyticsLogLevel, message: string, ...parameters: any): PromiseClass
	function fireEconomyEvent(player: Player, economyAction: Enum.AnalyticsEconomyAction, ...parameters: any): PromiseClass
	function fireProgressionEvent(player: Player, category: string, progressionStatus: Enum.AnalyticsProgressionStatus, ...parameters: any): PromiseClass
}