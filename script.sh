#!/bin/bash

echo "🔍 SSH Auto-Fix Script Starting..."

USER_NAME=$(whoami)
DEFAULT_PASS="${USER_NAME}@123"
CHANGED=false

echo "👤 User: $USER_NAME"
echo "--------------------------------------"

# STEP 1
PASS_AUTH=$(sudo sshd -T | grep passwordauthentication)
if [[ "$PASS_AUTH" == *"yes"* ]]; then
    echo "✅ Step 1: PasswordAuthentication already enabled"
else
    echo "❌ Step 1: Fixing PasswordAuthentication..."
    sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    CHANGED=true
fi

echo "--------------------------------------"

# STEP 2
AUTH_METHOD=$(sudo sshd -T | grep authenticationmethods)
if [[ "$AUTH_METHOD" == *"any"* ]]; then
    echo "✅ Step 2: AuthenticationMethods already correct"
else
    echo "❌ Step 2: Fixing AuthenticationMethods..."
    if grep -q "^AuthenticationMethods" /etc/ssh/sshd_config; then
        sudo sed -i 's/^AuthenticationMethods.*/AuthenticationMethods any/' /etc/ssh/sshd_config
    else
        echo "AuthenticationMethods any" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    fi
    CHANGED=true
fi

echo "--------------------------------------"

# STEP 3
if grep -Eq "^[#]*PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "✅ Step 3: PasswordAuthentication already correct in main config"
else
    echo "❌ Step 3: Fixing PasswordAuthentication in main config..."
    sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    CHANGED=true
fi

echo "--------------------------------------"

# STEP 4
if grep -Eq "^[#]*PermitRootLogin yes" /etc/ssh/sshd_config; then
    echo "✅ Step 4: PermitRootLogin already correct"
else
    echo "❌ Step 4: Fixing PermitRootLogin..."
    sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    CHANGED=true
fi

echo "--------------------------------------"

# STEP 5
echo "Step 5: 📁 Checking override configs..."

if grep -q "^Include /etc/ssh/sshd_config.d/\*\.conf" /etc/ssh/sshd_config; then
    for file in /etc/ssh/sshd_config.d/*.conf; do
        if grep -q "PasswordAuthentication yes" "$file"; then
            echo "✅ $file already correct"
        else
            echo "❌ Fixing $file"
            sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$file" || \
            echo "PasswordAuthentication yes" | sudo tee -a "$file"
            CHANGED=true
        fi
    done
else
    echo "ℹ️ No override configs found"
fi

echo "--------------------------------------"

# STEP 6
if [ "$CHANGED" = true ]; then
    echo "Step 6: 🔐 Changes detected → setting default password..."
    echo "$USER_NAME:$DEFAULT_PASS" | sudo chpasswd
    echo "✅ Password set to: $DEFAULT_PASS"
else
    echo "Step 6: 🟢 No changes needed → password NOT modified"
fi

echo "--------------------------------------"

# Restart only if changed
if [ "$CHANGED" = true ]; then
    echo "🔁 Restarting SSH..."
    sudo systemctl daemon-reload
    sudo systemctl restart ssh.socket
    sudo systemctl restart ssh
else
    echo "🔁 Restarting SSH... (skipped, already correct)"
fi

sleep 1

# FINAL CHECK
FINAL_PASS=$(sudo sshd -T | grep passwordauthentication)
FINAL_AUTH=$(sudo sshd -T | grep authenticationmethods)

echo "📊 Final Status:"
echo "$FINAL_PASS"
echo "$FINAL_AUTH"

if [[ "$CHANGED" = false ]]; then
    echo "🎉 System already correct No extra step need user can login using there pass!"
else
    echo "🎉 System fixed successfully"
fi

echo "🚀 Done!"
