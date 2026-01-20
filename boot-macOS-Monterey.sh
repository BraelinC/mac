#!/bin/bash
# Auto-generated boot script for macOS-Monterey
# Run with: ./boot-macOS-Monterey.sh

REPO_PATH="$(dirname "$0")"

args=(
    -enable-kvm
    -m 8G
    -cpu Haswell-noTSX,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check
    -smp 4,cores=4,sockets=1,threads=1
    -machine q35
    -device usb-ehci,id=ehci
    -device usb-kbd,bus=ehci.0
    -device usb-tablet,bus=ehci.0
    -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
    -drive if=pflash,format=raw,readonly=on,file="${REPO_PATH}/ovmf/OVMF_CODE.fd"
    -drive if=pflash,format=raw,file="${REPO_PATH}/ovmf/OVMF_VARS.fd"
    -smbios type=2
    -device ich9-intel-hda -device hda-duplex
    -device ich9-ahci,id=sata
    -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="${REPO_PATH}/boot/OpenCore.qcow2"
    -device ide-hd,bus=sata.2,drive=OpenCoreBoot,bootindex=1
    -drive id=InstallMedia,if=none,file="${REPO_PATH}/BaseSystem.img",format=raw
    -device ide-hd,bus=sata.3,drive=InstallMedia
    -drive id=MacHDD,if=none,file="${REPO_PATH}/macOS-Monterey.qcow2",format=qcow2
    -device ide-hd,bus=sata.4,drive=MacHDD
    -netdev user,id=net0,hostfwd=tcp::2222-:22 -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:c9:18:27
    -monitor stdio
    -device vmware-svga
    -display gtk,zoom-to-fit=on
)

qemu-system-x86_64 "${args[@]}"
