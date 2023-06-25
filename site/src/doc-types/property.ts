export interface Property {
	type: string;
	name?: string;
	description?: string | string[];
	optional?: boolean;
}

export interface FunctionProperty extends Property {
	type: "function";
	static?: boolean;
	parameters?: Property[];
	returns?: Property[];
}

export type ArrayItems = string | { type: "array"; items: ArrayItems };

export interface ArrayProperty extends Property {
	type: "array";
	items: ArrayItems;
}

export interface TableProperty extends Property {
	type: "table";
	fields: Property[];
}

export const isFunctionProperty = (prop: Property): prop is FunctionProperty => prop.type === "function";

export const isArrayProperty = (prop: Property): prop is ArrayProperty => prop.type === "array";

export const isTableProperty = (prop: Property): prop is TableProperty => prop.type === "table";
