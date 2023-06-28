export default function createDescriptionAnnotation(description: string | string[]) {
	let descriptionAnnotation = "";
	if (typeof description === "string") {
		descriptionAnnotation = `--- ${description}`;
	} else {
		descriptionAnnotation = description.map((descLine) => `--- ${descLine}`).join("\n");
	}

	return descriptionAnnotation;
}
