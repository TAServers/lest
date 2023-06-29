/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
	preset: "ts-jest",
	testEnvironment: "node",
	testMatch: ["**/*.test.ts"],
	collectCoverage: true,
	collectCoverageFrom: ["src/**/{!(index),}.ts"],
	coverageThreshold: {
		global: {
			lines: 85,
			branches: 75,
			functions: 90,
			statements: 85,
		},
	},
};
