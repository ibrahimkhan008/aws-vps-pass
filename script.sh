#!/bin/bash
set -euo pipefail

echo "🔍 SSH Auto-Fix Script Starting..."
echo "--------------------------------------"

if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run this script with sudo/root."
    exit 1
fi

# Fixed default password for BOTH accounts.
DEFAULT_PASS="changeme@123"
PUBLIC_IP=$(curl -fsSL https://ifconfig.me)

# When run as `sudo bash`, SUDO_USER is the account that originally
# connected to the VPS (e.g. ubuntu, opc, ec2-user).
CURRENT_USER="${SUDO_USER:-}"

if [[ -z "$CURRENT_USER" || "$CURRENT_USER" == "root" ]]; then
    echo "❌ Could not determine the current SSH user."
    echo "Run the script with sudo from the user's SSH session."
    exit 1
fi

if ! id "$CURRENT_USER" >/dev/null 2>&1; then
    echo "❌ User '$CURRENT_USER' does not exist."
    exit 1
fi

echo "👤 Current SSH user: $CURRENT_USER"
echo "👤 Root user: root"
echo "--------------------------------------"

echo "🔐 Setting password for $CURRENT_USER..."
printf '%s:%s\n' "$CURRENT_USER" "$DEFAULT_PASS" | chpasswd
echo "✅ Password set for $CURRENT_USER"

echo "🔐 Setting password for root..."
printf '%s:%s\n' "root" "$DEFAULT_PASS" | chpasswd
echo "✅ Password set for root"

echo "--------------------------------------"
echo "🔧 Configuring SSH password authentication..."

# Use a late override so provider/cloud-init settings don't override
# these SSH authentication settings.
OVERRIDE="/etc/ssh/sshd_config.d/99-password-auth.conf"

cat > "$OVERRIDE" <<'EOF'
# Managed by SSH Auto-Fix
PasswordAuthentication yes
KbdInteractiveAuthentication yes
AuthenticationMethods any
PermitRootLogin yes
EOF

chmod 644 "$OVERRIDE"

echo "🧪 Validating SSH configuration..."
if ! sshd -t; then
    echo "❌ sshd configuration is invalid."
    rm -f "$OVERRIDE"
    exit 1
fi
echo "✅ SSH configuration valid"

echo "--------------------------------------"
echo "🔁 Restarting SSH..."

if systemctl restart ssh 2>/dev/null; then
    echo "✅ SSH restarted"
elif systemctl restart sshd 2>/dev/null; then
    echo "✅ sshd restarted"
else
    echo "❌ Could not restart SSH service."
    exit 1
fi

sleep 1

echo "--------------------------------------"
echo "📊 Final SSH Status:"
sshd -T | grep -E '^(passwordauthentication|kbdinteractiveauthentication|authenticationmethods|permitrootlogin) '
echo "--------------------------------------"
echo "🎉 System fixed successfully"
echo "👤 Current user: $CURRENT_USER"
echo "👤 Root user: root"
echo "🔑 Password for BOTH: $DEFAULT_PASS"
echo ""
echo "🌐 Public IP: $PUBLIC_IP"
echo ""
echo "Test current user:"
echo "  ssh ${CURRENT_USER}@${PUBLIC_IP}"
echo ""
echo "Test root:"
echo "  ssh root@${PUBLIC_IP}"
echo "--------------------------------------"
echo "⚠️ Change the default password after testing:"
echo "  passwd"
echo "  sudo passwd root"
echo "🚀 Done!"
