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

function renderFunctionAliases(func: Function, staticMethod: boolean, className: string): string[] {
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

	// LuaLS has a very strict order about the function annotations, so this is why we have a specific order.
	// 1. Description
	// 2. Parameters
	// 3. Returns
	// 4. Function signature
	const descriptionLines = renderDescription(description);
	const paramList = renderParameterAnnotations(parameters);
	const returnList = renderReturnAnnotations(returns);
	const functionSignatures = renderFunctionAliases(func, staticMethod, className);

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
		this.addDescription(this.description);
	}

	addDescription(description: string[] | string | undefined) {
		const descriptionLines = Array.isArray(description) ? description : [description];
		descriptionLines.forEach((line) => line && this.add(`--- ${line}`));
	}

	addFunction(func: Function, staticMethod: boolean = false) {
		this.add(renderFunctionDeclaration(func, { staticMethod: staticMethod, className: this.name }));
	}

	addField(property: Property) {
		this.addDescription(property.description);
		this.add(`---@field ${formatProperty(property, " ")}`);
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
