import * as functions from "@lest/docs/functions";
import * as classes from "@lest/docs/types";
import * as matchers from "@lest/docs/matchers";
import { Class, Function, isFunctionProperty } from "@lest/docs";

import * as fs from "fs";
import AnnotationBuilder, { ClassBuilder } from "./annotationBuilder";

const functionDocs = Object.values<Function>(functions);
const classDocs = Object.values<Class>(classes);
const matcherDocs = Object.values<Function>(matchers);

const document = new AnnotationBuilder();

function generateClass({ name, description, fields = [] }: Class) {
	const cls = new ClassBuilder({
		name,
		description,
	});

	const classMethods = fields.filter((method) => isFunctionProperty(method));
	const classFields = fields.filter((property) => !isFunctionProperty(property));

	classFields.forEach((field) => cls.addField(field));
	cls.addDeclaration();
	classMethods.forEach((method) => cls.addFunction(method as Function));
	document.addClass(cls);
}

function generateMatcherClass({ inverse }: { inverse: boolean }) {
	const name = inverse ? "lest.InverseMatchers" : "lest.Matchers";
	const description = inverse ? "Inverse matchers for expect()" : "Matchers for expect()";

	const matchersClass = new ClassBuilder({
		name,
		description,
	});

	if (!inverse) {
		matchersClass.addField({
			name: "never",
			type: "lest.InverseMatchers",
			description: "Inverse matchers",
		});
	}

	matchersClass.addDeclaration();
	matcherDocs.forEach((matcher) => matchersClass.addFunction(matcher, true));
	document.addClass(matchersClass);
}

classDocs.forEach(generateClass);
functionDocs.forEach((func) => document.addFunction(func));
generateMatcherClass({ inverse: false });
generateMatcherClass({ inverse: true });

// This environment variable is set by NPM when you pass --debug to it
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
