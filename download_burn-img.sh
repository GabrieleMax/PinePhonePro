#!/bin/bash
## Last update 26/12/2024 ##                                   
## Before you start the script, connect the device via USB to your PC/laptop.

# Find the user with UID 1000 (first non-root user)
FIRSTUSER=$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')                                                                

# URLs for different operating systems
deb_testing_url="https://images.mobian-project.org/pinephonepro/installer/weekly/"
arch_url="https://github.com/dreemurrs-embedded/Pine64-Arch/releases/"
kali_nethunter_url="lynx -dump -listonly -nonumbers https://kali.download/nethunterpro-images/ | sort -r | head -n 1"

# Display the initial message
echo "Connect the PinePhone Pro (press vol+ until the LED turns blue):"

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
deb_testing_posh=$(wget -q -O - "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
deb_testing_plasma=$(wget -q -O - "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.img.xz' | sort -r | head -n 1)
arch_testing_posh=$(wget -q -O - "$arch_url" | grep -oP 'archlinux-pinephone-pro-phosh-\d{8}.img.xz' | sort -r | head -n 1)
kali_nethunter=$(wget -q -O - "$kali_nethunter_url" | grep -oP 'kali-nethunterpro-\d{4}-pinephonepro.img.xz' | sort -r | head -n 1)

# Function to download Debian testing image with Phosh for PinePhone Pro
deb_img_testing_posh() {
    if [ -n "$deb_testing_posh" ]; then
        echo "Found file: $deb_testing_posh"
        wget --progress=dot "$deb_testing_url$deb_testing_posh" -O "/tmp/image.xz"
        echo "Download complete: $deb_testing_posh"
        img_burn  # Automatically call the burn function after downloading
        exit  # Exit after burn
    else
        echo "File not found."
    fi
}

# Function to download Debian testing image with Plasma for PinePhone Pro
deb_img_testing_plasma() {
    if [ -n "$deb_testing_plasma" ]; then
        echo "Latest file found: $deb_testing_plasma"
        wget --progress=dot "$deb_testing_url$deb_testing_plasma" -O "/tmp/image.xz"
        echo "Download complete: $deb_testing_plasma"
        img_burn  # Automatically call the burn function after downloading
        exit  # Exit after burn
    else
        echo "File not found."
    fi
}

# Function to download the latest Arch Linux image for PinePhone Pro
arch_img_testing_posh() {
    if [ -n "$arch_testing_posh" ]; then
        echo "Latest Arch Linux file found: $arch_testing_posh"
        wget --progress=dot "$arch_url$arch_testing_posh" -O "/tmp/image.xz"
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
    if [ -n "$kali_nethunter" ]; then
        echo "Latest Kali Nethunter image found: $kali_nethunter"
        wget --progress=dot "$kali_nethunter_url$kali_nethunter" -O "/tmp/image.xz"
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

    # Write the image to the device
    cat "/tmp/image.xz" | unxz -c > /tmp/image.img
    sudo dd if=/tmp/image.img of=/dev/$device_name bs=4M status=progress conv=noerror,sync
    echo "Writing process complete."
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
            ;;
        "Download and install Debian testing with Phosh mobile")
            deb_img_testing_posh
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

