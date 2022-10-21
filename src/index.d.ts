import SinglePlayer = Enum.DialogBehaviorType.SinglePlayer;
import Players = Enum.HttpRequestType.Players;

interface PromiseClass {
    Get(): any;
    Cancel(): void;
    Retry(): any;
    Await(): any;

    Resolve(value: any);
    Reject(value: any);

    Callback(Promise: PromiseClass, Run: () => {}): any;
    Finally(Callback): PromiseClass;
    Then(Callback): PromiseClass;
}

interface AuthenticatorClass {
    key: string;
    id: number;

    constructor(id: number, key: string): AuthenticatorClass;
}

interface DataLinkClass {
    Authenticator: AuthenticatorClass;
    isAuthenticated: boolean;
    onAuthenticated: RBXScriptSignal;
    onRequestFailed: RBXScriptSignal;
    onRequestSuccess: RBXScriptSignal;

    Initialize(developerId, developerKey): void
    YieldUntilDataLinkIsAuthenticated(): void;
    FireCustomEvent(eventCategory: string, ...details: any): PromiseClass;
    FireLogEvent(logLevel: EnumItem, message: string, ...other: any): PromiseClass;
    FireEconomyEvent(player: Players, economyAction: EnumItem, ...other: any): PromiseClass;
    FireProgressionEvent(player: Players, category: string, progressionStatus: EnumItem, ...other: any): PromiseClass;
}


declare const Datalink: DataLinkClass
export = Datalink