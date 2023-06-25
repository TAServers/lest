import { Property } from "@site/src/doc-types/property";

export interface Function {
	name: string;
	description?: string | string[];
	parameters?: Property[];
	returns?: Property[];
}
