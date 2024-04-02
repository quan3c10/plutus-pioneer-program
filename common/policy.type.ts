import { Data } from "./deps.ts";

const ScriptTypesSchema = Data.Enum([
    Data.Literal("Native"),
    Data.Literal("PlutusScriptV1"),
    Data.Literal("PlutusScriptV2")
]);
export type ScriptTypes = Data.Static<typeof ScriptTypesSchema>;
export const ScriptTypes = ScriptTypesSchema as unknown as ScriptTypes;

const PolicyScriptSchema = Data.Object({
    type: Data.Tuple([ScriptTypesSchema]),
    description: Data.Literal,
    cborHex: Data.Bytes()
});

export type PolicyScript = Data.Static<typeof PolicyScriptSchema>;
export const PolicyScript = PolicyScriptSchema as unknown as PolicyScript;