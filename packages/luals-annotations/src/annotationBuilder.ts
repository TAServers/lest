import luaLSType, { formatProperty } from "./luaLSType";
import { Function, Property } from "@lest/docs";

type FunctionRenderOptions = {
	staticMethod?: boolean;
	className?: string;
};

function renderParameterAnnotations(parameters: Property[]): string[] {
	return parameters.map((param) => `---@param ${formatProperty(param, " ")}`);
}

function renderReturnAnnotations(returns: Property[]): string[] {
	return returns.map((ret) => `---@return ${luaLSType(ret)} ${ret.name ?? ""}`);
}

function renderFunctionSignature(func: Function, staticMethod: boolean, className: string): string[] {
	const { parameters = [] } = func;

	const functionCharacter = staticMethod ? "." : ":";
	const functionPrefix = className ? `${className}${functionCharacter}` : "";

	const functionNames = [func.name, ...(func.aliases ?? [])];

	return functionNames.map(
		(name) => `function ${functionPrefix}${name}(${parameters.map((param) => param.name)}) end`
	);
}

function renderDescription(description: string | string[]): string[] {
	const descriptionLines = Array.isArray(description) ? description : [description];
	return descriptionLines.map((line) => `--- ${line}`);
}

function renderFunctionDeclaration(
	func: Function,
	{ staticMethod = false, className = "" }: FunctionRenderOptions = {}
): string {
	const { parameters = [], returns = [], description = [] } = func;

	const descriptionLines = renderDescription(description);
	const paramList = renderParameterAnnotations(parameters);
	const returnList = renderReturnAnnotations(returns);
	const functionSignatures = renderFunctionSignature(func, staticMethod, className);

	return functionSignatures
		.map((signature) => [...descriptionLines, ...paramList, ...returnList, signature].join("\n"))
		.join("\n");
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

		this.addClassAnnotations();
	}

	addClassAnnotations() {
		this.add(`---@class ${this.name}`);
		(Array.isArray(this.description) ? this.description : [this.description]).forEach(
			(line) => line && this.add(`--- ${line}`)
		);
	}

	addFunction(func: Function, staticMethod: boolean = false) {
		this.add(renderFunctionDeclaration(func, { staticMethod: staticMethod, className: this.name }));
	}

	addField(property: Property) {
		// LuaLS has no support for multi line field descriptions, so that is why we join them with a space
		const description = Array.isArray(property.description) ? property.description.join(" ") : property.description;
		this.add(`---@field ${formatProperty(property, " ")} ${description}`);
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
