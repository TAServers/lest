import luaLSType from "./luaLSType";
import { Docs } from "./json-docs";

describe("luaLSType", () => {
	it("should handle untyped arrays", () => {
		// Arrange
		const testProperty: Docs.ArrayProperty = {
			name: "test",
			type: "array",
			items: "any",
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual("any[]");
	});

	it("should handle typed arrays", () => {
		// Arrange
		const testProperty: Docs.ArrayProperty = {
			name: "test",
			type: "array",
			items: "lest.MockResult",
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual("lest.MockResult[]");
	});

	it("should handle untyped arrays of arrays", () => {
		// Arrange
		const testProperty: Docs.ArrayProperty = {
			name: "test",
			type: "array",
			items: {
				type: "array",
				items: "any",
			},
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual("any[][]");
	});

	it("should handle specified function types", () => {
		// Arrange
		const testProperty: Docs.FunctionProperty = {
			name: "test",
			type: "function",
			parameters: [
				{
					name: "a",
					type: "string",
				},
			],
			returns: [
				{
					name: "b",
					type: "number",
				},
			],
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual("fun(a:string):number");
	});

	it("should handle unspecified function types", () => {
		// Arrange
		const testProperty: Docs.Property = {
			name: "test",
			type: "function",
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual("fun()");
	});

	it("should handle functions with no returns", () => {
		// Arrange
		const testProperty: Docs.FunctionProperty = {
			name: "test",
			type: "function",
			parameters: [
				{
					name: "a",
					type: "string",
				},
			],
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual("fun(a:string)");
	});

	it("should handle functions with optional parameters", () => {
		// Arrange
		const testProperty: Docs.FunctionProperty = {
			name: "test",
			type: "function",
			parameters: [
				{
					name: "a",
					type: "string",
				},
				{
					name: "b",
					type: "string",
					optional: true,
				},
			],
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual("fun(a:string,b?:string)");
	});

	it("should handle multiple string literal types", () => {
		// These are actually valid in LuaLS. So we don't need to do anything special.
		// Arrange
		const testProperty: Docs.Property = {
			name: "test",
			type: '"test" | "test2"',
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual('"test" | "test2"');
	});

	it("should handle tables", () => {
		// Arrange
		const testProperty: Docs.TableProperty = {
			name: "test",
			type: "table",
			fields: [
				{
					name: "foo",
					type: "string",
				},
				{
					name: "bar",
					type: "number",
				},
				{
					name: "baz",
					type: "boolean",
				},
				{
					name: "qux",
					type: "function",
					parameters: [
						{
							name: "a",
							type: "string",
						},
					],
					returns: [
						{
							name: "b",
							type: "number",
						},
					],
				} as Docs.FunctionProperty,
			],
		};

		// Act
		const generatedType = luaLSType(testProperty);

		// Assert
		expect(generatedType).toEqual("{foo:string,bar:number,baz:boolean,qux:fun(a:string):number}");
	});
});
