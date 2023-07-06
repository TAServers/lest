import { Property } from "./property";

export interface Function {
	name: string;
	aliases?: string[];
	description?: string | string[];
	parameters?: Property[];
	returns?: Property[];
}
