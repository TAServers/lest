# Lest Contributing Guide

Thank you for considering contributing to the Lest Lua testing framework!

Please note that while Total Anarchy Servers (that's us) allows full freedom of speech and expression in all of our game servers and Discord,
we expect those contributing to our projects on GitHub to conduct themselves professionally.
See our [Code of Conduct](https://github.com/TAServers/lest/blob/master/CODE_OF_CONDUCT.md) for more information.

## Repository structure

The Lest monorepo is split into a number of smaller *packages* which you can find in the `/packages` directory:
- `lest` - The testing framework itself
- `docs` - API documentation in plain JSON format
- `site` - Docusaurus site (https://taservers.github.io/lest)

For more information on each package and how to contribute to it, see the package's readme.
If a package doesn't have a readme yet, consider opening an issue or PR'ing one yourself even if you only include basic info.

## Workflow

We use [GitHub flow](https://docs.github.com/en/get-started/quickstart/github-flow) for all of our projects, including Lest.

1. Checkout a new feature branch from `master`
   - If working on a ticket, prefix your branch name with the ticket ref - e.g. `LEST-123-short-description`
   - You'll need to fork the repository if you haven't already (and don't have write access)
2. Push changes to your feature branch, merging in or rebasing onto `master` regularly
3. Once you're ready to merge your changes into `master`, create a new pull request on GitHub
4. Resolve any review comments that get raised
   - Pro tip: once you've pushed markups for review comments, you can re-request a review from the person who reviewed your PR so they know to take another look ![re-request view button location from GitHub's docs](https://docs.github.com/assets/cb-28785/mw-1440/images/help/pull_requests/request-re-review.webp)
5. Once approved, wait for someone to QA your pull request and resolve any issues that arise
6. After the QA has passed, merge your PR!
	- Your feature branch will be deleted automatically on GitHub, but you should delete it locally too to keep things tidy

## Project management

We currently use Jira's free plan for all project management purposes.
This is where the "ticket refs" (e.g. `LEST-123`) you see on PRs and branches come from.

Unfortunately, Jira's free plan does not allow for making a project publicly visible, which is an issue for potential outside contributors (like you!).
We will likely migrate to GitHub projects once we have access to [tasklists](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-tasklists) in order to improve your development experience (we're on the closed beta waitlist).
