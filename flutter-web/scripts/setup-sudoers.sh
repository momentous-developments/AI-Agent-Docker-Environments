#!/bin/bash

# Setup sudoers for developer user to have full passwordless sudo access
# This should be run during container build

echo "Setting up sudoers for developer user..."

# Create sudoers directory if it doesn't exist
mkdir -p /etc/sudoers.d

# Create sudoers file for developer with full passwordless sudo
cat > /etc/sudoers.d/developer << EOF
# Allow developer to run any command without password
developer ALL=(ALL) NOPASSWD:ALL
EOF

# Set proper permissions
chmod 0440 /etc/sudoers.d/developer

echo "Sudoers configured for developer user with passwordless access"