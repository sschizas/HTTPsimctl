# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Bump actions/upload-pages-artifact from 3 to 5.
- Bump actions/cache from 5 to 6.
- Bump actions/deploy-pages from 4 to 5.

## [1.7.0] - 2026-10-24
### Changed
- `/open-url` and `/permission/*` now reply only after `simctl` has finished, instead of immediately.
- `simctl` failures are reported to the client (500 with `simctl`'s stderr as the reason) instead of a silent 204.
- `/apns` returns `simctl push`'s actual error instead of a generic message, and always removes its temporary file.
- Commands run through [swift-subprocess](https://github.com/swiftlang/swift-subprocess) so waiting on `simctl` no longer blocks a request thread; concurrent requests no longer stall each other.
- Commands that run longer than 60 seconds are terminated and reported as 504.
- Require Swift 6.4 (Xcode 27) to build from source, and update Vapor to 4.122.3.

### Removed
- Unused duplicate `Shell.run(pid:)`.

## [1.6.0] - 2025-10-16
### Changed
- Support Swift 6.2
- Modernize project based on new VAPOR featues.

## [1.5.0] - 2024-07-23
### Added
- Support for sending Push Notifications (APNS).

## [1.4.0] - 2023-11-19
### Changed
- Start caching PIDs in memory instead of passing it to API consumers.
- Bumps [mislav/bump-homebrew-formula-action](https://github.com/mislav/bump-homebrew-formula-action) from 2 to 3.

## [1.3.0] - 2023-10-29
### Added
- Support simulators running in both normal and testing modes.

## [1.2.0] - 2023-09-17
### Added
- Support for app's permissions granting and revoking.

### Changed
- Bump Github action checkout to v4.

## [1.1.0] - 2023-08-09
### Added
- Version command.

### Changed
- Changed Swiftlint configuration.

### Fixed
- Fixed PRs' github action.

## [1.0.0] - 2023-07-15
### Added
- Support for universal links.
- Support for recording simulator screen and retreiving the file path.
- Support for installing using Homebrew.

[Unreleased]: https://github.com/sschizas/HTTPsimctl/compare/1.7.0...HEAD
[1.7.0]: https://github.com/sschizas/HTTPsimctl/compare/1.6.0...1.7.0
[1.6.0]: https://github.com/sschizas/HTTPsimctl/compare/1.5.0...1.6.0
[1.5.0]: https://github.com/sschizas/HTTPsimctl/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/sschizas/HTTPsimctl/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/sschizas/HTTPsimctl/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/sschizas/HTTPsimctl/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/sschizas/HTTPsimctl/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/sschizas/HTTPsimctl/releases/tag/1.0.0
