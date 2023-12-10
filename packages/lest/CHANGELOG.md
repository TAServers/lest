# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The valid change types are:

-   `Added` for new features.
-   `Changed` for changes in existing functionality.
-   `Deprecated` for soon-to-be removed features.
-   `Removed` for now removed features.
-   `Fixed` for any bug fixes.
-   `Security` in case of vulnerabilities.

## [3.0.0] - [#102](https://github.com/TAServers/lest/issues/102)

### Added

-   Made it possible to set `testMatch` from the CLI

### Changed

-   (**BREAKING**) Changed CLI option format to only support `--option=value` and `-o=value` (`--option` and `-o` are shorthand for `--option=true` and `-o=true` respectively)

### Fixed

-   `lest.config.lua` is no longer required to run tests [#97](https://github.com/TAServers/lest/issues/97)
-   Unrecognised CLI arguments no longer throw an error, fixing the `--luaCommand` option in the wrapper being unusable [#104](https://github.com/TAServers/lest/issues/104)

## [2.1.0] - [#95](https://github.com/TAServers/lest/issues/95)

### Changed

-   Improved version and release management approach

### Security

-   Updated package dependencies to resolve audit failures
