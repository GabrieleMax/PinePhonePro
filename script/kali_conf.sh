#!/bin/bash
# Run as sudo or root

# Variables
FIRSTUSER=$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')
DEVICE="/dev/mmcblk1"
LAYOUT="it"
UUID=$(blkid -s UUID -o value /dev/mmcblk1p1)

# Function for basic installation
apt_update_upgrade() {
    apt-get update
    apt-get upgrade -y
    apt-get install aptitude -y
    aptitude install ssh wget rsync rsyslog screen \
    apt-transport-https curl ca-certificates \
    tcpdump adb python3-pip python3-venv python3-full lshw -y
}

# Function for common software
software_common() {
    aptitude install thunderbird-l10n-"$LAYOUT" bleachbit chromium \
    libreoffice libreoffice-l10n-"$LAYOUT" git transmission amule \
    chromium chromium-l10n -y
}

# Function for Posh software
software_posh() {
    apt-get install hexchat -y
}

# Function to set the timezone
set_time() {
    timedatectl set-timezone Europe/Rome
    timedatectl set-ntp true
}

# Function to set the locale
set_locale() {
    sudo sed -i "s/\(XKBLAYOUT=\"\)[^\"]*/\1$LAYOUT/" /etc/default/keyboard
    echo 'LANG="it_IT.UTF-8"' | tee -a /etc/default/locale
}

# Function to disable suspend
disablesuspend() {
    sed -i 's/^#AllowSuspend=yes/AllowSuspend=no/' /etc/systemd/sleep.conf
}

# Function to configure Vim
install_vim() {
    aptitude install vim -y
    mkdir -p /home/"$FIRSTUSER"/.vim
    cp ../vim/.vimrc /home/"$FIRSTUSER"/
    cp -r ../vim/* /home/"$FIRSTUSER"/.vim/
}

# Function to install Waydroid
waydroid_install() {
    curl -s https://repo.waydro.id/ | bash
    aptitude install waydroid -y
    waydroid init
    systemctl enable waydroid-container
    systemctl restart waydroid-container
}

# Function to install Charles Proxy
install_proxy_charles() {
    wget -qO- https://www.charlesproxy.com/packages/apt/charles-repo.asc | tee /etc/apt/keyrings/charles-repo.asc
    echo "deb [signed-by=/etc/apt/keyrings/charles-repo.asc] https://www.charlesproxy.com/packages/apt/ charles-proxy main" | sudo tee /etc/apt/sources.list.d/charles.list
    apt-get update && sudo apt-get install charles-proxy
}

# Function to configure Charles Proxy on Waydroid
configcharles() {
    curl -O http://chls.pro/charles-ssl-proxying-certificate.pem
    waydroid container restart
    adb kill-server
    adb start-server
    adb push charles-ssl-proxying-certificate.pem /sdcard/
}

# Function to format the SD card
sdcardformat() {
    echo "Deleting all partitions..."
    yes | sfdisk --delete "$DEVICE"
    echo "Creating a new GPT partition table..."
    parted "$DEVICE" mklabel gpt --script
    echo "Creating a new partition..."
    parted "$DEVICE" mkpart primary ext4 0% 100% --script
    echo "Updating the partition table..."
    partprobe "$DEVICE"
    echo "Formatting the partition as ext4..."
    mkfs.ext4 "$DEVICE"p1
    echo "Operation completed successfully!"
}

# Function to mount the SD card
sdcardmount() {
    mkdir -p /mnt/sdcard
    UUID=$(blkid -s UUID -o value /dev/mmcblk1p1)
    PARTUUID=$(blkid -s PARTUUID -o value /dev/mmcblk1p1)
    sed -i '/\/dev\/mmcblk1p1/ d' /etc/fstab
    echo "UUID=$UUID /mnt/sdcard ext4 defaults 0 2" >> /etc/fstab
    systemctl daemon-reload
    mount /mnt/sdcard
    mount -a
    chown "$FIRSTUSER":root /mnt/sdcard/
    systemctl daemon-reload
}

# Function to install SD card
install_sd() {
    sdcardformat
    sdcardmount
}

# Function to install Posh
install_posh() {
    apt_update_upgrade
    software_common
    software_posh
    set_time
    set_locale
    disablesuspend
    install_vim
    apt-get dist-upgrade -y
    reboot
}

# Function to disable sudo and enable root
disable_sudo() {
    echo "Disabling sudo and enabling root..."
    sudo passwd root
    sudo deluser "$FIRSTUSER" sudo
    echo "Sudo has been disabled and root password has been set."
    su -
    reboot
}

# Disable SSH 
disable_ssh() {
    systemctl stop ssh.service
    systemctl disable ssh.service
    systemctl disable --now ssh.service
    systemctl daemon-reload
}

# Secure the system
secure_system() {
    disable_ssh
    disable_sudo
}

# Function to display the menu
show_menu() {
    echo "Choose one of the following options:"
    echo "1) Kali Nethunter posh tuning"
    echo "2) Install Waydroid"
    echo "3) System secure (exectute it as last choice)"
    echo "4) Install SD Card"
    echo "5) Exit"
}

# Function to handle user choice
get_user_choice() {
    read -p "Enter the number of the option: " choice
    case $choice in
        1) install_posh ;;
        2) waydroid_install ;;
        3) secure_system ;;
        4) install_sd ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again."; get_user_choice ;;
    esac
}

# Main function to run the script
main() {
    while true; do
        show_menu
        get_user_choice
    done
}

# Run the main function
main

