import AnnotationBuilder from "./annotationBuilder";

describe("annotationBuilder", () => {
	it("should generate correct function annotations", () => {
		// Arrange
		const document = new AnnotationBuilder();
		document.addFunction({
			name: "test",
			description: "test description",
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
		});

		const expectedElements = [
			"---@param a string",
			"---@return number b",
			"function test(a) end",
			"test description",
		];

		// Act
		const generatedAnnotations = document.toString();

		// Assert
		expectedElements.forEach((element) => expect(generatedAnnotations).toContain(element));
	});

	it("should generate correct class annotations", () => {
		// Arrange
		const document = new AnnotationBuilder();
		document.withClass("test", "my class", false, () => {
			document.addField({
				name: "test",
				type: "string",
				description: "test class description",
			});

			document.addClassDeclaration();

			document.addFunction({
				name: "test",
				description: "test function description",
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
			});
		});

		const expectedElements = [
			"---@class test",
			"my class",
			"---@field test string",
			"test class description",
			"test = {}",
			"---@param a string",
			"---@return number b",
			"function test:test(a) end",
			"test function description",
		];

		// Act
		const generatedAnnotations = document.toString();

		// Assert
		expectedElements.forEach((element) => expect(generatedAnnotations).toContain(element));
	});

	it("should handle multi-line descriptions", () => {
		// Arrange
		const document = new AnnotationBuilder();
		document.addFunction({
			name: "test",
			description: ["Hello!", "World!"],
			parameters: [
				{
					name: "a",
					type: "string",
				},
			],
		});

		const expectedElements = ["---@param a string", "--- Hello!", "--- World!", "function test(a) end"];

		// Act
		const generatedAnnotations = document.toString();

		// Assert
		expectedElements.forEach((element) => expect(generatedAnnotations).toContain(element));
	});

	it("should handle multi-line descriptions for fields properly", () => {
		// Arrange
		const document = new AnnotationBuilder();
		document.withClass("test", "e", false, () => {
			document.addField({
				name: "test",
				type: "string",
				description: ["Hello!", "World!"],
			});

			document.addClassDeclaration();
		});

		const expectedElement = "---@field test string Hello! World!";

		// Act
		const generatedAnnotations = document.toString();

		// Assert
		expect(generatedAnnotations).toContain(expectedElement);
	});

	it("should handle static methods on classes", () => {
		// Arrange
		const document = new AnnotationBuilder();
		document.withClass("test", "static class", true, () => {
			document.addFunction({
				name: "test",
				description: "test function description",
				parameters: [
					{
						name: "a",
						type: "string",
					},
				],
			});

			document.addClassDeclaration();
		});

		const expectedElement = "function test.test(a) end";

		// Act
		const generatedAnnotations = document.toString();

		// Assert
		expect(generatedAnnotations).toContain(expectedElement);
	});

	describe("should error", () => {
		test("on creating a class declaration without a current class", () => {
			const document = new AnnotationBuilder();
			expect(() => document.addClassDeclaration()).toThrowError();
		});

		test("on making a field without a current class", () => {
			const document = new AnnotationBuilder();
			expect(() => document.addField({ name: "test", type: "string" })).toThrowError();
		});
	});
});
