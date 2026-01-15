# Yocto RPi5 with RAUC A/B Updates

This project sets up a Yocto-based Linux image for Raspberry Pi 5 with RAUC A/B partition scheme for atomic OTA updates.

**All builds run inside Docker** - no need to install Yocto dependencies on your host machine.

## Configuration Overview

This repo separates configuration into:

- **Project-level build config**: `conf/project-build.conf` (gitignored, intended for per-user/per-machine settings)
- **Yocto build directory config**: `build/conf/local.conf` and `build/conf/bblayers.conf` (generated/updated after the first build env init)
- **Layer content**: `layers/meta-rpi5-rauc/` (image recipe, wic layout, RAUC system config)

During `./project build`, the build script ensures your `build/conf/local.conf` contains:

```conf
require ../../conf/project-build.conf
```

If `conf/project-build.conf` is missing, the build will fail. Start from the committed template and create your local config:

```bash
cp conf/project-build.conf.example conf/project-build.conf
```

Then edit `conf/project-build.conf` for your local settings (it is intentionally gitignored, similar to a local override file).

`build/conf/local.conf` is created by Yocto tooling and should be treated as generated. In this project, you should put local overrides in `conf/project-build.conf` rather than editing `build/conf/local.conf` directly.

### Local customization (`conf/project-build.conf`)

Uncomment and set the values you need in `conf/project-build.conf`. The template includes examples for:

- `BB_NUMBER_THREADS` and `PARALLEL_MAKE` (control build parallelism)
- `RPI5_SSH_USERNAME`, `RPI5_SSH_UID`, `RPI5_SSH_GID`, `RPI5_SSH_PUBLIC_KEY` (provision an SSH user)

## Partition Layout (32GB SD Card)

| Partition | Label     | Size    | Filesystem | Purpose                    |
|-----------|-----------|---------|------------|----------------------------|
| 1         | boot      | 256 MB  | FAT32      | RPi firmware + kernel      |
| 2         | rootfs_a  | 8 GB    | ext4       | Root filesystem (Slot A)   |
| 3         | rootfs_b  | 8 GB    | ext4       | Root filesystem (Slot B)   |
| 4         | data      | ~14 GB  | ext4       | Persistent user data       |

## Prerequisites

- **Docker** (Docker Desktop on macOS/Windows, or Docker Engine on Linux)
- ~50GB free disk space for build artifacts

## Quick Start

**All commands run inside Docker** - the only host requirement is Docker itself.

### 1. Start Docker Container

```bash
./project start
```

### 2. Clone Yocto Layers (inside Docker)

```bash
./project setup
```

This clones: `poky`, `meta-openembedded`, `meta-raspberrypi`, `meta-rauc`

### 3. Generate RAUC Signing Keys (inside Docker)

```bash
./project keys
```

⚠️ **For production**: Use proper PKI infrastructure and secure key storage!

### 4. Build the Image (inside Docker)

```bash
./project build
```

☕ **First build takes 1-4 hours** depending on your system.

### 5. Write Image to SD Card

```bash
./project write-image
```

Images will be copied to the `output/` directory:

| File | Description |
|------|-------------|
| `rpi5-rauc-image-raspberrypi5.wic` | Raw SD card image (write directly to disk) |
| `rpi5-rauc-image-raspberrypi5.wic.bmap` | Block map for faster flashing with bmaptool |
| `rpi5-rauc-bundle-*.raucb` | RAUC update bundle (if you ran `./project bundle`) |

Use your preferred tool to write the `.wic` image to your SD card (e.g., `dd`, Balena Etcher, Raspberry Pi Imager, `bmaptool`).

## Docker Commands Reference

### Container Management

| Command | Description |
|---------|-------------|
| `./project start` | Start build container |
| `./project stop` | Stop build container |
| `./project shell` | Enter container shell |
| `./project status` | Show container status |
| `./project logs` | Show container logs |
| `./project purge` | Remove all Docker volumes |

### Build Commands (run inside Docker)

| Command | Description |
|---------|-------------|
| `./project setup` | Clone Yocto layers |
| `./project keys` | Generate RAUC signing keys |
| `./project build` | Run Yocto build |
| `./project bundle` | Build RAUC update bundle |
| `./project clean` | Remove build artifacts |
| `./project clean-state <recipe>` | Reset a single recipe via `cleansstate` |
| `./project clean-failed` | Reset the most recently failed recipe via `cleansstate` |
| `./project write-image` | Copy images to output/ |

## RAUC Usage (On the Raspberry Pi)

Once booted, you can perform A/B updates:

```bash
# Check current boot slot
rauc status

# Install an update bundle to the inactive slot
rauc install /path/to/update.raucb

# The system will automatically boot into the new slot on next reboot
```

## Creating Update Bundles

```bash
./project bundle
```

The bundle (`.raucb` file) will be copied to `output/` after running `./project write-image`. Transfer it to the device and install with `rauc install`.

## Directory Structure

```
yocto-rpi5/
├── project                 # Host CLI (thin wrapper, only uses docker commands)
├── Dockerfile              # Build environment container
├── docker-compose.yml      # Container orchestration
├── scripts/                # All scripts run inside Docker container
│   ├── build.sh            # Yocto build script
│   ├── setup-layers.sh     # Clone Yocto layers
│   └── generate-rauc-keys.sh  # RAUC key generation
├── build/
│   └── conf/
│       ├── local.conf      # Build configuration
│       └── bblayers.conf   # Layer configuration
├── layers/
│   ├── poky/               # Yocto core (cloned)
│   ├── meta-openembedded/  # Additional recipes (cloned)
│   ├── meta-raspberrypi/   # RPi BSP layer (cloned)
│   ├── meta-rauc/          # RAUC recipes (cloned)
│   └── meta-rpi5-rauc/     # Custom layer (included)
├── output/                 # Copied artifacts (after ./project write-image)
├── CHANGELOG.md            # Version history and changes
└── README.md
```

## How A/B Updates Work

1. **Initial State**: System boots from Slot A (`rootfs_a`)
2. **Update**: RAUC writes new image to inactive Slot B (`rootfs_b`)
3. **Switch**: RAUC updates bootloader to boot from Slot B
4. **Reboot**: System boots into updated Slot B
5. **Rollback**: If boot fails, system automatically falls back to Slot A

This ensures atomic updates with automatic rollback on failure.

## Troubleshooting

### Build fails with "out of space"
Increase Docker Desktop disk allocation in Preferences → Resources.

### Build is very slow
On macOS/Windows, this is expected due to Docker's filesystem virtualization. The named volumes in `docker-compose.yml` help, but native Linux builds are faster.

### Permission errors in container
Ensure `USER_ID` and `GROUP_ID` match your host user. The `./project start` command sets these automatically.

### Can't find built images
Run `./project write-image` to copy images from the Yocto deploy directory to `output/`.

### Need to regenerate the `.wic` image
If you changed the `.wks` layout or image tasks and need to force WIC regeneration:

```bash
./project write-image --force-wic
```

## Configuration Reference

### Key Files

| File | Purpose |
|------|---------|
| `conf/project-build.conf` | Local project build overrides included from `local.conf` (gitignored) |
| `build/conf/local.conf` | Machine target, features, image settings |
| `build/conf/bblayers.conf` | Layer paths |
| `layers/meta-rpi5-rauc/wic/rpi5-rauc-ab.wks` | Partition layout |
| `layers/meta-rpi5-rauc/recipes-core/rauc/files/system.conf` | RAUC slot configuration |
| `layers/meta-rpi5-rauc/recipes-core/images/rpi5-rauc-image.bb` | Image recipe |

### Customization

**Change partition sizes**: Edit `layers/meta-rpi5-rauc/wic/rpi5-rauc-ab.wks`

**Add packages to image**: Edit `layers/meta-rpi5-rauc/recipes-core/images/rpi5-rauc-image.bb`:
```bitbake
IMAGE_INSTALL += " your-package"
```

**Change Yocto release**: Update branch in `scripts/setup-layers.sh` (default: `scarthgap`)

### Docker Build Environment Notes

- The container runs as a non-root user (Yocto does not build as root).
- `docker-compose.yml` uses named volumes for `downloads/`, `sstate-cache/`, and `build/tmp/` to improve performance on macOS/Windows.
- Memory limits/reservations are set in `docker-compose.yml`; if builds OOM, increase Docker Desktop memory and/or those limits.

## Development Notes

See [CHANGELOG.md](CHANGELOG.md) for version history and modifications made during development.
