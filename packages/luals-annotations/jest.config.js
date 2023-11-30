/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
	preset: "ts-jest",
	testEnvironment: "node",
	testMatch: ["**/*.test.ts"],
	collectCoverage: true,
	collectCoverageFrom: ["src/**/{!(index),}.ts"],
	coverageThreshold: {
		global: {
			lines: 100,
			branches: 100,
			functions: 100,
			statements: 100,
		},
	},
};
