// @ts-check

const lightCodeTheme = require("prism-react-renderer/themes/github");
const darkCodeTheme = require("prism-react-renderer/themes/dracula");

/** @type {import('@docusaurus/types').Config} */
const config = {
	title: "Lest",
	tagline: "Zero dependency Lua testing framework in the style of Jest",
	favicon: "img/favicon.ico",

	url: "https://taservers.github.io",
	baseUrl: "/lest/",

	organizationName: "TAServers",
	projectName: "lest",

	onBrokenLinks: "throw",
	onBrokenMarkdownLinks: "warn",

	i18n: {
		defaultLocale: "en-GB",
		locales: ["en-GB"],
	},

	presets: [
		[
			"classic",
			/** @type {import('@docusaurus/preset-classic').Options} */
			({
				docs: {
					path: "./docs",
					sidebarPath: require.resolve("./sidebars.js"),
					editUrl: "https://github.com/TAServers/lest/tree/master/site/",
				},
				theme: {
					customCss: require.resolve("./src/css/custom.css"),
				},
			}),
		],
	],

	themeConfig:
		/** @type {import('@docusaurus/preset-classic').ThemeConfig} */
		({
			// Replace with your project's social card
			image: "img/docusaurus-social-card.jpg",
			navbar: {
				title: "Lest",
				logo: {
					alt: "Lest Logo",
					src: "img/logo.svg",
				},
				items: [
					{
						type: "docsVersionDropdown",
					},
					{
						type: "docSidebar",
						sidebarId: "docs",
						position: "right",
						label: "Docs",
					},
					{
						type: "docSidebar",
						sidebarId: "api",
						position: "right",
						label: "API",
					},
					{
						href: "https://github.com/TAServers/lest",
						label: "GitHub",
						position: "right",
					},
				],
			},
			footer: {
				style: "dark",
				links: [
					{
						title: "Docs",
						items: [
							{
								label: "Getting Started",
								to: "/docs/tutorials/introduction/getting-started",
							},
							{
								label: "Guides",
								to: "/docs/tutorials/guides",
							},
							{
								label: "API Reference",
								to: "/docs/api/globals",
							},
						],
					},
					{
						title: "Community",
						items: [
							{
								label: "Discord",
								href: "https://discord.taservers.com",
							},
						],
					},
					{
						title: "More",
						items: [
							{
								label: "GitHub",
								href: "https://github.com/TAServers/lest",
							},
						],
					},
				],
				copyright: `Copyright © ${new Date().getFullYear()} TAServers. Built with Docusaurus.`,
			},
			prism: {
				theme: lightCodeTheme,
				darkTheme: darkCodeTheme,
				additionalLanguages: ["lua"],
			},
		}),
};

module.exports = config;
