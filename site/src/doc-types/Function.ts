import { Described } from "./Described";
import { Named } from "./Named";
import { Parameter } from "./Parameter";
import { Return } from "./Return";

export interface Function extends Named, Described {
	parameters?: Parameter[];
	returns?: Return[];
}
