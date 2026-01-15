# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed
- **All operations now run inside Docker** - host only needs Docker installed
- Host script `./project` is a thin wrapper that only calls docker commands
- Container scripts in `scripts/` (setup-layers.sh, generate-rauc-keys.sh, build.sh)
- Made documentation platform-agnostic (removed OS-specific instructions)
- Users write `.wic` images to SD cards using their own preferred tools
- Added `keys` command for generating RAUC signing keys inside Docker
- Added `bundle` command for building RAUC update bundles

### Added
- Initial project setup with Docker-based Yocto build environment
- Raspberry Pi 5 target configuration (`MACHINE = "raspberrypi5"`)
- RAUC A/B partition scheme for 32GB SD cards:
  - 256MB boot partition (FAT32)
  - 8GB rootfs_a (Slot A)
  - 8GB rootfs_b (Slot B)
  - ~14GB persistent data partition
- Custom Yocto layer `meta-rpi5-rauc` with:
  - `rpi5-rauc-image.bb` - Base image recipe
  - `rpi5-rauc-bundle.bb` - OTA update bundle recipe
  - `rpi5-rauc-ab.wks` - WIC partition layout
  - RAUC system configuration for U-Boot bootloader
  - Systemd mount unit for persistent data partition
- Docker build environment:
  - `Dockerfile` - Ubuntu 22.04 with Yocto dependencies
  - `docker-compose.yml` - Named volumes for sstate/downloads/tmp
  - `scripts/docker-build.sh` - Main CLI for all operations
  - `scripts/setup-layers.sh` - Clones required Yocto layers
  - `scripts/docker/build.sh` - Build script (runs inside container)
  - `scripts/generate-rauc-keys.sh` - Development key generation

### Configuration
- Yocto release: **scarthgap** (current LTS)
- Init system: **systemd**
- Bootloader: **U-Boot** (required for RAUC slot switching)
- SSH: **dropbear** (lightweight)
- Package format: **ipk**

---

## Version History Format

### [X.Y.Z] - YYYY-MM-DD

#### Added
- New features

#### Changed
- Changes to existing functionality

#### Fixed
- Bug fixes

#### Removed
- Removed features
