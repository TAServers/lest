import { Docs } from "../json-docs";
import makeClassAnnotation from "./class";

describe("makeClassAnnotation", () => {
	const testClass: Docs.Class = {
		name: "test",
		description: "test",
		fields: [
			{
				name: "test",
				description: "test",
				type: "string",
			},
		],
		methods: [
			{
				name: "test",
				description: "test",
				returns: [
					{
						name: "test",
						type: "string",
					},
				],
			},
		],
	};

	it("should create a lua table", () => {
		// Act
		const result = makeClassAnnotation(testClass);

		// Assert
		expect(result).toContain(`${testClass.name} = {}`);
	});

	it("should have a class annotation", () => {
		// Act
		const result = makeClassAnnotation(testClass);

		// Assert
		expect(result).toContain(`---@class ${testClass.name}`);
	});

	it("should generate the field annotations", () => {
		// Act
		const result = makeClassAnnotation(testClass);

		// Assert
		testClass.fields.forEach((field) => {
			expect(result).toContain(`---@field ${field.name}`);
		});
	});

	it("should generate the method annotations", () => {
		// Act
		const result = makeClassAnnotation(testClass);

		// Assert
		testClass.methods.forEach((method) => {
			expect(result).toContain(`function ${testClass.name}:${method.name}`);
		});
	});
});
