import {
	FunctionProperty,
	ArrayProperty,
	TableProperty,
	isArrayProperty,
	isFunctionProperty,
	isTableProperty,
	Property,
} from "@lest/docs";

function convertFunctionProperty(property: FunctionProperty): string {
	const params = property.parameters ?? [];
	const returns = property.returns ?? [];

	const paramList = params.map((param) => `${param.name}${(param.optional && "?") || ""}:${luaLSType(param)}`);
	const returnList = returns.map((ret) => luaLSType(ret));

	if (returnList.length === 0) {
		return `fun(${paramList})`;
	}

	return `fun(${paramList}):${returnList}`;
}

function convertArrayProperty(property: ArrayProperty) {
	if (typeof property.items === "string") {
		return `${property.items}[]`;
	} else {
		return `${luaLSType(property.items)}[]`;
	}
}

function convertTableProperty(property: TableProperty) {
	if (!property.fields) {
		return "table";
	}

	return `{${property.fields.map((field) => `${field.name}:${luaLSType(field)}`).join(",")}}`;
}

export default function luaLSType(docType: Property): string {
	if (isFunctionProperty(docType)) {
		return convertFunctionProperty(docType);
	}

	if (isArrayProperty(docType)) {
		return convertArrayProperty(docType);
	}

	if (isTableProperty(docType)) {
		return convertTableProperty(docType);
	}

	return docType.type;
}
