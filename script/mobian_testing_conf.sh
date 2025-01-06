#!/bin/bash

# Configurazione iniziale
FIRSTUSER=$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')
DEVICE="/dev/mmcblk1"
LAYOUT="it"
UUID=$(blkid -s UUID -o value /dev/mmcblk1p1)

# Funzione per disabilitare il sudo
sudodisable() {
    sudo passwd root
    sudo deluser "$FIRSTUSER" sudo
    su -
    reboot
}

# Funzione per estendere la partizione (se necessario)
rootextend() {
    apt-get install cloud-guest-utils -y
    growpart /dev/mmcblk2 2
    cryptsetup luksOpen /dev/mmcblk2p2 calamares_crypt || true
    cryptsetup resize calamares_crypt || true
    resize2fs /dev/mapper/calamares_crypt
    reboot
}

# Funzione per aggiornare e installare i pacchetti principali
apt_update_install() {
    apt-get update
    apt-get upgrade -y
    apt-get install aptitude -y
    aptitude install ssh wget rsync rsyslog screen \
        apt-transport-https curl ca-certificates \
        tcpdump adb python3-pip python3-venv python3-full lshw -y
}

# Funzione per installare il software comune
software_common() {
    aptitude install thunderbird-l10n-"$LAYOUT" bleachbit chromium \
        libreoffice libreoffice-l10n-"$LAYOUT" git transmission amule \
        chromium chromium-l10n -y
}

# Funzione per installare il software Plasma
software_plasma() {
    apt-get install kate kvirc dolphin -y
}

# Funzione per installare il software Posh
software_posh() {
    apt-get install hexchat -y
}

# Funzione per configurare la data e l'ora
set_time() {
    timedatectl set-timezone Europe/Rome
    timedatectl set-ntp true
}

# Funzione per configurare la lingua e la tastiera
locale_config() {
    sudo sed -i 's/\(XKBLAYOUT="\)[^"]*/\1'"$LAYOUT"'/' /etc/default/keyboard
    echo 'LANG="it_IT.UTF-8"' | tee -a /etc/default/locale
}

# Funzione per disabilitare la sospensione
disablesuspend() {
    sed -i 's/^#AllowSuspend=yes/AllowSuspend=no/' /etc/systemd/sleep.conf
}

# Funzione per installare vim e configurarlo
install_vim() {
    aptitude install vim -y
    mkdir -p /home/"$FIRSTUSER"/.vim
    cp ../vim/.vimrc /home/"$FIRSTUSER"/
    cp -r ../vim/* /home/"$FIRSTUSER"/.vim/
}

# Funzione per installare e configurare Waydroid
install_waydroid() {
    curl -s https://repo.waydro.id/ | bash
    aptitude install waydroid -y
    waydroid init
    systemctl enable waydroid-container
    systemctl restart waydroid-container
}

# Funzione per installare Charles Proxy
install_proxy_charles() {
    wget -qO- https://www.charlesproxy.com/packages/apt/charles-repo.asc | tee /etc/apt/keyrings/charles-repo.asc
    echo "deb [signed-by=/etc/apt/keyrings/charles-repo.asc] https://www.charlesproxy.com/packages/apt/ charles-proxy main" | sudo tee /etc/apt/sources.list.d/charles.list
    apt-get update && sudo apt-get install charles-proxy
}

# Funzione per configurare il certificato SSL per Charles su Waydroid
config_charles() {
    curl -O http://chls.pro/charles-ssl-proxying-certificate.pem
    waydroid container restart
    adb kill-server
    adb start-server
    adb push charles-ssl-proxying-certificate.pem /sdcard/
}

# Funzione per formattare e montare la scheda SD
sdcardformat() {
    echo "Eliminazione di tutte le partizioni..."
    yes | sfdisk --delete "$DEVICE"
    echo "Creazione di una nuova tabella delle partizioni GPT..."
    parted "$DEVICE" mklabel gpt --script
    echo "Creazione di una nuova partizione..."
    parted "$DEVICE" mkpart primary ext4 0% 100% --script
    echo "Aggiornamento della tabella delle partizioni..."
    partprobe "$DEVICE"
    echo "Formattazione della partizione come ext4..."
    mkfs.ext4 "$DEVICE"p1
    echo "Operazione completata con successo!"
}

# Funzione per montare la scheda SD
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

# Funzione per eseguire tutto il processo di configurazione della scheda SD
installsd() {
    sdcardformat
    sdcardmount
}

# Funzione per testare variabili e configurazioni
test_config() {
    echo "User: $FIRSTUSER"
    echo "Device: $DEVICE"
    echo "Layout: $LAYOUT"
}

# Funzione per installare Plasma
install_plasma() {
    apt_update_install
    software_common
    software_plasma
    social
    set_time
    locale_config
    disablesuspend
    install_vim
    install_waydroid
    sudodisable
    apt-get dist-upgrade -y
    reboot
}

# Funzione per installare Posh
install_posh() {
    apt_update_install
    software_common
    software_posh
    social
    set_time
    locale_config
    disablesuspend
    install_vim
    install_waydroid
    sudodisable
    apt-get dist-upgrade -y
    reboot
}

# Funzione per mettere il sistema in modalità sicura (disabilita SSH)
secure() {
    systemctl stop ssh.service
    systemctl disable ssh.service
    systemctl disable --now ssh.service
    systemctl daemon-reload
}

# Script principale che permette l'esecuzione delle funzioni
case "$1" in
    sudodisable)
        sudodisable
        ;;
    rootextend)
        rootextend
        ;;
    apt)
        apt_update_install
        ;;
    software_common)
        software_common
        ;;
    software_plasma)
        software_plasma
        ;;
    software_posh)
        software_posh
        ;;
    social)
        social
        ;;
    time)
        set_time
        ;;
    locale)
        locale_config
        ;;
    disablesuspend)
        disablesuspend
        ;;
    vim)
        install_vim
        ;;
    waydroid)
        install_waydroid
        ;;
    proxy_charles)
        install_proxy_charles
        ;;
    configcharles)
        config_charles
        ;;
    sdcardformat)
        sdcardformat
        ;;
    sdcardmount)
        sdcardmount
        ;;
    installs)
        installsd
        ;;
    test)
        test_config
        ;;
    install_plasma)
        install_plasma
        ;;
    install_posh)
        install_posh
        ;;
    secure)
        secure
        ;;
    *)
        echo "Comando non riconosciuto."
        ;;
esac

