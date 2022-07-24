--!nocheck 

export type AuthenticatorClass = {
	key: string,
	id: number,

	new: (id: number, key: string) -> AuthenticatorClass
}

export type DataLinkClass = {
	Authenticator: AuthenticatorClass,

	initialise: (authenticatorClass: AuthenticatorClass) -> boolean & string
}

return "DataLinkTypes"