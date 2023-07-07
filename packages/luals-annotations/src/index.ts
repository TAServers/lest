import * as functions from "@lest/docs/functions";
import * as classes from "@lest/docs/types";
import * as matchers from "@lest/docs/matchers";
import { Class, Function, FunctionProperty, isFunctionProperty } from "@lest/docs";

import * as fs from "fs";
import AnnotationBuilder, { ClassBuilder } from "./annotationBuilder";

const functionDocs = Object.values<Function>(functions);
const classDocs = Object.values<Class>(classes);
const matcherDocs = Object.values<Function>(matchers);

const document = new AnnotationBuilder();

function generateClasses() {
	classDocs.forEach((classInfo) => {
		const { name, description, fields = [] } = classInfo;
		const cls = new ClassBuilder({
			name,
			description,
		});

		const classMethods = fields.filter((method) => isFunctionProperty(method)) ?? [];
		const classFields = fields.filter((property) => !isFunctionProperty(property)) ?? [];

		classFields.forEach((field) => cls.addField(field));
		cls.addDeclaration();
		classMethods.forEach((method) => cls.addFunction(method as Function));
		document.addClass(cls);
	});
}

function generateFunctions() {
	functionDocs.forEach((func) => {
		document.addFunction(func);
	});
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

generateClasses();
generateFunctions();
generateMatcherClass({ inverse: false });
generateMatcherClass({ inverse: true });

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
