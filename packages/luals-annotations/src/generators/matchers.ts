import { Docs, matcherFunctions } from "../json-docs";

export default function makeMatcherClass(): Docs.Class {
	const matcherProperties: Docs.FunctionProperty[] = [];
	matcherFunctions.forEach((func) => {
		function addMatcherProperty(name: string) {
			matcherProperties.push({
				name,
				type: "function",
				description: func.description,
				parameters: func.parameters,
				returns: func.returns,
			});
		}

		addMatcherProperty(func.name);
		if (func.aliases) {
			func.aliases.forEach(addMatcherProperty);
		}
	});

	return {
		name: "lest.Matchers",
		description: "Matchers for expect()",
		methods: matcherFunctions,
	};
}
