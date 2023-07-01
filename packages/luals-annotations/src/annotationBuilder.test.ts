import AnnotationBuilder, { ClassBuilder } from "./annotationBuilder";

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
		const generatedAnnotations = document.build();

		// Assert
		expectedElements.forEach((element) => expect(generatedAnnotations).toContain(element));
	});

	it("should generate correct class annotations", () => {
		// Arrange
		const document = new AnnotationBuilder();
		const cls = new ClassBuilder({
			name: "test",
			description: "my class",
		});

		cls.addField({
			name: "test",
			type: "string",
			description: "test class description",
		});

		cls.addDeclaration();
		cls.addFunction({
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

		document.addClass(cls);

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
		const generatedAnnotations = document.build();

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
		const generatedAnnotations = document.build();

		// Assert
		expectedElements.forEach((element) => expect(generatedAnnotations).toContain(element));
	});

	it("should handle multi-line descriptions for fields properly", () => {
		// Arrange
		const document = new AnnotationBuilder();
		const cls = new ClassBuilder({
			name: "test",
			description: "my class",
		});

		cls.addField({
			name: "test",
			type: "string",
			description: ["Hello!", "World!"],
		});

		cls.addDeclaration();
		document.addClass(cls);

		const expectedElement = "---@field test string Hello! World!";

		// Act
		const generatedAnnotations = document.build();

		// Assert
		expect(generatedAnnotations).toContain(expectedElement);
	});

	it("should handle single line descriptions", () => {
		// Arrange
		const document = new AnnotationBuilder();
		document.addFunction({
			name: "test",
			description: "Hello!",
			parameters: [],
			returns: [],
		});

		const expectedElement = "--- Hello!";

		// Act
		const generatedAnnotations = document.build();

		// Assert
		expect(generatedAnnotations).toContain(expectedElement);
	});

	it("should handle static methods on classes", () => {
		// Arrange
		const document = new AnnotationBuilder();
		const cls = new ClassBuilder({
			name: "test",
			description: "static class",
		});

		cls.addDeclaration();
		cls.addFunction(
			{
				name: "test",
				description: "test function description",
				parameters: [
					{
						name: "a",
						type: "string",
					},
				],
			},
			true
		);

		document.addClass(cls);
		const expectedElement = "function test.test(a) end";

		// Act
		const generatedAnnotations = document.build();

		// Assert
		expect(generatedAnnotations).toContain(expectedElement);
	});

	it("should generate aliases of a function", () => {
		// Arrange
		const document = new AnnotationBuilder();
		document.addFunction({
			name: "test",
			description: "test function description",
			aliases: ["test2", "test3"],
			parameters: [
				{
					name: "a",
					type: "string",
				},
			],
		});

		const expectedElements = ["function test(a) end", "function test2(a) end", "function test3(a) end"];

		// Act
		const generatedAnnotations = document.build();

		// Assert
		expectedElements.forEach((element) => expect(generatedAnnotations).toContain(element));
	});
});
