#!/bin/bash
## Last update 22/12/2024 ##                                   
## Before to start the script connect the device by usb to the laptop

FIRSTUSER=$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')                                                                
DEVICE=/dev/mmcblk1
LAYOUT=it
#UUID=$(blkid -s UUID -o value /dev/mmcblk1p1)
#MOBIANIMG=$(find /tmp/ -iname "*mobian-installer*.xz" | grep -v "/\.local/")
# Url of the website with image links
url="https://images.mobian-project.org/pinephonepro/installer/weekly/"

# Recover the list of files from the website
# wget -q is quiet option, -O output file but - means the output file content is tranfered to the pipe |
# grep -o will print just the searche pattern -P is pearl regex and \d{8} means eight numbers
# sort -r the first line will be the latest
# head -n 1 shows just the first line
deb_testing_posh=$(wget -q -O - "$url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
deb_testing_plasma=$(wget -q -O - "$url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.img.xz' | sort -r | head -n 1)

# Mobian testing posh image download
deb_img_testing_posh() {
    # If the variable is not empty starts the script.
if [ -n "$deb_testing_posh" ]; then
    echo "File founded: $deb_testing_posh"
    
    # Download the file
    wget --progress=dot "$url$deb_testing_posh" -O "/tmp/image.xz"
    echo "Download finished: $deb_testing_posh"
else
    echo "File not found."
fi
}

# Mobian testing plasma image download
deb_img_testing_plasma() {
    # If the variable is not empty starts the script.
if [ -n "$deb_testing_plasma" ]; then
    echo "File più recente trovato: $deb_testing_plasma"
    
    # Download the file
    wget --progress=dot "$url$deb_testing_plasma" -O "/tmp/image.xz"
    echo "Download finished: $deb_testing_plasma"
else
    echo "File not found."
fi
}

# Image burn
img_burn() {
  lsblk
  bash -c '\
  read -p "Insert the name of the disk which will be erased (e.g., sdb): " diskname; \
  echo "The disk which will be erased is /dev/$diskname"; \
  echo "The diskname is $diskname"; \
  # Umount all disk partitions \
  #for part in $(lsblk -no NAME,MOUNTPOINT | grep "/dev/$diskname" | awk "{print $1}"); do \
  # umount /dev/$part || true; \
  #done; \
  # Deactive LUKS volumes \
  #cryptsetup luksClose /dev/$diskname || true; \
  '
  pv "/tmp/image.xz" | unxz -c > /tmp/image.img
  sudo dd if=/tmp/image.img of=/dev/sdb bs=4M status=progress conv=noerror,sync
}          

# Verifica se è stato trovato un file
if [ -n "$latest_file" ]; then
    echo "File più recente trovato: $latest_file"
    
    # Scarica il file
    wget --progress=dot "$url$latest_file" -O "/tmp/$latest_file"
    echo "Download completato: $latest_file"
else
    echo "Nessun file trovato."
fi

# Funzione per scaricare l'immagine
scarica_immagine() {
    echo "Scaricamento dell'immagine..."
    # Aggiungi qui il comando per scaricare l'immagine, ad esempio:
    # wget http://esempio.com/immagine.iso
}

# Funzione per visualizzare informazioni
visualizza_info() {
    echo "Visualizzazione delle informazioni..."
    # Aggiungi qui il comando per visualizzare le informazioni, ad esempio:
    # df -h
}

# Menu
PS3="Scegli un'opzione (1-3): "
select menu in "Download and install Debian testing with Plasma mobile" \
               "Download and install Debian testing with Posh mobile" \
               "Image burn" \
               "Esci"; do
    case $menu in
        "Download and install Debian testing with Plasma mobile")
            deb_img_testing_plasma img_burn
            ;;
        "Scarica immagine")
            deb_img_testing_posh img_burn
            ;;
        "Image burn")
            img_burn
            ;;
        "Esci")
            echo "Uscita dallo script."
            break
            ;;
        *)
            echo "Scelta non valida. Riprova."
            ;;
    esac
done

