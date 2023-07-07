import luaLSType from "./luaLSType";
import { Function, Property } from "@lest/docs";

type FunctionRenderOptions = {
	staticMethod?: boolean;
	className?: string;
};

function renderFunctionDeclaration(func: Function, { staticMethod, className }: FunctionRenderOptions = {}): string {
	const params = func.parameters ?? [];
	const returns = func.returns ?? [];

	const paramList = params.map((param) => `---@param ${param.name}${param.optional ? "?" : ""} ${luaLSType(param)}`);
	const returnList = returns.map((ret) => `---@return ${luaLSType(ret)} ${ret.name ?? ""}`);

	const functionCharacter = staticMethod ? "." : ":";
	const functionPrefix = className ? `${className}${functionCharacter}` : "";

	const functionNames = [func.name, ...(func.aliases ?? [])];

	const annotations = functionNames.map((name) => {
		const signature = `function ${functionPrefix}${name}(${params.map((param) => param.name)}) end`;
		const description = Array.isArray(func.description) ? func.description : [func.description];

		return [...description.map((line) => `--- ${line}`), ...paramList, ...returnList, signature].join("\n");
	});

	return annotations.join("\n");
}

export class DocumentBuilder {
	lines: string[] = [];

	add(line: string) {
		this.lines.push(line);
	}

	build(): string {
		return this.lines.join("\n");
	}

	buildToLines(): string[] {
		return this.lines;
	}
}

type ClassOptions = {
	name: string;
	description?: string | string[];
};

export class ClassBuilder extends DocumentBuilder {
	name: string;
	description?: string | string[];

	constructor(options: ClassOptions) {
		super();

		this.name = options.name;
		this.description = options.description;

		this.add(`---@class ${this.name}`);
		this.addDescription(this.description);
	}

	addComment(comment: string) {
		this.add(`--- ${comment}`);
	}

	addDescription(description: string | string[] | undefined) {
		if (!description) return;
		(Array.isArray(description) ? description : [description]).forEach((line) => this.addComment(line));
	}

	addFunction(func: Function, staticMethod: boolean = false) {
		this.add(renderFunctionDeclaration(func, { staticMethod: staticMethod, className: this.name }));
	}

	addField(property: Property) {
		// LuaLS has no support for multi line field descriptions, so that is why we join them with a space
		const description = Array.isArray(property.description) ? property.description.join(" ") : property.description;
		this.add(`---@field ${property.name} ${luaLSType(property)} ${description}`);
	}

	addDeclaration() {
		this.add(`${this.name} = {}`);
	}
}

export default class AnnotationBuilder extends DocumentBuilder {
	constructor() {
		super();
		this.add("---@meta");
	}

	addFunction(func: Function) {
		this.add(renderFunctionDeclaration(func));
	}

	addClass(cls: ClassBuilder) {
		cls.buildToLines().forEach((line) => this.add(line));
	}
}
