import { Docs } from "@/json-docs";

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

	let paramAnnotation = params.map((param) => `---@param ${param.name} ${param.type}`).join("\n");
	let returnAnnotation = returns.map((ret) => `---@return ${ret.type} ${ret.name ?? ""}`).join("\n");

	if (!func.aliases) {
		return [descriptionAnnotation, paramAnnotation, returnAnnotation, signature].join("\n");
	} else {
		return [func.name, ...func.aliases]
			.map((name) =>
				[descriptionAnnotation, paramAnnotation, returnAnnotation, makeSignature(name, params)].join("\n")
			)
			.join("\n\n");
	}
}
