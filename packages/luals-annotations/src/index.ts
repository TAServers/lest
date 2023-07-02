import * as functions from "@lest/docs/functions";
import * as classes from "@lest/docs/types";
import * as matchers from "@lest/docs/matchers";

import AnnotationBuilder, { ClassBuilder } from "./annotationBuilder.js";
import * as fs from "fs";
import { Docs } from "./docTypes.js";

const document = new AnnotationBuilder();

Object.values<Docs.Class>(classes).forEach((classDef) => {
	const cls = new ClassBuilder({
		name: classDef.name,
		description: classDef.description,
	});

	const methods = classDef.fields.filter((method) => Docs.isFunctionProperty(method)) as Docs.Function[];
	const fields = classDef.fields.filter((property) => property.type !== "function");

	fields.forEach((field) => cls.addField(field));
	cls.addDeclaration();
	methods.forEach((method) => cls.addFunction(method));
	document.addClass(cls);
});

Object.values<Docs.Function>(functions).forEach((func) => {
	document.addFunction(func);
});

const matcherFunctions = Object.values<Docs.Function>(matchers);
const matchersClass = new ClassBuilder({
	name: "lest.Matchers",
	description: "Matchers for expect()",
});

matchersClass.addField({
	name: "never",
	type: "lest.InverseMatchers",
	description: "Inverse matchers",
});

matchersClass.addDeclaration();
matcherFunctions.forEach((matcher) => matchersClass.addFunction(matcher, true));
document.addClass(matchersClass);

const inverseMatchersClass = new ClassBuilder({
	name: "lest.InverseMatchers",
	description: "Inverse matchers for expect()",
});

inverseMatchersClass.addDeclaration();
matcherFunctions.forEach((matcher) => inverseMatchersClass.addFunction(matcher, true));
document.addClass(inverseMatchersClass);

// This environment variable is set by NPM when you pass a double dashed argument to it.
// The dev script passes --debug to the start:ts-node script, so this code is ran when you run `npm run dev`.
if (process.env["npm_config_debug"]) {
	console.log(document.build());
	process.exit(0);
}

const targetFilePath = process.argv[2];
if (!targetFilePath) {
	console.error("No target file path provided");
	process.exit(1);
}

fs.writeFileSync(targetFilePath, document.build());
