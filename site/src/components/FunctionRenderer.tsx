import React from "react";
import Heading from "@theme/Heading";
import Markdown from "markdown-to-jsx";
import { Function, Property, FunctionProperty, ArrayProperty, isFunctionProperty, isArrayProperty } from "../doc-types";

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

const renderParameterSignature = (parameters: Property[]) =>
	parameters
		.map((parameter) => `${parameter.name}${parameter.optional ? "?" : ""}: ${renderType(parameter)}`)
		.join(", ");

const renderReturnSignature = (returns: Property[]) =>
	returns.map((value) => `${renderType(value)}${value.optional ? "?" : ""}`).join(", ");

interface FunctionRendererProps extends Function {
	children: React.ReactNode;
}

const FunctionRenderer: React.FC<FunctionRendererProps> = ({
	name,
	description = "No description provided.",
	parameters = [],
	returns = [],
	children,
}) => {
	if (description instanceof Array) {
		description = description.join("\n");
	}

	return (
		<section>
			<Heading as="h3" id={name}>
				<code>
					{name}({parameters.length > 0 && renderParameterSignature(parameters)})
					{returns.length > 0 && `: ${renderReturnSignature(returns)}`}
				</code>
			</Heading>
			<Markdown options={{ forceBlock: true }}>{description}</Markdown>
			{children}
		</section>
	);
};

export default FunctionRenderer;
