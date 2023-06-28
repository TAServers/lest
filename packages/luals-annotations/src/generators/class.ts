import { Docs } from "../json-docs";
import makeFunctionAnnotation from "./function";
import convertType from "../luals/convertType";
import createDescriptionAnnotation from "./description";
import combine from "./combine";

export default function makeClassAnnotation(docClass: Docs.Class, staticFunctions: boolean = false): string {
	let descriptionAnnotation = createDescriptionAnnotation(docClass.description);
	let classAnnotation = `---@class ${docClass.name}`;
	const fields = docClass.fields ?? [];
	const methods = docClass.methods ?? [];

	function transformFieldDescription(field: Docs.Property): string {
		if (typeof field.description === "string") {
			return field.description;
		} else {
			return field.description.join(" ");
		}
	}
	let fieldsAnnotation = fields
		.map((field) => `---@field ${field.name} ${convertType(field)} ${field.description}`)
		.join("\n");
	let tableDeclaration = `${docClass.name} = {}`;

	const methodCharacter = staticFunctions ? "." : ":";
	let methodsAnnotation = methods
		.map((method) => makeFunctionAnnotation(method, docClass.name + methodCharacter))
		.join("\n");

	return combine(descriptionAnnotation, classAnnotation, fieldsAnnotation, tableDeclaration, methodsAnnotation);
}
