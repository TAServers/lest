import {
	FunctionProperty,
	ArrayProperty,
	TableProperty,
	isArrayProperty,
	isFunctionProperty,
	isTableProperty,
	Property,
} from "@lest/docs";

export function formatListProperty(property: Property): string {
	return formatProperty(property, " ");
}

function formatProperty({ name, optional, ...props }: Property, typeSeparator = ":"): string {
	return `${name}${optional ? "?" : ""}${typeSeparator}${luaLSType({ name, optional, ...props })}`;
}

function convertFunctionProperty({ parameters = [], returns = [] }: FunctionProperty): string {
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
