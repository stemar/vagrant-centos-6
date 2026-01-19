# Changelog

## 1.0.7 - 2026-01-19

### Changed

- Changed Adminer theme.

## 1.0.6 - 2026-01-18

### Added

- Added `CHANGELOG.md`
- Added `config/adminer-plugins.php`
- Bash output to null

### Changed

- Updated YAML array format in `settings.yaml`.
    - Added `:id` to all `:forwarded_ports`.
- Updated `Vagrantfile` by adding local variables.
    - Modernized path in the `YAML.load_file()` call.
- Replaced `FORWARDED_PORT_80` variable with `HOST_HTTP_PORT` in 3 files.
    - Updated `provision.sh`, `adminer.conf`, `virtualhost.conf` with new variable name.
- Modified the version section of `provision.sh` for the section title and the Apache version output.
- Updated the last section of `README.md`.
- Updated `config/adminer.php`.

### Fixed

- Updated Adminer to version 5+ plugin code and files.

## 1.0.5 - 2023-08-10

### Fixed

- Fixed Ruby variables in Vagrantfile.

## 1.0.4 - 2023-01-16

### Changed

- Updated Adminer.
- Modified `settings.yaml`.

## 1.0.3 - 2022-05-06

### Added

- Added yum repositories files.
- Added checks in `provision.sh`.

### Changed

- Updated `virtualhost.conf`.
- Moved box name to `settings.yaml`.
- Hard-coded `/vagrant/config` in `provision.sh`.

### Fixed

- Fixed the URLs for End Of Life repositories.
    - Original CentOS mirrors no longer supported.

## 1.0.2 - 2022-04-29

### Changed

- Corrected port in `virtualhost.conf`.
- Updated README.

### Fixed

- Fixed Adminer password lock.

## 1.0.1 - 2021-04-26

### Added

- Added SSH forwarded ports to `settings.yaml`.
- Added `:php_error_reporting` to `settings.yaml`.
- Added timezone setting.

### Changed

- Renamed `centos-6-10` to `centos-6`.
- Updated MariaDB to version 10.6.
- Modified README, `Vagrantfile`, `settings.yaml`, `provision.sh`.

## 1.0.0 - 2021-04-15

_First release_
