packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "freebsd" {
  iso_url           = "https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/14.1/FreeBSD-14.1-RELEASE-amd64-disc1.iso"
  iso_checksum      = "sha256:5321791bd502c3714850e79743f5a1aedfeb26f37eeed7cb8eb3616d0aebf86b"
  efi_firmware_code = "../Firmware/code-freebsd-amd64.img"
  efi_firmware_vars = "../Firmware/vars-freebsd-amd64.img"
  output_directory  = "image_freebsd_amd64"
  qemu_binary       = "qemu-system-x86_64"
  disk_size         = "2G"
  format            = "raw"
  display           = "cocoa"
  ssh_username      = "root"
  ssh_password      = "packer"
  ssh_timeout       = "20m"
  vm_name           = "freebsd.img"
  net_device        = "virtio-net-pci"
  disk_interface    = "virtio"
  boot_wait         = "5s"
  http_directory    = "http_freebsd"
  shutdown_command  = "poweroff"

  qemuargs = [
    ["-machine", "q35,accel=tcg"],
    ["-cpu", "max"],
    ["-smp", "4"],
    ["-boot", "strict=off"],
    ["-device", "qemu-xhci"],
    ["-device", "usb-kbd"],
    ["-device", "usb-tablet"],
    ["-device", "intel-hda"],
    ["-device", "hda-duplex"]
  ]

  boot_command = [
    "<esc><wait>", 
    "boot -s<enter>", 
    "<wait15s>", 
    "/bin/sh<enter><wait>", 
    "mdmfs -s 100m md /tmp<enter><wait>", 
    "dhclient -l /tmp/dhclient.lease.vtnet0 vtnet0<enter><wait5>", 
    "fetch -o /tmp/installerconfig http://{{ .HTTPIP }}:{{ .HTTPPort }}/installerconfig<enter><wait5>",
    "bsdinstall script /tmp/installerconfig<enter>"
  ]
}

build {
  name = "build-freebsd"
  sources = [
    "source.qemu.freebsd"
  ]
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; env {{ .Vars }} {{ .Path }}"
    scripts = [
      "shell/freebsd-update.sh",
      "shell/freebsd-install.sh",
      "shell/freebsd-cleanup.sh"
    ]
  }

}