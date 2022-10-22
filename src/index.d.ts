import Players = Enum.HttpRequestType.Players;

interface PromiseClass {
    Get(): any;
    Cancel(): void;
    Retry(): any;
    Await(): any;

    Resolve(value: any): void;
    Reject(value: any): void;

    Callback(Promise: PromiseClass, Run: () => {}): any;
    Finally(arg0: Callback): PromiseClass;
    Then(arg0: Callback): PromiseClass;
}

interface AuthenticatorClass {
    key: string;
    id: number;

    constructor(id: number, key: string): AuthenticatorClass;
}

interface DatalinkClass {
    new(): void;
    Authenticator: AuthenticatorClass;
    isAuthenticated: boolean;
    onAuthenticated: RBXScriptSignal;
    onRequestFailed: RBXScriptSignal;
    onRequestSuccess: RBXScriptSignal;

    Initialize(developerId: number, developerKey: string): void
    YieldUntilDataLinkIsAuthenticated(): void;
    FireCustomEvent(eventCategory: string, ...data: any): PromiseClass;
    FireLogEvent(logLevel: EnumItem, message: string, ...other: any): PromiseClass;
    GetFastInt(featureName: string, def?: number): PromiseClass;
    GetFastFlag(featureName: string, ignoreCache?: boolean): PromiseClass;
    SetVerboseLogging(state: boolean): void;
    SetVariable(name: string, value: any): void;
    GetVariable(name: string): void;
    FireEconomyEvent(player: Players, economyAction: EnumItem, ...other: any): PromiseClass;
    FireProgressionEvent(player: Players, category: string, progressionStatus: EnumItem, ...other: any): PromiseClass;
}


declare const Datalink: DatalinkClass
export = Datalink