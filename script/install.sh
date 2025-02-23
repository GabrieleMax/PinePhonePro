#!/bin/bash
## Run as sudo or root                                    

# Display the ASCII splashscreen
echo -e "\n\n"
cat splash_screen.txt  

# Find the user with UID 1000 (first non-root user)
FIRSTUSER=$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')                                                                

# URLs for different operating systems
deb_testing_url="https://images.mobian-project.org/pinephonepro/installer/weekly/"
arch_url="https://github.com/dreemurrs-embedded/Pine64-Arch/releases/"
kali_nethunter_url=$(lynx -dump -listonly -nonumbers https://kali.download/nethunterpro-images/ | sort -r | head -n 1)

# Verifica se il file disclaimer.txt esiste
if [ ! -f disclaimer.txt ]; then
    echo "Error: disclaimer.txt not found!"
    exit 1
fi

# Load  disclaimer
echo -e "\n\n"
cat disclaimer.txt

# Prompt per l'utente
echo "Press 'y' to continue or any other key to exit."

# Lettura dell'input dell'utente
read -p "Continue? (y/n): " user_input

# Controlla se l'utente ha premuto 'y' o 'Y'
if [[ "$user_input" != "y" && "$user_input" != "Y" ]]; then
    echo "Exiting the script."
    exit 1
fi

# Display the initial message
echo -e "\n\nConnect the PinePhone Pro (press the volume up button until the LED turns blue):"

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

# Retrieve the list of downloadable files from the websites, sort them, and take the latest one
deb_testing_posh=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
deb_testing_plasma=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.img.xz' | sort -r | head -n 1)
arch_testing_posh=$(curl -s "$arch_url" | grep -oP 'archlinux-pinephone-pro-phosh-\d{8}.img.xz' | sort -r | head -n 1)
#kali_nethunter=$(wget -q -O - "$kali_nethunter_url" | grep -oP 'kali-nethunterpro-\d{4}\.\d{2}-pinephonepro\.img\.xz' | sort -r | head -n 1)
#kali_nethunter=$(curl -O ${kali_nethunter_url}$(curl -s ${kali_nethunter_url} | grep -oP 'kali-nethunterpro-\d{4}\.\d{1,2}-pinephonepro\.img\.xz' | sort -r | head -n 1))
kali_nethunter="${kali_nethunter_url}$(curl -s ${kali_nethunter_url} | grep -oP 'kali-nethunterpro-\d{4}\.\d{1,2}-pinephone\.img\.xz' | sort -r | head -n 1)"

# Function to download Debian testing image with Phosh for PinePhone Pro
deb_img_testing_posh() {
    if [ -z "$deb_testing_posh" ]; then
        echo "File not found."
        return 1  # Termina solo la funzione, lo script continua
    fi  

    if [ -f "/tmp/$deb_testing_posh" ]; then
        echo "File already exists in /tmp/. Skipping download."
    else
        echo "Latest file found: $deb_testing_posh"
        wget --progress=dot -c -d --timeout=60 --tries=3 -O "/tmp/$deb_testing_posh" "$deb_testing_url$deb_testing_posh"

        if [ $? -eq 0 ]; then
            echo "Download complete: $deb_testing_posh"
        else
            echo "Download failed."
            return 1
        fi
    fi
}

# Function to check Mobian testing image with Posh for PinePhone Pro signature
deb_img_testing_posh_sig() {
    deb_testing_posh_shasums=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-posh-\d{8}.sha256sums' | sort -r | head -n 1)
    deb_testing_posh_shasig=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-posh-\d{8}.sha256sums.sig' | sort -r | head -n 1)
    deb_testing_posh_imgbmap=$(curl -s "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-posh-\d{8}.img.bmap' | sort -r | head -n 1)

    wget -q -P /tmp "$deb_testing_url$deb_testing_posh_shasums"
    wget -q -P /tmp "$deb_testing_url$deb_testing_posh_shasig"
    wget -q -P /tmp "$deb_testing_url$deb_testing_posh_imgbmap"

    # SHA256SUM check
    if sha256sum -c "/tmp/$deb_testing_posh_shasums" 2>&1 | grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Verifica se il file esiste prima di spostarlo
        if [ -f "/tmp/$deb_testing_posh" ]; then
            mv "/tmp/$deb_testing_posh" "/tmp/image.xz"
            
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

    wget -q -P /tmp "$deb_testing_url$deb_testing_plasma_shasums"
    wget -q -P /tmp "$deb_testing_url$deb_testing_plasma_shasig"
    wget -q -P /tmp "$deb_testing_url$deb_testing_plasma_imgbmap"

    # SHA256SUM check
    if sha256sum -c "/tmp/$deb_testing_plasma_shasums" 2>&1 | grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Verifica se il file esiste prima di spostarlo
        if [ -f "/tmp/$deb_testing_plasma" ]; then
            mv "/tmp/$deb_testing_plasma" "/tmp/image.xz"
            
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
}

# Function to download the latest Arch Linux image for PinePhone Pro
arch_img_testing_posh() {
    if [ -n "$arch_testing_posh" ]; then
        echo "Latest Arch Linux file found: $arch_testing_posh"
        wget --progress=dot -c -d --timeout=60 --tries=3 "$arch_url$arch_testing_posh" -O "/tmp/image.xz"
        echo "Download complete: $arch_testing_posh"
        img_burn  # Automatically call the burn function after downloading
        exit  # Exit after burn
    else
        echo "Arch Linux file not found."
    fi
}

# Function to download the latest Kali Nethunter image for PinePhone Pro
kali_nethunter_posh_img() {
    echo "Trying to download the Kali Nethunter image..."
    kali_nethunter="${kali_nethunter_url}$(curl -s ${kali_nethunter_url} | grep -oP 'kali-nethunterpro-\d{4}\.\d{1,2}-pinephonepro\.img\.xz' | sort -r | head -n 1)"
    if [ -n "$kali_nethunter" ]; then
        echo "Latest Kali Nethunter image found: $kali_nethunter"
        wget --progress=dot -c -d --timeout=60 --tries=3 "$kali_nethunter" -O "/tmp/image.xz"
        echo "Download complete: $kali_nethunter"
        img_burn  # Automatically call the burn function after downloading
        exit  # Exit after burn
    else
        echo "Kali Nethunter image not found. Please check the URL and file availability."
    fi  
}

# Function to burn the image to the device
img_burn() {
    # Check if device_name is set and not empty
    if [ -z "$device_name" ]; then
        echo "Device name not set. Exiting."
        exit 1
    fi

    # Confirm the device where the image will be written
    echo "The disk that will be erased is: /dev/$device_name"

    # Check if the device exists and is accessible
    if [ ! -b "/dev/$device_name" ]; then
        echo "Error: Device /dev/$device_name is not available."
        exit 1
    fi

    # Write the image to the device
    echo "Writing image to /dev/$device_name..."
    cat "/tmp/image.xz" | unxz -c > /tmp/image.img
    sudo dd if=/tmp/image.img of=/dev/$device_name bs=4M status=progress conv=fsync,notrunc iflag=direct oflag=direct
    echo "Writing process complete."

    # Ensure script exits after burning process
    exit 0
}

# Menu with the correct options
PS3="Choose an option (1-5): "
select menu in "Download and install Debian testing with Plasma mobile" \
               "Download and install Debian testing with Phosh mobile" \
               "Download and install Arch Linux with Phosh" \
               "Download and install Kali Nethunter Linux with Phosh" \
               "Exit"; do
    case $menu in
        "Download and install Debian testing with Plasma mobile")
            deb_img_testing_plasma 
            deb_img_testing_plasma_sig
            img_burn 
            ;;
        "Download and install Debian testing with Phosh mobile")
            deb_img_testing_posh
            deb_img_testing_posh_sig
            img_burn 
            ;;
        "Download and install Arch Linux with Phosh")
            arch_img_testing_posh
            ;;
        "Download and install Kali Nethunter Linux with Phosh")
            kali_nethunter_posh_img
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

