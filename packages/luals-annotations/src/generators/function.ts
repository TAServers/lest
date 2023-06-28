import { Docs } from "../json-docs";
import convertType from "../luals/convertType";
import createDescriptionAnnotation from "./description";
import combine from "./combine";

export default function makeFunctionAnnotation(func: Docs.Function, parentClass?: string): string {
	function makeSignature(name: string, params: Docs.Property[]): string {
		return `function ${parentClass ? parentClass : ""}${name}(${params.map((param) => param.name).join(",")}) end`;
	}

	let descriptionAnnotation = createDescriptionAnnotation(func.description);
	const params = func.parameters ?? [];
	const returns = func.returns ?? [];
	const signature = makeSignature(func.name, params);

	let paramAnnotation = params
		.map((param) => `---@param ${param.name}${param.optional ? "?" : ""} ${convertType(param)}`)
		.join("\n");
	let returnAnnotation = returns.map((ret) => `---@return ${convertType(ret)} ${ret.name ?? ""}`).join("\n");

	const fullAnnotation = combine(descriptionAnnotation, paramAnnotation, returnAnnotation);

	if (!func.aliases) {
		return fullAnnotation + "\n" + signature;
	} else {
		return [func.name, ...func.aliases]
			.map((name) => fullAnnotation + "\n" + makeSignature(name, params))
			.join("\n");
	}
}
