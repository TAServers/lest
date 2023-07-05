import { Property } from "./property";
import { Function } from "./function";
export interface Class {
	name: string;
	description?: string | string[];
	fields?: Property[];
	methods?: Function[];
}
