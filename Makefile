
.PHONY: download-firmware

download-firmware:
	sh download-firmware.sh
	
freebsd-aarch64: 
	sh freebsd-aarch64-firmware.sh
	cd Packer && packer build freebsd_aarch64.pkr.hcl


freebsd-amd64: 
	sh freebsd-amd64-firmware.sh
	cd Packer && packer build freebsd_amd64.pkr.hcl

ubuntu-amd64: 
	sh ubuntu-amd64-firmware.sh
	cd Packer && packer build ubuntu_amd64.pkr.hcl

		