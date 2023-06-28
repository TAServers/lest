import { Docs } from "./json-docs";

function convertFunctionProperty(property: Docs.FunctionProperty): string {
	if (!property.parameters && !property.returns) {
		return "fun()";
	}

	const params = property.parameters ?? [];
	const returns = property.returns ?? [];

	const paramList = params.map((param) => `${param.name}${(param.optional && "?") || ""}:${luaLSType(param)}`);
	const returnList = returns.map((ret) => `${luaLSType(ret)}`);

	if (returnList.length === 0) {
		return `fun(${paramList})`;
	}

	return `fun(${paramList}):${returnList}`;
}

function convertArrayProperty(property: Docs.ArrayProperty) {
	if (typeof property.items === "string") {
		return `${property.items}[]`;
	} else {
		return `${luaLSType(property.items)}[]`;
	}
}

function convertTableProperty(property: Docs.TableProperty) {
	return `{${property.fields.map((field) => `${field.name}:${luaLSType(field)}`).join(",")}}`;
}

export default function luaLSType(docType: Docs.Property): string {
	switch (docType.type) {
		case "function":
			return convertFunctionProperty(docType as Docs.FunctionProperty);
		case "array":
			return convertArrayProperty(docType as Docs.ArrayProperty);
		case "table":
			return convertTableProperty(docType as Docs.TableProperty);
		default:
			return docType.type;
	}
}