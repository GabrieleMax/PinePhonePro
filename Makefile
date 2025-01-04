## Last update 03/01/2024 - Mobian Trixie with Plasma or Posh Mobile, select the right install ###
## First step - Run install_img to burn the image to the phone (run it as root)
## Second step - Power off the phone and connect it by usb to the laptop
## Third step - Press vol+ untill the status led will be blue;

FIRSTUSER=$(shell grep "1000" /etc/passwd | awk -F ':' '{print $$1}')
DEVICE=/dev/mmcblk1
LAYOUT=it
UUID=$(shell blkid -s UUID -o value /dev/mmcblk1p1)
#MOBIANIMG=$(shell find /tmp/ -iname "*mobian-installer*.xz" | grep -v "/\.local/")

install_img:
	bash ./script/install_img.sh

install_distribution:
	bash distribution_selection.sh 

#config_distribution:

## Deploy to the phone
deploy:
	@bash -c ' \
	read -p "Insert the PinePhone ip address: " remoteip; \
	read -p "Insert the PinePhone ssh port: " sshport; \
	read -p "Insert the PinePhone username: " remoteuser; \
	echo "The PinePhone ip address is $$remoteip and the remote ssh port is $$sshport" the remote user is $$remoteuser; \
	rsync --exclude '*.swp' -avzh -e "ssh -p $$sshport" . $$remoteuser@$$remoteip:install; \
	'
