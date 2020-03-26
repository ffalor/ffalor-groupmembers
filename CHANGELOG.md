# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

## Release 0.2.1 - 2020-3-26

### Changed

-   Fixed exception check to prevent failures
-   Fixed CHANGELOG typos.
-   Updated readme to be more clear.
-   Updated tags to increase Puppet quality score.
-   Changed Write-Host to Write-Output becasue of a codacy policy

## Release 0.2.0 - 2019-4-9

### Added

-   Member names longer than 20 characters can now be added if PowerShell 5.1 is present.
-   If a member is passed with a name longer than 20 characters and PowerShell 5.1 is not present they will be skipped instead of erroring out.
-   Members that are skipped will show up in a new JSON value.

### Changed

-   Updated success output to show as correct JSON.
-   Updated readme to reflect new requirements.
-   Updated readme to reflect new limitations.
-   Changed CHANGELOG to a new format.

## Release 0.1.1 - 2019-4-5

### Changed

-   Removed references to unused variables.

## Release 0.1.0 - 2019-4-5

### Added

-   Groupmembers task initial release.
