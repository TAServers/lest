import React from "react";
import Heading from "@theme/Heading";
import { useField, useMemberPrefix } from "./object";
import Description from "../Description";
import { renderType } from "../../helpers/renderers";
import { isFunctionProperty } from "../../doc-types";
import FunctionRenderer from "@site/src/components/FunctionRenderer";

interface FieldRendererProps {
	path: string;
	children: React.ReactNode;
}

export const FieldRenderer: React.FC<FieldRendererProps> = ({ path, children }) => {
	const memberPrefix = useMemberPrefix();
	const field = useField(path);

	const nameWithPrefix = `${memberPrefix}.${path}`;

	if (isFunctionProperty(field)) {
		return (
			<section>
				<FunctionRenderer {...field} headingLevel="h4" name={nameWithPrefix}>
					{children}
				</FunctionRenderer>
			</section>
		);
	}

	return (
		<section>
			<Heading as="h4" id={nameWithPrefix}>
				<code>
					{nameWithPrefix}
					{field.optional && "?"}: {renderType(field)}
				</code>
			</Heading>
			<Description text={field.description} />
			{children}
		</section>
	);
};
