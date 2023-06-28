import { classList, functionsList, matcherFunctions } from "./json-docs";
import AnnotationBuilder from "./annotationBuilder";
import * as fs from "fs";

const document = new AnnotationBuilder();
document.add("---@meta", "-- autogenerated");

classList.forEach((classDef) => {
	document.startClass(classDef.name, classDef.description);
	classDef.fields?.forEach((field) => document.addField(field));
	document.addClassDeclaration();
	classDef.methods?.forEach((method) => document.addFunction(method));
	document.endClass();
});

functionsList.forEach((func) => {
	document.addFunction(func);
});

document.startClass("lest.Matchers", "Matchers for expect()", true);
document.addField({
	name: "never",
	type: "lest.InverseMatchers",
	description: "Inverse matchers",
});
document.addClassDeclaration();
matcherFunctions.forEach((func) => document.addFunction(func));
document.endClass();

document.startClass("lest.InverseMatchers", "Inverse matchers", true);
document.addClassDeclaration();
matcherFunctions.forEach((func) => document.addFunction(func));
document.endClass();

const targetFilePath = process.argv[2];
if (!targetFilePath) {
	console.error("No target file path provided");
	process.exit(1);
}

fs.writeFileSync(targetFilePath, document.toString());
