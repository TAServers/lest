import { classList, functionsList } from "./json-docs";
import makeFunctionAnnotation from "./generators/function";
import makeClassAnnotation from "./generators/class";

const document = ["---@meta", "-- auto-generated annotations file for Lest types"];
for (const func of functionsList) {
	document.push(makeFunctionAnnotation(func));
}

for (const cls of classList) {
	document.push(makeClassAnnotation(cls));
}

console.log(document.join("\n"));
