import React from "react";
import { Function } from "@lest/docs";
import FunctionRenderer from "./FunctionRenderer";

interface MatcherRendererProps extends Function {
	children: React.ReactNode;
}

const MatcherRenderer: React.FC<MatcherRendererProps> = ({ children, name, ...rest }) => (
	<FunctionRenderer {...rest} name={`.${name}`}>
		{children}
	</FunctionRenderer>
);

export default MatcherRenderer;
