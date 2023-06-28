export default function combine(...annotations: string[]): string {
	return annotations.filter((annotation) => annotation.length > 0).join("\n");
}
