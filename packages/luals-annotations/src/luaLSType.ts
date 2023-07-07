import {
	FunctionProperty,
	ArrayProperty,
	TableProperty,
	isArrayProperty,
	isFunctionProperty,
	isTableProperty,
	Property,
} from "@lest/docs";

export function formatProperty(param: Property, typeSeparator = ":"): string {
	const { name, optional } = param;
	return `${name}${optional ? "?" : ""}${typeSeparator}${luaLSType(param)}`;
}

function convertFunctionProperty(property: FunctionProperty): string {
	const { parameters = [], returns = [] } = property;

	const paramList = parameters.map((param) => formatProperty(param));
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

	return `{${property.fields.map((field) => formatProperty(field)).join(",")}}`;
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
