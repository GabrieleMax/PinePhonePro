#!/bin/bash
## Last update 26/12/2024 ##                                   
## Before to start the script connect the device by usb to the pc\laptop

FIRSTUSER=$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')                                                                
# Url of the website with image links
deb_testing_url="https://images.mobian-project.org/pinephonepro/installer/weekly/"
arch_url="https://github.com/dreemurrs-embedded/Pine64-Arch/releases/"
kali_nethunter_url="https://kali.download/nethunterpro-images/kali-2024.4/"

# Show the initial message
echo "Connect the Pine Phone pro (press vol+ untill the led will be blue):"

# Save the initial output of lsblk, excluding partitions
initial_devices=$(lsblk -dn -o NAME | sort)

# Continuously monitor for a new device
while true; do
    # Save the current output of lsblk, excluding partitions
    current_devices=$(lsblk -dn -o NAME | sort)

    # Compare the current output with the initial one
    new_device=$(comm -13 <(echo "$initial_devices") <(echo "$current_devices"))

    # If a new device is found, perform the desired action
    if [ -n "$new_device" ]; then
        echo "New device connected: $new_device"
        device_name="$new_device"  # Assign the device name to a variable
        break  # Exit the loop
    fi

    # Pause to avoid consuming too much CPU
    sleep 1
done

# Now you can use the $device_name variable
echo "The connected device is: /dev/$device_name"

# Recover the list of files from the website
deb_testing_posh=$(wget -q -O - "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
deb_testing_plasma=$(wget -q -O - "$deb_testing_url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.img.xz' | sort -r | head -n 1)
arch_testing_posh=$(wget -q -O - "$arch_url" | grep -oP 'archlinux-pinephone-pro-phosh-\d{8}.img.xz' | sort -r | head -n 1)
kali_nethunter=$(wget -q -O - "$kali_nethunter_url" | grep -oP 'kali-nethunterpro-\d{8}.img.xz' | sort -r | head -n 1)

# Function to download the Mobian image with Phosh for PinePhone Pro
deb_img_testing_posh() {
    if [ -n "$deb_testing_posh" ]; then
        echo "File found: $deb_testing_posh"
        wget --progress=dot "$deb_testing_url$deb_testing_posh" -O "/tmp/image.xz"
        echo "Download finished: $deb_testing_posh"
        img_burn  # Automatically call the burn function after download
        exit  # Exit after burn
    else
        echo "File not found."
    fi
}

# Function to download the Mobian image with Plasma for PinePhone Pro
deb_img_testing_plasma() {
    if [ -n "$deb_testing_plasma" ]; then
        echo "Most recent file found: $deb_testing_plasma"
        wget --progress=dot "$deb_testing_url$deb_testing_plasma" -O "/tmp/image.xz"
        echo "Download finished: $deb_testing_plasma"
        img_burn  # Automatically call the burn function after download
        exit  # Exit after burn
    else
        echo "File not found."
    fi
}

# Function to download the latest Arch image for PinePhone Pro
arch_img_testing_posh() {
    if [ -n "$arch_testing_posh" ]; then
        echo "Most recent Arch image found: $arch_testing_posh"
        wget --progress=dot "$arch_url$arch_testing_posh" -O "/tmp/image.xz"
        echo "Download finished: $arch_testing_posh"
        img_burn  # Automatically call the burn function after download
        exit  # Exit after burn
    else
        echo "Arch image not found."
    fi
}

# Function to download the latest Kali Linux Nethunter image for PinePhone Pro
kali_nethunter_posh_img() {
    if [ -n "$kali_nethunter" ]; then
        echo "Most recent Kali Nethunter image found: $kali_nethunter"
        wget --progress=dot "$kali_nethunter_url$kali_nethunter" -O "/tmp/image.xz"
        echo "Download finished: $kali_nethunter"
        img_burn  # Automatically call the burn function after download
        exit  # Exit after burn
    else
        echo "Kali Nethunter image not found."
    fi  
}

# Function for the image burn process
img_burn() {
    # Check if device_name is set and not empty
    if [ -z "$device_name" ]; then
        echo "Device name is not set. Exiting."
        exit 1
    fi

    # Confirm the device to burn to
    echo "The disk that will be erased is /dev/$device_name"

    # Burn the image to the device
    cat "/tmp/image.xz" | unxz -c > /tmp/image.img
    sudo dd if=/tmp/image.img of=/dev/$device_name bs=4M status=progress conv=noerror,sync
    echo "Burn process finished."
}

# Menu with correct options
PS3="Choose an option (1-5): "
select menu in "Download and install Debian testing with Plasma mobile" \
               "Download and install Debian testing with Phosh mobile" \
               "Download and install Arch Linux with Phosh mobile" \
               "Download and install Kali Nethunter Linux with Phosh mobile" \
               "Image burn" \
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
          "Image burn")
            img_burn
            exit  # Exit after burn
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

