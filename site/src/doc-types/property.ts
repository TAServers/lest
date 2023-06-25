export interface Property {
	type: string;
	name?: string;
	description?: string | string[];
	optional?: boolean;
}

export interface FunctionProperty extends Property {
	type: "function";
	parameters?: Property[];
	returns?: Property[];
}

export interface ArrayProperty extends Property {
	type: "array";
	items: string;
}

export const isFunctionProperty = (prop: Property): prop is FunctionProperty => prop.type === "function";

export const isArrayProperty = (prop: Property): prop is ArrayProperty => prop.type === "array";
