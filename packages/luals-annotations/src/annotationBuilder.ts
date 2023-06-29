import { Docs } from "./json-docs";
import luaLSType from "./luaLSType";

export default class AnnotationBuilder {
	generatedAnnotations: string[] = [];

	currentClass: string = "";
	staticMethod: boolean = false;

	constructor() {}

	add(...lines: string[]) {
		this.generatedAnnotations.push(...lines);
	}

	addComment(comment: string) {
		this.add(`--- ${comment}`);
	}

	addDescription(description: string | string[]) {
		if (typeof description === "string") {
			this.addComment(description);
		} else {
			description.forEach((line) => this.addComment(line));
		}
	}

	addFunction(func: Docs.Function) {
		const params = func.parameters ?? [];
		const returns = func.returns ?? [];

		const paramList = params.map(
			(param) => `---@param ${param.name}${(param.optional && "?") || ""} ${luaLSType(param)}`
		);
		const returnList = returns.map((ret) => `---@return ${luaLSType(ret)} ${ret.name ?? ""}`);

		const functionCharacter = this.staticMethod ? "." : ":";
		const functionPrefix = this.currentClass ? `${this.currentClass}${functionCharacter}` : "";

		const renderFunction = (signature: string) => {
			this.addDescription(func.description);
			this.add(...paramList, ...returnList, signature);
		};

		if (func.aliases) {
			func.aliases.forEach((alias) => {
				const signature = `function ${functionPrefix}${alias}(${params.map((param) => param.name)}) end`;
				renderFunction(signature);
			});
		}

		const signature = `function ${functionPrefix}${func.name}(${params.map((param) => param.name)}) end`;
		renderFunction(signature);
	}

	addClassDeclaration() {
		if (!this.currentClass) {
			throw new Error("Cannot add class declaration without a class");
		}

		this.add(`${this.currentClass} = {}`);
	}

	addField(property: Docs.Property) {
		if (!this.currentClass) {
			throw new Error("Cannot add field without a class");
		}

		let description = property.description;
		if (typeof description !== "string") {
			// Unfortunately, we can't really have multi-line descriptions for fields
			description = description.join(" ");
		}

		this.add(`---@field ${property.name} ${luaLSType(property)} ${description}`);
	}

	private startClass(name: string, description: string | string[], staticMethod: boolean = false) {
		this.currentClass = name;
		this.staticMethod = staticMethod;

		this.add(`---@class ${name}`);
		this.addDescription(description);
	}

	private endClass() {
		this.currentClass = "";
		this.staticMethod = false;
	}

	withClass(name: string, description: string | string[], staticMethod: boolean, classFn: () => void) {
		this.startClass(name, description, staticMethod);
		classFn();
		this.endClass();
	}

	build(): string {
		return this.generatedAnnotations.join("\n");
	}

	toString(): string {
		return this.build();
	}
}
