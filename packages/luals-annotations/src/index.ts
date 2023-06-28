import { classes, functions, matchers } from "./json-docs";
import AnnotationBuilder from "./annotationBuilder";
import * as fs from "fs";

const document = new AnnotationBuilder();
document.add("---@meta");

classes.forEach((classDef) => {
	document.withClass(classDef.name, classDef.description, false, () => {
		classDef.fields?.forEach((field) => document.addField(field));
		document.addClassDeclaration();
		classDef.methods?.forEach((method) => document.addFunction(method));
	});
});

functions.forEach((func) => {
	document.addFunction(func);
});

document.withClass("lest.Matchers", "Matchers for expect()", true, () => {
	document.addField({
		name: "never",
		type: "lest.InverseMatchers",
		description: "Inverse matchers",
	});

	document.addClassDeclaration();
	matchers.forEach((matcher) => document.addFunction(matcher));
});

document.withClass("lest.InverseMatchers", "Inverse matchers", true, () => {
	document.addClassDeclaration();
	matchers.forEach((matcher) => document.addFunction(matcher));
});

const targetFilePath = process.argv[2];
if (!targetFilePath) {
	console.error("No target file path provided");
	process.exit(1);
}

fs.writeFileSync(targetFilePath, document.toString());
