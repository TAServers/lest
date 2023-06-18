import React from "react";
import Heading from "@theme/Heading";
import Markdown from "markdown-to-jsx";
import { Parameter, Return, Function } from "../doc-types";

const renderParameterSignature = (parameters: Parameter[]) =>
	parameters.map(({ name, type, optional }) => `${name}${optional ? "?" : ""}: ${type}`).join(", ");

const renderReturnSignature = (returns: Return[]) =>
	returns.map(({ type, optional }) => `${type}${optional ? "?" : ""}`).join(", ");

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
			<Heading as="h3">
				<code>
					{name}({renderParameterSignature(parameters)})
					{returns.length > 0 && `: ${renderReturnSignature(returns)}`}
				</code>
			</Heading>
			<Markdown options={{ forceBlock: true }}>{description}</Markdown>
			{children}
		</section>
	);
};

export default FunctionRenderer;
