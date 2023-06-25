import React from "react";
import Heading from "@theme/Heading";
import Markdown from "markdown-to-jsx";
import { Function } from "../../doc-types";
import { renderParameterSignature, renderReturnSignature } from "./helpers";
import { Aliases } from "@site/src/components/FunctionRenderer/components/Aliases";

interface FunctionRendererProps extends Function {
	children: React.ReactNode;
}

export const FunctionRenderer: React.FC<FunctionRendererProps> = ({
	name,
	aliases,
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
			<Aliases aliases={aliases} />
			<Markdown options={{ forceBlock: true }}>{description}</Markdown>
			{children}
		</section>
	);
};
