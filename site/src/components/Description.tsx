import React from "react";
import Markdown from "markdown-to-jsx";

interface DescriptionProps {
	text?: string | string[];
}

const Description: React.FC<DescriptionProps> = ({ text = "No description provided." }) => {
	if (text instanceof Array) {
		text = text.join("\n");
	}

	return <Markdown options={{ forceBlock: true }}>{text}</Markdown>;
};

export default Description;
