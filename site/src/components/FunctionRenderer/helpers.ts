import { FunctionProperty, ArrayProperty, Property, isFunctionProperty, isArrayProperty } from "../../doc-types";

const renderFunctionType = ({ parameters = [], returns = [] }: FunctionProperty) => {
	const paramSignature = parameters.length > 0 ? renderParameterSignature(parameters) : "";
	const returnSignature = returns.length > 0 ? `: ${renderReturnSignature(returns)}` : "";

	return `fun(${paramSignature})${returnSignature}`;
};

const renderArrayType = ({ items }: ArrayProperty) => `${items}[]`;

const renderType = (parameter: Property): string => {
	if (isFunctionProperty(parameter)) {
		return renderFunctionType(parameter);
	}

	if (isArrayProperty(parameter)) {
		return renderArrayType(parameter);
	}

	return parameter.type;
};

export const renderParameterSignature = (parameters: Property[]) =>
	parameters
		.map((parameter) => `${parameter.name}${parameter.optional ? "?" : ""}: ${renderType(parameter)}`)
		.join(", ");

export const renderReturnSignature = (returns: Property[]) =>
	returns.map((value) => `${renderType(value)}${value.optional ? "?" : ""}`).join(", ");
