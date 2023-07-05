import React, { createContext, useContext } from "react";
import Heading from "@theme/Heading";
import Description from "../Description";
import { Class } from "@lest/docs";
import { isTableProperty, Property } from "@lest/docs";

interface ObjectContextProps {
	object?: Class;
	memberPrefix: string;
}

const ObjectContext = createContext<ObjectContextProps>({ object: undefined, memberPrefix: "" });

const useObject = (): Class => {
	const { object } = useContext(ObjectContext);

	if (!object) {
		throw new Error("ObjectContextProvider must have an object defined");
	}

	return object;
};

export const useField = (path: string): Property => {
	const object = useObject();
	const segments = path.split(".");

	let field: Property = { ...object, type: "table" };

	while (segments.length > 0) {
		const fieldName = segments.shift() as string;

		if (isTableProperty(field)) {
			const newField = field.fields.find(({ name }) => name === fieldName);
			if (!newField) {
				throw new Error(`Invalid path ${path}`);
			}

			field = newField;
		} else {
			throw new Error(`Invalid path ${path}, no such nested field`);
		}
	}

	return field;
};

export const useMemberPrefix = (): string => useContext(ObjectContext).memberPrefix;

interface ObjectRendererProps extends Class {
	memberPrefix: string;
	children: React.ReactNode;
}

export const ObjectRenderer: React.FC<ObjectRendererProps> = ({
	memberPrefix,
	name,
	description,
	children,
	...rest
}) => {
	return (
		<ObjectContext.Provider value={{ memberPrefix, object: { name, description, ...rest } }}>
			<section>
				<Heading as="h2" id={name}>
					<code>{name}</code>
				</Heading>
				<Description text={description} />
				{children}
			</section>
		</ObjectContext.Provider>
	);
};
