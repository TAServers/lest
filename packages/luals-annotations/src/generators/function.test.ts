import makeFunctionAnnotation from "./function";
import * as mock_function_doc1 from "../tests/mock_function_doc1.json";
import * as mock_function_doc2 from "../tests/mock_function_doc2.json";

import { Docs } from "../json-docs";

describe("makeFunctionAnnotation", () => {
	test.each([
		[
			// Normal function with parameters, returns and no aliases.
			mock_function_doc1 as Docs.Function,
			[
				...mock_function_doc1.parameters.map((param) => `---@param ${param.name} ${param.type}`),
				...mock_function_doc1.returns.map((ret) => `---@return ${ret.type} ${ret.name}`),
				`function ${mock_function_doc1.name}`,
			],
		],
		[
			// Aliased function with no returns, and a variadic argument.
			mock_function_doc2 as Docs.Function,
			[
				...mock_function_doc2.parameters.map((param) => `---@param ${param.name} ${param.type}`),
				`function ${mock_function_doc2.name}`,
				`function ${mock_function_doc2.aliases[0]}`,
			],
		],
	])(
		"should create correct annotations given a documentation input (test case %#)",
		(docFunction, requiredElements) => {
			// Act
			const annotation = makeFunctionAnnotation(docFunction);

			// Assert
			for (const element of requiredElements) {
				expect(annotation).toContain(element);
			}
		}
	);
});
