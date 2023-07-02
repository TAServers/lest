import React from "react";
import Markdown from "markdown-to-jsx";

interface AliasesProps {
	aliases?: string[];
}

export const Aliases: React.FC<AliasesProps> = ({ aliases }) => {
	if (!aliases || aliases.length <= 0) {
		return null;
	}

	if (aliases.length === 1) {
		return (
			<p>
				Also under the alias <code>{aliases[0]}</code>.
			</p>
		);
	}

	const formattedAliases = aliases.map((alias) => `\`${alias}\``);

	return (
		<Markdown options={{ forceBlock: true }}>
			{`Also under the aliases: ${formattedAliases.slice(0, -1).join(", ")} and ${formattedAliases.at(-1)}.`}
		</Markdown>
	);
};
