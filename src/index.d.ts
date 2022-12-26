declare class DatalinkSDK {
  constructor(settings: { UserID: number, API_KEY: string });
  isAuthenticated(): boolean;
  authenticateAsync(): Promise<void | never>;
  getFastFlagAsync(flagid: string | number): Promise<void | never>;
  getFastIntAsync(flagid: string | number): Promise<number | never>;
  getAllFastFlagsAsync(): DatalinkFastFlagsBulk[];
  getLocalVariables(): {};
  getLocalVariable(variableName: string): any;
  setLocalVariable(variableName: string, variableValue: string): void;
  setVerboseLogging(state: boolean): void;

  // Signals
  onAuthenticated: RBXScriptSignal

  // Properties
}

export type DatalinkFastFlagsBulk = {
  flagName: string, 
  flagValue: boolean, 
  flagInt: number
}


export type DatalinkInstance = DatalinkSDK
