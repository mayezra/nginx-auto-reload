#!/bin/bash

##############################################################################
# Init Container - Configuration Validation
# Runs before main containers to ensure valid configuration
##############################################################################

set -euo pipefail

readonly NGINX_CONFIG="/etc/nginx/nginx.conf"

echo "================================"
echo "Init Container: Config Validation"
echo "================================"

# Check 1: Config file exists
echo "[1/3] Checking configuration file exists..."
if [ ! -f "$NGINX_CONFIG" ]; then
    echo "ERROR: Configuration file not found: $NGINX_CONFIG"
    exit 1
fi
echo "✓ Configuration file exists"

# Check 2: Config file is readable
echo "[2/3] Checking configuration file is readable..."
if [ ! -r "$NGINX_CONFIG" ]; then
    echo "ERROR: Configuration file not readable: $NGINX_CONFIG"
    exit 1
fi
echo "✓ Configuration file is readable"

# Check 3: Config syntax is valid
echo "[3/3] Validating configuration syntax..."
if ! nginx -t -c "$NGINX_CONFIG" 2>&1; then
    echo "ERROR: Configuration syntax validation failed"
    exit 1
fi
echo "✓ Configuration syntax is valid"

echo ""
echo "================================"
echo "All validation checks passed!"
echo "Proceeding to start main containers..."
echo "================================"

exit 0
