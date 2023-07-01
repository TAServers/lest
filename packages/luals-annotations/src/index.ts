import { classes, functions, matchers } from "./json-docs";
import AnnotationBuilder, { ClassBuilder } from "./annotationBuilder";
import * as fs from "fs";

const document = new AnnotationBuilder();

classes.forEach((classDef) => {
	const cls = new ClassBuilder({
		name: classDef.name,
		description: classDef.description,
	});

	classDef.fields?.forEach((field) => cls.addField(field));
	cls.addDeclaration();
	classDef.methods?.forEach((method) => cls.addFunction(method));
	document.addClass(cls);
});

functions.forEach((func) => {
	document.addFunction(func);
});

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
matchers.forEach((matcher) => matchersClass.addFunction(matcher, true));
document.addClass(matchersClass);

const inverseMatchersClass = new ClassBuilder({
	name: "lest.InverseMatchers",
	description: "Inverse matchers for expect()",
});

inverseMatchersClass.addDeclaration();
matchers.forEach((matcher) => inverseMatchersClass.addFunction(matcher, true));
document.addClass(inverseMatchersClass);

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
