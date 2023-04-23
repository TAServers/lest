import { Named } from "./Named";
import { Value } from "./Value";

export interface Parameter extends Value, Named {
	name: string;
}
