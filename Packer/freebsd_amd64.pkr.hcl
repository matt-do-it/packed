packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "freebsd" {
  iso_url           = "/Users/herold/Downloads/FreeBSD-14.1-RELEASE-amd64-zfs.raw"
  iso_checksum      = "sha256:8322798d11a794f8bb99ce2e620af7a315fb085993ad7184b989bac723b13ef7"
  disk_image        = true
  efi_firmware_code = "../Firmware/code-freebsd-amd64.img"
  efi_firmware_vars = "../Firmware/vars-freebsd-amd64.img"
  output_directory  = "image_freebsd_amd64"
  qemu_binary       = "qemu-system-x86_64"
  disk_size         = "8G"
  format            = "raw"
  display           = "cocoa"
  ssh_username      = "root"
  ssh_password      = "packer"
  ssh_timeout       = "20m"
  vm_name           = "freebsd.img"
  net_device        = "virtio-net-pci"
  disk_interface    = "virtio"
  boot_wait         = "5s"
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
    "boot<enter>",
    "<wait30s>",
    "root<enter>",
    "service sshd enable<enter>",
    "passwd<enter>",
    "packer<enter>",
    "packer<enter>",
    "sed -i '' -e 's/^#PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config<enter>",
    "service sshd start<enter>"
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