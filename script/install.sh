#!/bin/bash
## Run as sudo or root                                    

# Display the ASCII splashscreen
echo -e "\n\n"
cat splash_screen.txt  

# URLs for different operating systems
deb_keyring="https://salsa.debian.org/Mobian-team/mobian-keyring/-/raw/509d5fae1ac9bb1aa8e9d9bd446dbac3f9588c49/mobian-archive-keyring.gpg"
deb_testing_url="https://images.mobian.org/pinephonepro/installer/weekly/"
arch_url="https://github.com/dreemurrs-embedded/Pine64-Arch/releases/download/20241223/"
arch_img=$(curl -s https://github.com/dreemurrs-embedded/Pine64-Arch/releases/ | grep -oP 'href="/dreemurrs-embedded/Pine64-Arch/releases/download/[^"]*archlinux-pinephone-pro-phosh[^"]*\.img\.xz"' | sed -E 's/^href=".*\/([^"]*)"/\1/' | sort -r | head -n 1)
kali_nethunter_url=$(lynx -dump -listonly -nonumbers https://kali.download/nethunterpro-images/ | sort -r | head -n 1)

# Verifica se il file disclaimer.txt esiste
if [ ! -f disclaimer.txt ]; then
    echo "Error: disclaimer.txt not found!"
    exit 1
fi

# Load  disclaimer
echo -e "\n\n"
cat disclaimer.txt

# User prompt
echo "Press 'y' to continue or any other key to exit."

# Read user input
while true; do
    read -p "Continue? (y/n): " user_input
    if [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
      break
    elif [[ "$user_input" == "n" || "$user_input" == "N" ]]; then
      echo "Bye bye! ;)"
        exit 0
    else
      echo "Input not valid."
    fi
done

# Continue the script
echo "Right answer: $user_input"

# Retrieve the list of downloadable files from the websites, sort them, and take the latest one
deb_testing_phosh=$(curl -s "$deb_testing_url" | grep -oP '(?<=href=")mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
deb_testing_plasma=$(curl -s "$deb_testing_url" | grep -oP '(?<=href=")mobian-installer-rockchip-plasma-mobile-\d{8}\.img\.xz' | sort -r | head -n 1)
#kali_nethunter=$(wget -q -O - "$kali_nethunter_url" | grep -oP 'kali-nethunterpro-\d{4}\.\d{2}-pinephonepro\.img\.xz' | sort -r | head -n 1)
#kali_nethunter=$(curl -O ${kali_nethunter_url}$(curl -s ${kali_nethunter_url} | grep -oP 'kali-nethunterpro-\d{4}\.\d{1,2}-pinephonepro\.img\.xz' | sort -r | head -n 1))
#kali_nethunter="${kali_nethunter_url}$(curl -s ${kali_nethunter_url} | grep -oP 'kali-nethunterpro-\d{4}\.\d{1,2}-pinephone\.img\.xz' | sort -r | head -n 1)"

# Function to download Mobian testing image with Phosh for PinePhone Pro
deb_img_testing_phosh() {
    if [ -z "$deb_testing_phosh" ]; then
        echo "The variable deb_testing_posh is empty."
        return 1  # Termina solo la funzione, lo script continua
    fi  

    if [ -f "/tmp/$deb_testing_phosh" ]; then
        echo "File already exists in /tmp/. Skipping download."
    else
        echo "Latest file found: $deb_testing_phosh"
        wget --progress=dot -c -d --timeout=60 --tries=3 -O "/tmp/$deb_testing_phosh" "$deb_testing_url$deb_testing_phosh"

        if [ $? -eq 0 ]; then
            echo "Download complete: $deb_testing_phosh"
        else
            echo "Download failed."
            return 1
        fi
    fi
}

# Function to check Mobian testing image with phosh for PinePhone Pro signature
deb_img_testing_phosh_sig() {
    deb_testing_phosh_shasums=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.sha256sums' | sort -r | head -n 1)
    deb_testing_phosh_shasig=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.sha256sums.sig' | sort -r | head -n 1)
    deb_testing_phosh_imgbmap=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.img.bmap' | sort -r | head -n 1)
    
    if [ -f /tmp/$deb_testing_phosh_shasums ] && [ -f /tmp/$deb_testing_phosh_shasig ] && [ -f /tmp/$deb_testing_phosh_imgbmap ]; then
      echo "Signature files already available and I don't download them."
    else
      echo "I'm going to download signature files."
    wget -q -P /tmp "$deb_testing_url$deb_testing_phosh_shasums"
    wget -q -P /tmp "$deb_testing_url$deb_testing_phosh_shasig"
    wget -q -P /tmp "$deb_testing_url$deb_testing_phosh_imgbmap"
    fi

# GPG download and import key
if [ -z "$deb_keyring" ]; then
    echo "Debian keyring variable URL not available"
    exit 1
  else
    if [ ! -f "/tmp/mobian-archive-keyring.gpg" ]; then
      echo "I'm going to download Debian keyring"
      wget -q -P /tmp "$deb_keyring"
    #gpg --import mobian-archive-keyring.gpg
    #gpg --list-keys --with-colons | grep "$(gpg --with-colons --import-options show-only --import mobian-archive-keyring.gpg | grep '^fpr' | cut -d: -f10)"
      else
        echo "Debian keyring already present"
    fi
    # GPG check key
    if gpg --verify "/tmp/$deb_testing_phosh_shasig" >/dev/null 2>&1; then
        echo "Valid GPG signature"
    else
        echo "GPG signature not valid"
        exit 1
    fi
fi

# SHA256SUM check
#( cd /tmp && sha256sum -c "$deb_testing_plasma_shasums" )
if [ ! -f "/tmp/$deb_testing_phosh" ]; then
  echo "Image not avalaible"
  exit 1
else
    if ( cd /tmp && sha256sum -c "$deb_testing_phosh_shasums" ) |  grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Verifica se il file esiste prima di spostarlo
        if [ -f "/tmp/$deb_testing_phosh" ]; then
            mv "/tmp/$deb_testing_phosh" "/tmp/image.xz"
            
            # Controlla se mv ha avuto successo
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /tmp."
            exit 1
        fi
    else
        echo "Signature failed: SHA256SUM verification did not pass."
        exit 1
    fi
fi
}

# Function to download Mobian testing image with Plasma for PinePhone Pro
deb_img_testing_plasma() {
    if [ -z "$deb_testing_plasma" ]; then
        echo "File not found."
        return 1  # Termina solo la funzione, lo script continua
    fi  

    if [ -f "/tmp/$deb_testing_plasma" ]; then
        echo "File already exists in /tmp/. Skipping download."
    else
        echo "Latest file found: $deb_testing_plasma"
        wget --progress=dot -c -d --timeout=60 --tries=3 -O "/tmp/$deb_testing_plasma" "$deb_testing_url$deb_testing_plasma"

        if [ $? -eq 0 ]; then
            echo "Download complete: $deb_testing_plasma"
        else
            echo "Download failed."
            return 1
        fi
    fi
}

# Function to check Mobian testing image with Plasma for PinePhone Pro signature
deb_img_testing_plasma_sig() {
    deb_testing_plasma_shasums=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.sha256sums' | sort -r | head -n 1)
    deb_testing_plasma_shasig=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.sha256sums.sig' | sort -r | head -n 1)
    deb_testing_plasma_imgbmap=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.img.bmap' | sort -r | head -n 1)
    
    if [ -f /tmp/$deb_testing_plasma_shasums ] && [ -f /tmp/$deb_testing_plasma_shasig ] && [ -f /tmp/$deb_testing_plasma_imgbmap ]; then
      echo "Signature files already available and I don't download them."
    else
      echo "I'm going to download signature files."
    wget -q -P /tmp "$deb_testing_url$deb_testing_plasma_shasums"
    wget -q -P /tmp "$deb_testing_url$deb_testing_plasma_shasig"
    wget -q -P /tmp "$deb_testing_url$deb_testing_plasma_imgbmap"
    fi

# GPG download and import key
if [ -z "$deb_keyring" ]; then
    echo "Debian keyring variable URL not available"
    exit 1
  else
    if [ ! -f "/tmp/mobian-archive-keyring.gpg" ]; then
      echo "I'm going to download Debian keyring"
      wget -q -P /tmp "$deb_keyring"
    #gpg --import mobian-archive-keyring.gpg
    #gpg --list-keys --with-colons | grep "$(gpg --with-colons --import-options show-only --import mobian-archive-keyring.gpg | grep '^fpr' | cut -d: -f10)"
      else
        echo "Debian keyring already present"
    fi
    # GPG check key
    if gpg --verify "/tmp/$deb_testing_plasma_shasig" >/dev/null 2>&1; then
        echo "Valid GPG signature"
    else
        echo "GPG signature not valid"
        exit 1
    fi
fi

# SHA256SUM check
#( cd /tmp && sha256sum -c "$deb_testing_plasma_shasums" )
if [ ! -f "/tmp/$deb_testing_plasma" ]; then
  echo "Image not avalaible"
  exit 1
else
  if ( cd /tmp && sha256sum -c "$deb_testing_plasma_shasums" 2>/dev/null ) |  grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Check if the file exist before to rename it
        if [ -f "/tmp/$deb_testing_plasma" ]; then
            mv "/tmp/$deb_testing_plasma" "/tmp/image.xz"
            
            # Check if the mv command status
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /tmp."
            exit 1
        fi
    else
        echo "Signature failed: SHA256SUM verification did not pass."
        exit 1
    fi
fi
}

# Function to download the latest Arch Linux image for PinePhone Pro
arch_img_phosh() {
    if [ -n "$arch_img" ]; then
        echo "Latest Arch Linux file found: $arch_img and I don't need to download it:"
        wget --progress=dot -c -d --timeout=60 --tries=3 -O "/tmp/$arch_img" "$arch_url$arch_img"
        echo "Download complete: $arch_img"
    else
        echo "Arch Linux file not found."
    fi
}

# Function to download the latest Kali Nethunter image for PinePhone Pro
kali_nethunter_phosh_img() {
    kali_nethunter_img="$(curl -s ${kali_nethunter_url} | grep -oP 'kali-nethunterpro-\d{4}\.\d{1,2}-pinephonepro\.img\.xz' | sort -r | head -n 1)"
    
    if [ -f "/tmp/$kali_nethunter_img" ]; then
        echo "Latest Kali Nethunter image founded and I don't need to download it."
      else
        echo "I'm going to download latest Kali Nethunter image:"
        wget --progress=dot -c -d --timeout=60 --tries=3 "$kali_nethunter_url$kali_nethunter_img" -P /tmp
        echo "Download complete: $kali_nethunter_img"
    fi  
}

# Function to check Kali Nethunter signature
kali_nethunter_phosh_sig() {

# Download SHA256SUMS    
    if [ -f /tmp/SHA256SUMS ]; then
      echo "Signature file already available and I don't download it."
    else
      echo "I'm going to download signature files."
    wget -q -P /tmp "${kali_nethunter_url}SHA256SUMS"
    fi

# SHA256SUM check
  if ( cd /tmp && sha256sum -c SHA256SUMS ) |  grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Check if the file exist before to rename it
        if [ -f "/tmp/$kali_nethunter_img" ]; then
            mv "/tmp/$kali_nethunter_img" "/tmp/image.xz"
            
            # Check if the mv command status
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /tmp."
            exit 1
        fi
    else
        echo "Signature failed: SHA256SUM verification did not pass."
        exit 1
    fi
}

devicecheck() {
# Display the initial message
echo -e "\n\nConnect the PinePhone Pro and after it press the volume up button until the LED turns blue or insert the microsd:"

# Save the initial list of devices (excluding partitions)
initial_devices=$(lsblk -dn -o NAME | sort)

# Continuously monitor for a new device
while true; do
    # Save the current list of devices (excluding partitions)
    current_devices=$(lsblk -dn -o NAME | sort)

    # Compare the current list with the initial list
    new_device=$(comm -13 <(echo "$initial_devices") <(echo "$current_devices"))

    # If a new device is found, take the desired action
    if [ -n "$new_device" ]; then
        echo "New device connected: $new_device"
        device_name="$new_device"  # Assign the device name to a variable
        break  # Exit the loop
    fi

    # Sleep to avoid consuming too much CPU
    sleep 1
done

# Now you can use the $device_name variable
echo "The connected device is: /dev/$device_name"
}

# Function to burn the image to the device
img_burn() {
    # Check if device_name is set and not empty
    if [ -z "$device_name" ]; then
        echo "Device name not set. Exiting."
        exit 1
    fi

    # Check if the device exists and if it is accessible
    if [ ! -b "/dev/$device_name" ]; then
        echo "Error: Device /dev/$device_name is not available."
        exit 1
    fi

    # Confirm the device where the image will be written
    echo "The disk that will be erased is: /dev/$device_name"

while true; do
    read -p "Continue? (y/n): " user_input
    if [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
      break
    elif [[ "$user_input" == "n" || "$user_input" == "N" ]]; then
      echo "Bye bye! ;)"
        exit 0
    else
      echo "Input not valid."
    fi  
done  

    # Write the image to the device
    echo "Writing image to /dev/$device_name wait few minutes..."
    cat "/tmp/image.xz" | unxz -c > /tmp/image.img
    sudo dd if=/tmp/image.img of=/dev/$device_name status=progress bs=4M conv=fdatasync iflag=sync
    echo "Writing process complete."

    # Ensure script exits after burning process
    exit 0
}

# Menu with the correct options
PS3="Choose an option (1-5): "
select menu in "Download and install Mobian testing with Plasma mobile" \
               "Download and install Mobian testing with Phosh mobile" \
               "Download and install Arch Linux with Phosh" \
               "Download and install Kali Nethunter Linux with Phosh" \
               "Exit"; do
    case $menu in
        "Download and install Mobian testing with Plasma mobile")
            deb_img_testing_plasma 
            deb_img_testing_plasma_sig
            devicecheck
            img_burn 
            ;;
        "Download and install Mobian testing with Phosh mobile")
            deb_img_testing_phosh
            deb_img_testing_phosh_sig
            devicecheck
            img_burn 
            ;;
       "Download and install Arch Linux with Phosh")
            arch_img_phosh
            ;;
        "Download and install Kali Nethunter Linux with Phosh")
            kali_nethunter_phosh_img
            kali_nethunter_phosh_sig
            devicecheck
            img_burn
            ;;
        "Exit")
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

