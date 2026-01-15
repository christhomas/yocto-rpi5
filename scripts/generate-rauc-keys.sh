#!/bin/bash
# =============================================================================
# Generate RAUC Signing Keys (runs inside Docker container)
# =============================================================================
# This script generates development keys for RAUC bundle signing.
# FOR PRODUCTION: Use proper PKI infrastructure and secure key storage!

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
KEYS_DIR="$PROJECT_DIR/layers/meta-rpi5-rauc/files"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

mkdir -p "$KEYS_DIR"

log_warn "=============================================="
log_warn "DEVELOPMENT KEYS ONLY - NOT FOR PRODUCTION!"
log_warn "=============================================="
echo ""

# Generate CA private key
log_info "Generating CA private key..."
openssl genrsa -out "$KEYS_DIR/ca.key.pem" 4096

# Generate CA certificate
log_info "Generating CA certificate..."
openssl req -new -x509 -days 3650 \
    -key "$KEYS_DIR/ca.key.pem" \
    -out "$KEYS_DIR/ca.cert.pem" \
    -subj "/CN=RAUC CA/O=Development/C=US"

# Generate signing key
log_info "Generating signing key..."
openssl genrsa -out "$KEYS_DIR/signing.key.pem" 4096

# Generate signing certificate request
log_info "Generating signing certificate..."
openssl req -new \
    -key "$KEYS_DIR/signing.key.pem" \
    -out "$KEYS_DIR/signing.csr.pem" \
    -subj "/CN=RAUC Signing/O=Development/C=US"

# Sign the certificate with CA
openssl x509 -req -days 3650 \
    -in "$KEYS_DIR/signing.csr.pem" \
    -CA "$KEYS_DIR/ca.cert.pem" \
    -CAkey "$KEYS_DIR/ca.key.pem" \
    -CAcreateserial \
    -out "$KEYS_DIR/signing.cert.pem"

# Clean up CSR
rm -f "$KEYS_DIR/signing.csr.pem"

log_info "Keys generated successfully!"
echo ""
log_info "Files created:"
echo "  - $KEYS_DIR/ca.key.pem       (CA private key - KEEP SECRET)"
echo "  - $KEYS_DIR/ca.cert.pem      (CA certificate - goes on device)"
echo "  - $KEYS_DIR/signing.key.pem  (Signing key - KEEP SECRET)"
echo "  - $KEYS_DIR/signing.cert.pem (Signing certificate)"
echo ""
log_warn "Store private keys securely! Never commit them to version control!"
