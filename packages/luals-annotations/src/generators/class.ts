import { Docs } from "../json-docs";
import makeFunctionAnnotation from "./function";
import convertType from "../luals/convertType";
import createDescriptionAnnotation from "./description";
import combine from "./combine";

export default function makeClassAnnotation(docClass: Docs.Class): string {
	let descriptionAnnotation = createDescriptionAnnotation(docClass.description);
	let classAnnotation = `---@class ${docClass.name}`;
	const fields = docClass.fields ?? [];
	const methods = docClass.methods ?? [];

	let fieldsAnnotation = fields
		.map((field) => `---@field ${field.name} ${convertType(field)} ${field.description}`)
		.join("\n");
	let tableDeclaration = `${docClass.name} = {}`;
	let methodsAnnotation = methods.map((method) => makeFunctionAnnotation(method, docClass.name)).join("\n");

	return combine(descriptionAnnotation, classAnnotation, fieldsAnnotation, tableDeclaration, methodsAnnotation);
}
