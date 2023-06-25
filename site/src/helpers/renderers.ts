import { FunctionProperty, Property, isFunctionProperty, isArrayProperty, ArrayItems } from "../doc-types";

const renderFunctionType = ({ parameters = [], returns = [] }: FunctionProperty) => {
	const paramSignature = parameters.length > 0 ? renderParameterSignature(parameters) : "";
	const returnSignature = returns.length > 0 ? `: ${renderReturnSignature(returns)}` : "";

	return `fun(${paramSignature})${returnSignature}`;
};

const renderArrayType = (items: ArrayItems): string => {
	let arrayBrackets = "[]";
	while (typeof items === "object") {
		arrayBrackets += "[]";
		items = items.items;
	}

	return `${items}${arrayBrackets}`;
};

export const renderType = (property: Property): string => {
	if (isFunctionProperty(property)) {
		return renderFunctionType(property);
	}

	if (isArrayProperty(property)) {
		return renderArrayType(property.items);
	}

	return property.type;
};

export const renderParameterSignature = (parameters: Property[]) =>
	parameters
		.map((parameter) => `${parameter.name}${parameter.optional ? "?" : ""}: ${renderType(parameter)}`)
		.join(", ");

export const renderReturnSignature = (returns: Property[]) =>
	returns.map((value) => `${renderType(value)}${value.optional ? "?" : ""}`).join(", ");
