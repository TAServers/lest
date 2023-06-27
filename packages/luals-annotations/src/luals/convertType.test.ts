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
});
