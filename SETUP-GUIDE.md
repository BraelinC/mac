# macOS VM Setup Guide (Ultimate-macOS-KVM)

This guide sets up a macOS virtual machine on Linux using Ultimate-macOS-KVM, which has better automation and error handling than basic QEMU setups.

## System Requirements

- **CPU:** Intel with VT-x or AMD with SVM (virtualization support)
- **RAM:** 16GB+ recommended (8GB minimum for VM + host)
- **Storage:** 100GB+ free space
- **OS:** Ubuntu, Debian, Fedora, Arch, or similar Linux distro

---

## Step 1: Install Dependencies

### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install -y qemu-system-x86 qemu-utils libvirt-daemon-system \
    libvirt-clients bridge-utils virt-manager ovmf python3 python3-pip \
    git wget curl dmg2img tesseract-ocr
```

### Fedora:
```bash
sudo dnf install -y qemu-kvm libvirt virt-manager bridge-utils \
    edk2-ovmf python3 python3-pip git wget curl dmg2img tesseract
```

### Arch:
```bash
sudo pacman -S qemu-full libvirt virt-manager edk2-ovmf python python-pip \
    git wget curl dmg2img tesseract
```

---

## Step 2: Configure KVM

### Enable and start libvirt:
```bash
sudo systemctl enable --now libvirtd
sudo systemctl start libvirtd
```

### Add your user to required groups:
```bash
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
```

### Configure KVM for macOS compatibility:
```bash
# For AMD CPUs:
echo "options kvm_amd nested=1" | sudo tee /etc/modprobe.d/kvm_amd.conf
echo "options kvm ignore_msrs=1 report_ignored_msrs=0" | sudo tee -a /etc/modprobe.d/kvm_amd.conf

# For Intel CPUs:
echo "options kvm_intel nested=1" | sudo tee /etc/modprobe.d/kvm_intel.conf
echo "options kvm ignore_msrs=1 report_ignored_msrs=0" | sudo tee -a /etc/modprobe.d/kvm_intel.conf

# Apply immediately (or reboot):
sudo modprobe -r kvm_amd kvm_intel 2>/dev/null
sudo modprobe kvm
sudo modprobe kvm_amd 2>/dev/null || sudo modprobe kvm_intel 2>/dev/null

# Verify ignore_msrs is enabled:
cat /sys/module/kvm/parameters/ignore_msrs
# Should output: Y
```

### Log out and back in (or reboot) for group changes to take effect:
```bash
# Option 1: Reboot
sudo reboot

# Option 2: Log out and back in, then verify:
groups | grep -E "(libvirt|kvm)"
```

---

## Step 3: Clone Ultimate-macOS-KVM

```bash
cd ~
git clone https://github.com/Coopydood/ultimate-macOS-KVM.git
cd ultimate-macOS-KVM
```

---

## Step 4: Run the Setup Wizard

```bash
./main.py
```

This launches an interactive wizard that will:
1. Check your system compatibility
2. Let you choose macOS version (Monterey, Ventura, Sonoma, Sequoia, or Tahoe)
3. Download the recovery image
4. Configure CPU, RAM, and disk settings
5. Generate optimized QEMU scripts

### Recommended settings when prompted:
- **macOS Version:** Monterey (most stable for VMs) or Ventura
- **RAM:** 8GB-12GB (leave some for host)
- **CPU Cores:** 4-6 (half your total cores)
- **Disk Size:** 128GB or more
- **Network:** Default (user-mode NAT)

---

## Step 5: Start the VM

After the wizard completes, it creates a boot script. Run it:

```bash
./boot.sh
```

Or use the main menu:
```bash
./main.py
# Select "Start an existing macOS virtual machine"
```

---

## Step 6: Install macOS

1. **OpenCore Boot Picker:** Select "macOS Base System"
2. **Language:** Select your language
3. **Disk Utility:**
   - Click "View" > "Show All Devices"
   - Select the large virtual disk (not a partition)
   - Click "Erase"
   - Name: `Macintosh HD`
   - Format: `APFS`
   - Click "Erase"
4. **Close Disk Utility**
5. **Select "Reinstall macOS [Version]"**
6. **Follow the installer prompts**

The VM will restart several times during installation.

---

## Step 7: Post-Install (Important!)

After macOS boots to the setup screen:

### Prevent boot loop (critical for Monterey+):
Before you restart or shut down, do ONE of these:

**Option A - Enable Auto-Login:**
1. Complete the macOS setup
2. Go to System Preferences > Users & Groups
3. Click Login Options
4. Set "Automatic login" to your user

**Option B - Enable FileVault:**
1. Go to System Preferences > Security & Privacy > FileVault
2. Turn on FileVault

This prevents the loginwindow crash that causes boot loops in VMs.

---

## Troubleshooting

### "busy timeout" errors during boot:
Edit the OpenCore config to add boot arguments:
```
-v keepsyms=1 tlbto_us=0 vti=9
```

### VM won't start - permission denied:
```bash
sudo chmod 666 /dev/kvm
```

### Black screen after OpenCore:
Try a different macOS version or check CPU compatibility.

### Slow performance:
- Ensure KVM is enabled (not TCG emulation)
- Reduce RAM if host is swapping
- Use SSD storage for VM disk

### Check logs:
```bash
# Ultimate-macOS-KVM creates logs in:
ls -la ~/ultimate-macOS-KVM/logs/
```

---

## Useful Commands

### Check if KVM is working:
```bash
kvm-ok
# or
lsmod | grep kvm
```

### Monitor VM resources:
```bash
# Find QEMU process
ps aux | grep qemu-system

# Watch resource usage
htop
```

### Access QEMU monitor (if configured):
```bash
socat -,echo=0,icanon=0 unix-connect:/path/to/monitor.socket
```

---

## Directory Structure

After setup, you'll have:
```
~/ultimate-macOS-KVM/
├── main.py              # Main menu
├── boot.sh              # Generated boot script
├── resources/           # OVMF, OpenCore files
├── logs/                # Error logs
└── [macOS-disk].qcow2   # Virtual disk
```

---

## Links

- **Ultimate-macOS-KVM:** https://github.com/Coopydood/ultimate-macOS-KVM
- **OpenCore Documentation:** https://dortania.github.io/OpenCore-Install-Guide/
- **Troubleshooting:** https://github.com/Coopydood/ultimate-macOS-KVM/wiki

---

*Generated for setting up macOS VM on Linux with 20GB+ RAM system*
