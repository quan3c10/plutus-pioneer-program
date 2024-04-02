import { Constr, Data, applyParamsToScript } from "./lucid-cardano/mod.ts";
import { PolicyScript } from "./policy.type.ts";

const jsonDataFile=Deno.args[0];
const jsonData = await Deno.readTextFile("./data/"+jsonDataFile+".plutus");

const script = JSON.parse(jsonData) as PolicyScript;

console.log("Before change: ", jsonData["cborHex"]);

const outRef = new Constr(0, [
    new Constr(0, ["7fe331cbc922d47b75fab515b90bcfa47956c979269872db48f41afb2e1c3245"]),
    BigInt(1),
  ]);

const newCbor = applyParamsToScript(script.cborHex, [outRef]);

script.cborHex = newCbor;

console.log("After change: ", script);

// await Deno.writeTextFile("./data/"+jsonDataFile+".plutus", script);