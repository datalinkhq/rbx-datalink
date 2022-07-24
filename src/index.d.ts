declare class AuthenticatorClass {
    public constructor(id: Number, key: String)
}

declare namespace Datalink {
    const Authenticator: AuthenticatorClass
    function initialise(authenticatorClass: AuthenticatorClass): true | LuaTuple<[false, string]>
}