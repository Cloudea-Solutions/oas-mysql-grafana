#!/bin/bash

set -e

OAS_USER="oas"
OAS_GROUP="oas"
OAS_INSTALL_DIR="/opt/oas"
ZIP_FILE="oas-linux-license-host.zip"
SERVICE_FILE="/etc/systemd/system/oas-license-host.service"

echo "📦 Installing OAS License Host..."

# Ensure root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root: sudo ./install_oas_license_host.sh"
  exit 1
fi

# Create oas user and group if not exists
if ! id "$OAS_USER" &>/dev/null; then
  echo "👤 Creating user '$OAS_USER'..."
  useradd --system --create-home --shell /usr/sbin/nologin "$OAS_USER"
fi

# Prepare install directory
mkdir -p "$OAS_INSTALL_DIR"
cd "$OAS_INSTALL_DIR"

# Download and extract
echo "⬇️  Downloading license host..."
wget -qO "$ZIP_FILE" https://filedownloads.openautomationsoftware.com/license-host/oas-linux-license-host.zip
echo "📂 Extracting..."
unzip -o "$ZIP_FILE"
rm -f "$ZIP_FILE"

# Fix permissions
chown -R "$OAS_USER":"$OAS_GROUP" "oas-linux-license-host"
cd oas-linux-license-host
chmod -R 750 $OAS_INSTALL_DIR/oas-linux-license-host
usermod -aG docker $OAS_USER

# Create systemd service
echo "📝 Creating systemd service at $SERVICE_FILE..."
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Open Automation Software License Host
After=network.target

[Service]
Type=simple
User=$OAS_USER
WorkingDirectory=$OAS_INSTALL_DIR/oas-linux-license-host
ExecStart=$OAS_INSTALL_DIR/oas-linux-license-host/OASLicenseHost
Restart=always
SyslogIdentifier=oas-license-host

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "🔁 Enabling and starting service..."
systemctl daemon-reload
systemctl enable oas-license-host
systemctl start oas-license-host

echo "✅ OAS License Host installed and running as user '$OAS_USER' from $OAS_INSTALL_DIR/oas-linux-license-host"
