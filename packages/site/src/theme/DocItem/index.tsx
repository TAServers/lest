import React, { useEffect, useState } from "react";
import { HtmlClassNameProvider } from "@docusaurus/theme-common";
import { DocProvider } from "@docusaurus/theme-common/internal";
import DocItemMetadata from "@theme/DocItem/Metadata";
import DocItemLayout from "@theme/DocItem/Layout";
import type { Props } from "@theme/DocItem";
import type { TOCItem } from "@docusaurus/mdx-loader";

const getLevelFromTag = (tag: string): number | undefined => {
	const match = tag.match(/^H(?<level>\d)$/);

	if (match?.groups) {
		return Number(match.groups.level);
	}
};

const transformHeading = (heading: Element): TOCItem => {
	const isCode = heading.getElementsByTagName("code").length > 0;
	const value = isCode ? `<code>${heading.textContent}</code>` : heading.textContent ?? "";

	return {
		value,
		id: heading.id,
		level: getLevelFromTag(heading.tagName) ?? 2,
	};
};

export default function DocItem({ content: DocContent }: Props) {
	const docHtmlClassName = `docs-doc-id-${DocContent.metadata.unversionedId}`;
	const [toc, setToc] = useState<TOCItem[]>([]);

	useEffect(() => {
		console.log("BLAH");
		const headings = document.querySelectorAll("h2, h3, h4, h5, h6");

		setToc(Array.from(headings).map(transformHeading));
	}, [DocContent]);

	return (
		<DocProvider content={{ ...DocContent, toc } as never}>
			<HtmlClassNameProvider className={docHtmlClassName}>
				<DocItemMetadata />
				<DocItemLayout>
					<DocContent />
				</DocItemLayout>
			</HtmlClassNameProvider>
		</DocProvider>
	);
}
