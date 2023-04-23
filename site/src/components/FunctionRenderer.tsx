import React from "react";
import { Parameter, Return, Function } from "../doc-types";

const renderParameterSignature = (parameters: Parameter[]) =>
	parameters.map(({ name, type, optional }) => `${name}${optional ? "?" : ""}: ${type}`).join(", ");

const renderReturnSignature = (returns: Return[]) =>
	returns.map(({ type, optional }) => `${type}${optional ? "?" : ""}`).join(", ");

interface FunctionRendererProps extends Function {
	children: JSX.Element;
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
		<>
			<h3>
				<code>
					{name}({renderParameterSignature(parameters)})
					{returns.length > 0 && `: ${renderReturnSignature(returns)}`}
				</code>
			</h3>
			<p>{description}</p>
			{children}
		</>
	);
};

export default FunctionRenderer;
