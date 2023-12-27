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

## [3.1.0] - [#113](https://github.com/TAServers/lest/pull/113)

### Added

-   Added pretty diff rendering to `toEqual` matcher to show differences between deeply nested values

### Changed

-   `toBe` matcher now generates its message more in line with Jest to make comparing values easier
-   All values displayed in test failure messages are now properly serialised to mostly valid Lua, including the contents of tables
-   Test failure messages no longer include the expected and received values in the `expect(...).matcherName(...)` signature
    -   This matches the behaviour of Jest and avoids duplicating information between the signature and failure message
-   Test failure messages are no longer highlighted in red to give more control to matchers over how individual messages are formatted

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
