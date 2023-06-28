import { Docs } from "../json-docs";

export default function convertType(docType: Docs.Property): string {
	if (Docs.isFunctionProperty(docType)) {
		if (!docType.parameters && !docType.returns) {
			return "function";
		}

		const params = docType.parameters ?? [];
		const returns = docType.returns ?? [];
		const paramList = params
			.map((param) => `${param.name}${(param.optional && "?") || ""}:${convertType(param)}`)
			.join(",");
		const returnList = returns.map((ret) => `${convertType(ret)}`).join(",");

		if (returnList.length === 0) {
			return `fun(${paramList})`;
		}

		return `fun(${paramList}):${returnList}`;
	} else if (Docs.isArrayProperty(docType)) {
		if (typeof docType.items === "string") {
			return `${docType.items}[]`;
		} else {
			return `${convertType(docType.items)}[]`;
		}
	} else if (Docs.isTableProperty(docType)) {
		return `{${docType.fields.map((field) => `${field.name}:${convertType(field)}`).join(",")}}`;
	}

	return docType.type;
}
