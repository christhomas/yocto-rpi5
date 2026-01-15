#!/bin/sh
# RAUC Post-Install Handler
# =========================
# This script runs after RAUC installs an update to a slot

set -e

SLOT_NAME="$RAUC_SLOT_NAME"
SLOT_BOOTNAME="$RAUC_SLOT_BOOTNAME"

echo "RAUC post-install: Slot $SLOT_NAME ($SLOT_BOOTNAME) updated successfully"

# Update U-Boot environment to boot from the new slot
if [ "$SLOT_BOOTNAME" = "A" ]; then
    fw_setenv BOOT_SLOT slot_a
elif [ "$SLOT_BOOTNAME" = "B" ]; then
    fw_setenv BOOT_SLOT slot_b
fi

echo "Boot slot set to: $SLOT_BOOTNAME"

exit 0
