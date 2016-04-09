# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.6] - 2016-04-09
### Changed
- Updated CHANGELOG.md
- Fix issue with missing Logger::Application (ruby 2.3)
- Catch IOError when accepting clients (ruby 2.3)
- Test against multiple ruby version on travis CI
- Add 'test-unit' gem dependency (ruby 2.2)

## [0.3] - 2016-03-13
### Added
- Implemented "daemon mode"
- Updated documentation
- Added Dockerfile for testing unreleased gems

## [0.2.17] - 2016-03-03
### Changed
- Fix version reporting issue

## [0.2.16] - 2016-03-03
### Changed
- Refactored snippets of code to be more consistent with "the Ruby way"
- Improved code consistency
- Added travis caching to bundler
- Removed unused parameter from the Configuration class initializer
- Updated documentation
- Added license notice to source files
- Replaced `assert_raise_with_message` with `assert_raise`
- Renamed the functional test case

### Added
- `--version` flag

## [0.2.0] - 2016-02-29
### Added
- Readme file

### Changed
- The sample configuration file now includes comments
