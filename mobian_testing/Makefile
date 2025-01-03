## Last update 22/12/2024 - Mobian Trixie with Plasma or Posh Mobile, select the right install ###
## Power off the phone and connect it by usb to the laptop
## Press vol+ untill the status led will be blue;

FIRSTUSER=$(shell grep "1000" /etc/passwd | awk -F ':' '{print $$1}')
DEVICE=/dev/mmcblk1
LAYOUT=it
UUID=$(shell blkid -s UUID -o value /dev/mmcblk1p1)
#MOBIANIMG=$(shell find /tmp/ -iname "*mobian-installer*.xz" | grep -v "/\.local/")

sudodisable:
	sudo passwd root
	sudo deluser $(FIRSTUSER) sudo
	su -
	reboot

## Just if needed - Extend on-board partition run as sudo or root
rootextend:
	apt-get install cloud-guest-utils -y
	growpart /dev/mmcblk2 2
	cryptsetup luksOpen /dev/mmcblk2p2 calamares_crypt || true
	cryptsetup resize calamares_crypt || true
	resize2fs /dev/mapper/calamares_crypt
	reboot

apt:
	apt-get update
	apt-get upgrade -y
	apt-get install aptitude -y
	#aptitude install --reinstall console-setup kbd
	aptitude install ssh wget rsync rsyslog screen \
	apt-transport-https curl ca-certificates \
	tcpdump adb python3-pip python3-venv python3-full lshw -y

software_common:
	aptitude install thunderbird-l10n-$(LAYOUT) bleachbit chromium \
	libreoffice libreoffice-l10n-$(LAYOUT) git transmission amule \
	chromium chromium-l10n -y

software_plasma:
	apt-get install kate kvirc dolphin -y

software_posh:
	apt-get install hexchat -y

social:
	#wget -O signal.deb https://github.com/0mniteck/Signal-Desktop-Mobian/raw/master/builds/release/signal-desktop_7.23.0_arm64.deb
	#dpkg -i signal.deb
	#wget -O axolotl.tar.gz https://github.com/axolotl-chat/axolotl/archive/refs/tags/v2.0.4.tar.gz
	#mkdir -p axolotl
	#tar --strip-components=1 -xvzf axolotl.tar.gz -C axolotl
	#cd axolotl
	#cargo install tauri-cli
	#cargo tauri build --features tauri --bundles deb
	#apt install ./target/release/bundle/deb/*.deb
	#wget https://telegram.org/dl/desktop/linux/tsetup.5.5.3.tar.xz
	#tar -xvf tsetup.5.5.3.tar.xz

time:
	timedatectl set-timezone Europe/Rome
	timedatectl set-ntp true
	#timedatectl set-local-rtc 1

locale:
	sudo sed -i 's/\(XKBLAYOUT="\)[^"]*/\1$(LAYOUT)/' /etc/default/keyboard
	echo 'LANG="it_IT.UTF-8"' | tee -a /etc/default/locale
	#localectl set-x11-keymap it pc105

disablesuspend:
	sed -i 's/^#AllowSuspend=yes/AllowSuspend=no/' /etc/systemd/sleep.conf

vim:
	aptitude install vim -y
	mkdir -p /home/$(FIRSTUSER)/.vim
	cp vim/.vimrc /home/$(FIRSTUSER)/
	cp -r vim/* /home/$(FIRSTUSER)/.vim/

# Inside Waydroid download F-Droid (search it by the web browser) and after it search and install Aurora app
waydroid:
	curl -s https://repo.waydro.id/ | bash
	aptitude install waydroid -y
	waydroid init
	systemctl enable waydroid-container
	systemctl restart waydroid-container

# Install proxy
# To start charles proxy run java --add-opens java.base/sun.security.ssl=ALL-UNNAMED -jar /usr/lib/charles-proxy/charles.jar
proxy_charles:
	wget -qO- https://www.charlesproxy.com/packages/apt/charles-repo.asc | tee /etc/apt/keyrings/charles-repo.asc
	echo "deb [signed-by=/etc/apt/keyrings/charles-repo.asc] https://www.charlesproxy.com/packages/apt/ charles-proxy main" | sudo tee /etc/apt/sources.list.d/charles.list
	apt-get update && sudo apt-get install charles-proxy

#proxy_mitm:


# Copy ssl cert to waydroid
configcharles:
	curl -O http://chls.pro/charles-ssl-proxying-certificate.pem
	waydroid container restart
	adb kill-server
	adb start-server
	adb push charles-ssl-proxying-certificate.pem /sdcard/

# Setup the sd card if it is present

sdcardformat:
	#umount $(DEVICE)p1
	@echo "Eliminazione di tutte le partizioni..."
	@yes | sfdisk --delete $(DEVICE)
	@echo "Creazione di una nuova tabella delle partizioni GPT..."
	@parted $(DEVICE) mklabel gpt --script
	@echo "Creazione di una nuova partizione..."
	@parted $(DEVICE) mkpart primary ext4 0% 100% --script
	@echo "Aggiornamento della tabella delle partizioni..."
	@partprobe $(DEVICE)
	@echo "Formattazione della partizione come ext4..."
	@mkfs.ext4 $(DEVICE)p1
	@echo "Operazione completata con successo!"

sdcardmount: 
	mkdir -p /mnt/sdcard
	@UUID=$$(blkid -s UUID -o value /dev/mmcblk1p1); \
	PARTUUID=$$(blkid -s PARTUUID -o value /dev/mmcblk1p1); \
	sed -i '/\/dev\/mmcblk1p1/ d' /etc/fstab; \
	echo "UUID=$$UUID /mnt/sdcard ext4 defaults 0 2" >> /etc/fstab
	systemctl daemon-reload
	mount /mnt/sdcard	
	mount -a
	chown $(FIRSTUSER):root /mnt/sdcard/
	systemctl daemon-reload

installsd: sdcardformat sdcardmount 

test:
	@echo $(FIRSTUSER)
	@echo $(DEVICE)
	@echo $(LAYOUT)

## Fourth step, select preferred desktop environment, plasma or posh
install_plasma: apt software_common software_plasma social time locale disablesuspend vim waydroid sudodisable
	apt-get dist-upgrade -y
	reboot

install_posh: apt software_common software_posh social time locale disablesuspend vim waydroid sudodisable
	apt-get dist-upgrade -y
	reboot

secure:
	systemctl stop ssh.service
	systemctl disable ssh.service
	systemctl disable --now ssh.service
	systemctl daemon-reload

