# 🔐 SSH Auto-Fix Script

A smart Bash script that **automatically audits, fixes, and validates SSH configuration** on Linux servers (tested on Ubuntu AWS EC2).

It ensures password-based SSH login works correctly while avoiding unnecessary changes.

---

## ✨ Features

* ✅ Detects current SSH configuration state
* 🔧 Fixes only missing or incorrect settings
* 🧠 Skips steps if already configured
* 🔐 Sets default password **only when changes are made**
* 📁 Handles AWS override configs (`sshd_config.d`)
* 🔁 Restarts SSH **only if required**
* 📊 Final validation output
* 🧾 Clean, step-by-step CLI output

---

## 📋 What It Checks & Fixes

### Step-by-step:

1. **PasswordAuthentication**

   * Ensures:

     ```
     PasswordAuthentication yes
     ```

2. **AuthenticationMethods**

   * Ensures:

     ```
     AuthenticationMethods any
     ```

3. **Main SSH Config (`/etc/ssh/sshd_config`)**

   * Fixes or adds:

     ```
     PasswordAuthentication yes
     PermitRootLogin yes
     ```

4. **Override Configs (`/etc/ssh/sshd_config.d/*.conf`)**

   * Detects AWS cloud configs like:

     ```
     60-cloudimg-settings.conf
     ```
   * Overrides:

     ```
     PasswordAuthentication no → yes
     ```

5. **Password Setup**

   * Sets default password:

     ```
     username@123
     ```
   * ONLY if changes were required

6. **Service Restart**

   * Restarts SSH **only if modifications were made**

---

## 🚀 Installation & Usage

## One-line install command

```bash 
curl -fsSL https://raw.githubusercontent.com/ibrahimkhan008/aws-vps-pass/main/script.sh | sudo bash
```

### 1. Clone or create script

```bash
nano fix-ssh.sh
```

Paste the script → Save

---

### 2. Make executable

```bash
chmod +x fix-ssh.sh
```

---

### 3. Run script

```bash
./fix-ssh.sh
```

---

## 🧾 Example Output

### ✅ Already Configured

```
🔍 SSH Auto-Fix Script Starting...
👤 User: ubuntu
--------------------------------------
✅ Step 1: PasswordAuthentication already enabled
--------------------------------------
✅ Step 2: AuthenticationMethods already correct
--------------------------------------
✅ Step 3: PasswordAuthentication already correct in main config
--------------------------------------
✅ Step 4: PermitRootLogin already correct
--------------------------------------
Step 5: 📁 Checking override configs...
✅ /etc/ssh/sshd_config.d/60-cloudimg-settings.conf already correct
--------------------------------------
Step 6: 🟢 No changes needed → password NOT modified
--------------------------------------
🔁 Restarting SSH... (skipped, already correct)
📊 Final Status:
passwordauthentication yes
authenticationmethods any
🎉 System already correct No extra step need user can login using there pass!
🚀 Done!
```

---

### 🔧 When Fixes Are Needed

```
❌ Step 1: Fixing PasswordAuthentication...
❌ Step 2: Fixing AuthenticationMethods...
...
🔐 Changes detected → setting default password...
🔁 Restarting SSH...
🎉 System fixed successfully
```

---

## ⚠️ Security Warning

The script sets a predictable default password:

```
username@123
```

👉 This is **NOT secure for production environments**

### Recommended:

* Change password immediately after use
* Or modify script to generate random password

---

## 🧠 Use Cases

* AWS EC2 setup (Ubuntu)
* VPS quick configuration
* Automation / DevOps scripts
* Personal server setup
* Debugging SSH login issues

---

## 🔮 Future Improvements (Ideas)

* 🔐 Random secure password generator
* 📲 Telegram/Discord notification
* 🛡️ Auto-install Fail2Ban
* 🔥 Firewall setup (UFW)
* ⚡ One-line installer (`curl | bash`)
* 🧩 CLI menu version

---

## 🤝 Contributing

Pull requests are welcome.
If you have ideas or improvements, feel free to fork and enhance.

---

## 📄 License

MIT License — free to use and modify.

---

## ⭐ Support

If this helped you:

* ⭐ Star the repo
* 🍴 Fork it
* 🧠 Share improvements
