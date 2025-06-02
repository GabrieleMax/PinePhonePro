#!/bin/bash
## Run as sudo or root                                    

# Display the ASCII splashscreen
echo -e "\n\n"
cat splash_screen.txt  

# Download dir
DOWNLOAD_DIR=/tmp

# URLs for different operating systems
arch_img=$(curl -s https://github.com/dreemurrs-embedded/Pine64-Arch/releases/ | grep -o "archlinux-pinephone-pro-phosh-[0-9]\+.img.xz" | sort -r | head -n 1)
arch_img_date=$(echo $arch_img | grep -o '[0-9]\+')
arch_url="https://github.com/dreemurrs-embedded/Pine64-Arch/releases/download/${arch_img_date}/"
kali_nethunter_url=$(lynx -dump -listonly -nonumbers https://kali.download/nethunterpro-images/ | sort -r | head -n 1)
postmarketOS_plasma_lastdir=$(curl -s https://images.postmarketos.org/bpo/ | grep -o 'v[0-9]\+\.[0-9]\+' | sort -r | head -n 1)
postmarketOS_plasma_url="https://images.postmarketos.org/bpo/${postmarketOS_plasma_lastdir}/pine64-pinephonepro/plasma-mobile/"
postmarketOS_plasma_img_date=$(curl -s https://images.postmarketos.org/bpo/v24.12/pine64-pinephonepro/plasma-mobile/ | grep -oP "[0-9]{8}-[0-9]{4}/" | sort -r | head -n 1)
postmarketOS_plasma_img=$(curl -s "$postmarketOS_plasma_url$postmarketOS_plasma_img_date/" | grep -o '202[0-9]\{5\}-[0-9]\{4\}-postmarketOS-[^"]*\.img\.xz' | sort -r | head -n 1)

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

# Check internet link
while ! ping -c 1 8.8.8.8 &> /dev/null; do
  echo "Internet is not avalaible, please connect it if you want to download images."
  sleep 5
done

echo "Internet is avalaible and I can continue the script."

# Function to download the latest Arch Linux image for PinePhone Pro
arch_img_phosh() {
   if [ -f "/$DOWNLOAD_DIR/$arch_img" ]; then
        echo "File $arch_img already exists in /$DOWNLOAD_DIR/ skipping download."
    else
        echo "Latest Arch Linux file found: $arch_img"
        wget --progress=dot -c -d --timeout=60 --tries=3 -O "/$DOWNLOAD_DIR/$arch_img" "$arch_url$arch_img"
        echo "Download complete: $arch_img"
    fi
}

# Function to check Arch image signature
arch_img_phosh_sig() {

  echo "The img file is $arch_img and the sig file is ${arch_img}.sig"
# Download arch signature file    
    if [ -f /$DOWNLOAD_DIR/${arch_img}.sig ]; then
      echo "Signature file already available and I don't download it."
    else
      echo "I'm going to download signature files."
    wget -q -P /$DOWNLOAD_DIR "${arch_url}${arch_img}.sig"
    fi

# Add GPG key
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys F09A933C0FE0331E558CA4E166CAB7EAA45DD781

# GPG check
  if ( cd /$DOWNLOAD_DIR && gpg --verify "${arch_img}.sig" "${arch_img}" ); then
        echo "GPG verification passed. Renaming file..."

        # Check if the file exist before to rename it
        if [ -f "/$DOWNLOAD_DIR/$arch_img" ]; then
            mv "/$DOWNLOAD_DIR/$arch_img" "/$DOWNLOAD_DIR/image.xz"
            
            # Check if the mv command status
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /$DOWNLOAD_DIR."
            exit 1
        fi
    else
        echo "Signature failed, GPG verification did not pass."
        exit 1
    fi
}

# Function to download the latest Kali Nethunter image for PinePhone Pro
kali_nethunter_phosh_img() {
    kali_nethunter_img="$(curl -s ${kali_nethunter_url} | grep -oP 'kali-nethunterpro-\d{4}\.\d{1,2}-pinephonepro\.img\.xz' | sort -r | head -n 1)"
    
    if [ -f "/$DOWNLOAD_DIR/$kali_nethunter_img" ]; then
        echo "Latest Kali Nethunter image founded and I don't need to download it."
      else
        echo "I'm going to download latest Kali Nethunter image:"
        wget --progress=dot -c -d --timeout=60 --tries=3 "$kali_nethunter_url$kali_nethunter_img" -P /$DOWNLOAD_DIR
        echo "Download complete: $kali_nethunter_img"
    fi  
}

# Function to check Kali Nethunter signature
kali_nethunter_phosh_sig() {

# Download SHA256SUMS    
    if [ -f /$DOWNLOAD_DIR/SHA256SUMS ]; then
      echo "Signature file already available and I don't download it."
    else
      echo "I'm going to download signature files."
    wget -q -P /$DOWNLOAD_DIR "${kali_nethunter_url}SHA256SUMS"
    fi

# SHA256SUM check
  if ( cd /$DOWNLOAD_DIR && sha256sum -c SHA256SUMS ) |  grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Check if the file exist before to rename it
        if [ -f "/$DOWNLOAD_DIR/$kali_nethunter_img" ]; then
            mv "/$DOWNLOAD_DIR/$kali_nethunter_img" "/$DOWNLOAD_DIR/image.xz"
            
            # Check if the mv command status
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /$DOWNLOAD_DIR."
            exit 1
        fi
    else
        echo "Signature failed: SHA256SUM verification did not pass."
        exit 1
    fi
}

# Function to download the latest postmarketOS with Plasma Mobile
postmarketOS_plasma_img() {
    
    if [ -f "/$DOWNLOAD_DIR/$postmarketOS_plasma_img" ]; then
        echo "Latest postmarketOS with Plasma Mobile founded and I don't need to download it."
      else
        echo "I'm going to download latest postmarketOS with Plasma Mobile image:"
        echo "The download url is $postmarketOS_plasma_url$postmarketOS_plasma_img_date$postmarketOS_plasma_img"
        wget --progress=dot -c -d --timeout=60 --tries=3 "$postmarketOS_plasma_url$postmarketOS_plasma_img_date$postmarketOS_plasma_img" -P /$DOWNLOAD_DIR
        echo "Download complete: $postmarketOS_plasma_img"
    fi  
}

# Function to check postmarketOS with Plasma Mobile signature
postmarketOS_plasma_sig() {

# Download SHA256SUMS    
    if [ -f "/$DOWNLOAD_DIR/${postmarketOS_plasma_img}.sha512" ]; then
      echo "Signature file already available and I don't download it."
    else
      echo "I'm going to download signature files."
    wget -q -P /$DOWNLOAD_DIR "${postmarketOS_plasma_url}${postmarketOS_plasma_img_date}${postmarketOS_plasma_img}.sha512"
    fi

# SHA256SUM check
  if ( cd /$DOWNLOAD_DIR && sha256sum -c SHA256SUMS ) |  grep -q "OK$"; then
        echo "SHA256SUM verification passed. Renaming file..."

        # Check if the file exist before to rename it
        if [ -f "/$DOWNLOAD_DIR/$postmarketOS_plasma_img" ]; then
            mv "/$DOWNLOAD_DIR/$postmarketOS_plasma_img" "/$DOWNLOAD_DIR/image.xz"
            
            # Check if the mv command status
            if [ $? -eq 0 ]; then
                echo "File renamed to image.xz"
            else
                echo "Error: Failed to rename the file."
                exit 1
            fi
        else
            echo "File to rename not found in /$DOWNLOAD_DIR."
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
    cat "/$DOWNLOAD_DIR/image.xz" | unxz -c > /$DOWNLOAD_DIR/image.img
    sudo dd if=/$DOWNLOAD_DIR/image.img of=/dev/$device_name status=progress bs=4M conv=fdatasync iflag=sync
    echo "Writing process complete."

    # Ensure script exits after burning process
    exit 0
}

# Menu with the correct options
PS3="Choose an option (1-5): "
options=(
  "Download and install Mobian testing" 
  "Download and install Arch Linux with Phosh" 
  "Download and install Kali Nethunter Linux with Phosh" 
  "Download and install postmarketOS with Plasma Mobile" 
  "Exit"
)

select choice in "${options[@]}"; do
    case "$choice" in
        "Download and install Mobian testing")
            echo "Choose environment:"
            echo "1) Phosh"
            echo "2) Plasma Mobile"
            read -rp "Enter your choice [1-2]: " env_choice
            case $env_choice in
                1)  
                    echo "Phosh selected. Choose action:"
                    echo "1) Download image with installation wizard"
                    echo "2) Download image without installation wizard"
                    read -rp "Enter your choice [1-2]: " action_choice
                    case $action_choice in
                        1)
                            # Azioni per Phosh - Download image without installation wizard
                            mob_img_testing_phosh
                            mob_img_testing_phosh_sig
                            ;;
                        2)
                            # Azioni per Phosh - Download image without installation wizard install
                            devicecheck
                            img_burn
                            ;;
                        *)
                            echo "Invalid choice."
                            ;;
                    esac
                    ;;
                2)  
                    echo "Plasma Mobile selected. Choose action:"
                    echo "1) Download image with installation wizard"
                    echo "2) Download image without installation wizard"
                    read -rp "Enter your choice [1-2]: " action_choice
                    case $action_choice in
                        1)
                            # Azioni per Plasma - Download image without installation wizard
                            mob_img_testing_plasma
                            mob_img_testing_plasma_sig
                            ;;
                        2)
                            # Azioni per Plasma - Download image without installation wizard install
                            devicecheck
                            img_burn
                            ;;
                        *)
                            echo "Invalid choice."
                            ;;
                    esac
                    ;;
                *)
                    echo "Invalid choice."
                    ;;
            esac
            ;;     
        "Download and install Arch Linux with Phosh")
            arch_img_phosh
            arch_img_phosh_sig
            devicecheck
            img_burn
            ;;

        "Download and install Kali Nethunter Linux with Phosh")
            kali_nethunter_phosh_img
            kali_nethunter_phosh_sig
            devicecheck
            img_burn
            ;;

        "Download and install postmarketOS with Plasma Mobile")
            postmarketOS_plasma_img
            postmarketOS_plasma_sig
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

