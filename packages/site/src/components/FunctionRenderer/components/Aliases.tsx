import React from "react";

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

	const lastAlias = aliases.pop();

	return (
		<p>
			Also under the aliases:{" "}
			{aliases.map((alias, index) => (
				<React.Fragment key={index}>
					<code>{alias}</code>,{" "}
				</React.Fragment>
			))}{" "}
			and <code>{lastAlias}</code>
		</p>
	);
};
