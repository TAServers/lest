import { functionsList } from "@/json-docs";
import makeFunctionAnnotation from "@/generators/function";

const document = ["---@meta", "-- auto-generated annotations file for Lest types"];
for (const func of functionsList) {
	document.push(makeFunctionAnnotation(func));
}

console.log(document.join("\n"));
