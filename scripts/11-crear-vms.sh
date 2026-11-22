#!/usr/bin/env bash
# =============================================================================
# 11-crear-vms.sh — P2 / Tasca 0 + Tasca 4
# Crea las 11 VMs del laboratorio individual con VBoxManage, en el grupo
# /ThinkLab-asier. REPETIBLE: si una VM ya existe, la salta (no la modifica).
# No toca ninguna VM fuera de /ThinkLab-asier.
# Diseño: docs/04-disseny.md (red interna LAN_21).
# Uso:  ./scripts/11-crear-vms.sh            (no necesita sudo)
# Las ISOs se leen de ~/Descargas (ver docs/03-sistemes.md).
# =============================================================================
set -euo pipefail

GRUPO="/ThinkLab-asier"
LAN="LAN_21"
DESC="$HOME/Descargas"
ISO_OPN="$DESC/OPNsense-26.7-dvd-amd64.iso"            # ya descomprimida y verificada (igual al .bz2)
ZIP_CHR="$DESC/mikrotik-chr-7.25.1/chr-7.25.1.vdi.zip"
ISO_DEB="$DESC/debian-13.1.0-amd64-netinst.iso"
ISO_PVE="$DESC/proxmox-ve_9.2-1.iso"
ISO_TN="$DESC/TrueNAS-SCALE-25.10.7.iso"
ISO_WS="$DESC/w2k25.iso"
ISO_W11="$DESC/win11.iso"                              # 25H2 (NO w11.iso, sin soporte)

paso() { echo; echo ">>> $*"; }
for f in "$ISO_OPN" "$ZIP_CHR" "$ISO_DEB" "$ISO_PVE" "$ISO_TN" "$ISO_WS" "$ISO_W11"; do
  [ -f "$f" ] || { echo "ERROR: falta $f"; exit 1; }
done

existe() { VBoxManage showvminfo "$1" >/dev/null 2>&1; }
carpeta() { dirname "$(VBoxManage showvminfo "$1" --machinereadable | awk -F'"' '/^CfgFile=/{print $2}')"; }

# crear <vm> <ostype> <vcpu> <ram_MB> <vram_MB> <gráfica> <firmware bios|efi>
crear() {
  local vm=$1
  VBoxManage createvm --name "$vm" --ostype "$2" --groups "$GRUPO" --register >/dev/null
  VBoxManage modifyvm "$vm" --cpus "$3" --memory "$4" --vram "$5" --graphicscontroller "$6" \
    --firmware "$7" --ioapic on --rtc-use-utc on --audio-enabled off --usb-ohci off \
    --boot1 dvd --boot2 disk --boot3 none --boot4 none
  # Un controlador SATA (AHCI) para todo: Windows Server no admite arrancar desde IDE
  VBoxManage storagectl "$vm" --name SATA --add sata --controller IntelAhci --portcount 10 --bootable on
}
# disco <vm> <puerto> <tamaño_MB> <nombre>   (VDI dinámico: solo ocupa lo que se usa)
disco() {
  local f; f="$(carpeta "$1")/$4.vdi"
  VBoxManage createmedium disk --filename "$f" --size "$3" --format VDI --variant Standard >/dev/null
  VBoxManage storageattach "$1" --storagectl SATA --port "$2" --device 0 --type hdd --medium "$f"
}
dvd() { VBoxManage storageattach "$1" --storagectl SATA --port "$2" --device 0 --type dvddrive --medium "$3"; }
# Firewall: adaptador 1 NAT (WAN) + adaptador 2 red interna LAN_21. Intel PRO/1000 (em0/em1, enp0s3/enp0s8, ether1/ether2)
red_fw()  { VBoxManage modifyvm "$1" --nic1 nat --nictype1 82540EM --nic2 intnet --intnet2 "$LAN" --nictype2 82540EM --cableconnected1 on --cableconnected2 on; }
# Resto: un solo adaptador en LAN_21
red_lan() { VBoxManage modifyvm "$1" --nic1 intnet --intnet1 "$LAN" --nictype1 82540EM --cableconnected1 on; }

hecho=(); saltadas=()
vm_nueva() { if existe "$1"; then echo "--- $1 ya existe: se salta"; saltadas+=("$1"); return 1; fi; paso "Creando $1"; hecho+=("$1"); }

# ---------------- Firewalls ----------------
if vm_nueva FW1-MikroTik; then
  crear FW1-MikroTik Linux26_64 1 288 16 vmsvga bios    # 288 MB ≥ fórmula oficial v7 (264 MB)
  red_fw FW1-MikroTik
  # La CHR no se instala: el disco ES la imagen oficial descomprimida
  unzip -o -q "$ZIP_CHR" -d "$(carpeta FW1-MikroTik)"
  VBoxManage storageattach FW1-MikroTik --storagectl SATA --port 0 --device 0 --type hdd \
    --medium "$(carpeta FW1-MikroTik)/chr-7.25.1.vdi"
  VBoxManage modifyvm FW1-MikroTik --boot1 disk --boot2 none
fi
if vm_nueva FW2-OPNsense; then
  crear FW2-OPNsense FreeBSD_64 1 3072 16 vmsvga bios       # 3 GB para el instalador (oficial); luego 1 GB (P18)
  red_fw FW2-OPNsense; disco FW2-OPNsense 0 16384 FW2-OPNsense; dvd FW2-OPNsense 1 "$ISO_OPN"
fi
if vm_nueva FW3-Debian-NFT; then
  crear FW3-Debian-NFT Debian12_64 1 512 16 vmsvga bios      # VirtualBox 7.0 no tiene tipo «Debian 13»
  red_fw FW3-Debian-NFT; disco FW3-Debian-NFT 0 8192 FW3-Debian-NFT; dvd FW3-Debian-NFT 1 "$ISO_DEB"
fi

# ---------------- Proxmox (VT-x anidada + promiscuo) ----------------
for n in 1 2 3; do
  vm="Proxmox-Node$n"
  if vm_nueva "$vm"; then
    crear "$vm" Debian12_64 2 3072 16 vmsvga bios
    VBoxManage modifyvm "$vm" --nested-hw-virt on
    red_lan "$vm"; VBoxManage modifyvm "$vm" --nicpromisc1 allow-all
    disco "$vm" 0 32768 "$vm"; dvd "$vm" 1 "$ISO_PVE"
  fi
done

# ---------------- Servidores ----------------
if vm_nueva NAS-TrueNAS; then
  crear NAS-TrueNAS Debian12_64 2 8192 16 vmsvga bios       # 8 GB = mínimo oficial
  red_lan NAS-TrueNAS
  disco NAS-TrueNAS 0 16384 NAS-TrueNAS-sistema
  disco NAS-TrueNAS 1 20480 NAS-TrueNAS-copias              # disco aparte para el pool de copias
  dvd NAS-TrueNAS 2 "$ISO_TN"
fi
if vm_nueva WinServer-2025; then
  crear WinServer-2025 Windows2022_64 2 4096 128 vboxsvga efi   # VirtualBox 7.0 no tiene tipo «Windows 2025»
  red_lan WinServer-2025; disco WinServer-2025 0 51200 WinServer-2025; dvd WinServer-2025 1 "$ISO_WS"
fi
if vm_nueva Server-Monitorizacion; then
  crear Server-Monitorizacion Debian12_64 1 1024 16 vmsvga bios
  red_lan Server-Monitorizacion
  disco Server-Monitorizacion 0 10240 Server-Monitorizacion
  for i in 1 2 3 4 5 6 7; do disco Server-Monitorizacion $((i+1)) 1024 "raid-disco$i"; done   # P15: RAID 0/1/5
  dvd Server-Monitorizacion 9 "$ISO_DEB"
fi

# ---------------- Clientes ----------------
if vm_nueva Client-Win11; then
  crear Client-Win11 Windows11_64 2 4096 128 vboxsvga efi
  VBoxManage modifyvm Client-Win11 --tpm-type 2.0
  VBoxManage modifynvram Client-Win11 inituefivarstore
  VBoxManage modifynvram Client-Win11 enrollmssignatures   # claves de Microsoft → Secure Boot
  VBoxManage modifynvram Client-Win11 enrollorclpk         # clave de plataforma → Secure Boot activo
  red_lan Client-Win11; disco Client-Win11 0 65536 Client-Win11; dvd Client-Win11 1 "$ISO_W11"
fi
if vm_nueva Client-Linux; then
  crear Client-Linux Debian12_64 2 3072 128 vmsvga bios     # consola de gestión con navegador
  red_lan Client-Linux; disco Client-Linux 0 25600 Client-Linux; dvd Client-Linux 1 "$ISO_DEB"
fi

echo
echo "=== Creadas (${#hecho[@]}): ${hecho[*]:-ninguna}"
echo "=== Saltadas porque ya existían (${#saltadas[@]}): ${saltadas[*]:-ninguna}"
