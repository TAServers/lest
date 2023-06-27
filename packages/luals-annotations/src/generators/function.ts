import { Docs } from "../json-docs";

function makeSignature(name: string, params: Docs.Property[]): string {
	return `function ${name}(${params.map((param) => param.name).join(",")}) end`;
}

export default function makeFunctionAnnotation(func: Docs.Function): string {
	let descriptionAnnotation = "";
	if (typeof func.description === "string") {
		descriptionAnnotation = `--- ${func.description}`;
	} else {
		descriptionAnnotation = func.description.map((descLine) => `--- ${descLine}`).join("\n");
	}

	const params = func.parameters ?? [];
	const returns = func.returns ?? [];
	const signature = makeSignature(func.name, params);
	//
	//
	// TODO: Add convertToLuaLS(type: string): string;
	// TODO: Reflect this in the tests, and also fix the signature being 1 line
	// TODO: away from the annotations.
	//
	//
	let paramAnnotation = params.map((param) => `---@param ${param.name} ${param.type}`).join("\n");
	let returnAnnotation = returns.map((ret) => `---@return ${ret.type} ${ret.name ?? ""}`).join("\n");

	const fullAnnotation = [descriptionAnnotation, paramAnnotation, returnAnnotation]
		.filter((annotation) => annotation.length > 0)
		.join("\n");

	if (!func.aliases) {
		return fullAnnotation + "\n" + signature;
	} else {
		return [func.name, ...func.aliases]
			.map((name) => fullAnnotation + "\n" + makeSignature(name, params))
			.join("\n");
	}
}
