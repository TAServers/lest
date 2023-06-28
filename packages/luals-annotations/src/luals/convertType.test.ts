import convertType from "./convertType";
import { Docs } from "../json-docs";

describe("convertType", () => {
	it("should handle untyped arrays", () => {
		// Arrange
		const testProperty: Docs.ArrayProperty = {
			name: "test",
			type: "array",
			items: "any",
		};

		// Act
		const luaLSType = convertType(testProperty);

		// Assert
		expect(luaLSType).toEqual("any[]");
	});

	it("should handle typed arrays", () => {
		// Arrange
		const testProperty: Docs.ArrayProperty = {
			name: "test",
			type: "array",
			items: "lest.MockResult",
		};

		// Act
		const luaLSType = convertType(testProperty);

		// Assert
		expect(luaLSType).toEqual("lest.MockResult[]");
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
		const luaLSType = convertType(testProperty);

		// Assert
		expect(luaLSType).toEqual("any[][]");
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
		const luaLSType = convertType(testProperty);

		// Assert
		expect(luaLSType).toEqual("fun(a:string):number");
	});

	it("should handle unspecified function types", () => {
		// Arrange
		const testProperty: Docs.Property = {
			name: "test",
			type: "function",
		};

		// Act
		const luaLSType = convertType(testProperty);

		// Assert
		expect(luaLSType).toEqual("fun()");
	});

	it("should handle multiple string literal types", () => {
		// These are actually valid in LuaLS. So we don't need to do anything special.
		// Arrange
		const testProperty: Docs.Property = {
			name: "test",
			type: '"test" | "test2"',
		};

		// Act
		const luaLSType = convertType(testProperty);

		// Assert
		expect(luaLSType).toEqual('"test" | "test2"');
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
		const luaLSType = convertType(testProperty);

		// Assert
		expect(luaLSType).toEqual("{foo:string,bar:number,baz:boolean,qux:fun(a:string):number}");
	});
});
