import React from "react";
import Heading from "@theme/Heading";
import { Function } from "@lest/docs";
import { renderParameterSignature, renderReturnSignature } from "../../helpers/renderers";
import { Aliases } from "./components/Aliases";
import Description from "../Description";

interface FunctionRendererProps extends Function {
	headingLevel?: "h1" | "h2" | "h3" | "h4" | "h5";
	children: React.ReactNode;
}

export const FunctionRenderer: React.FC<FunctionRendererProps> = ({
	name,
	aliases,
	description,
	parameters = [],
	returns = [],
	headingLevel = "h3",
	children,
}) => (
	<section>
		<Heading as={headingLevel} id={name}>
			<code>
				{name}({parameters.length > 0 && renderParameterSignature(parameters)})
				{returns.length > 0 && `: ${renderReturnSignature(returns)}`}
			</code>
		</Heading>
		<Aliases aliases={aliases} />
		<Description text={description} />
		{children}
	</section>
);
