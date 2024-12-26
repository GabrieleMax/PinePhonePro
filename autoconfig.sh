#!/bin/bash
## Last update 26/12/2024 ##                                   
## Before to start the script connect the device by usb to the pc\laptop

FIRSTUSER=$(grep "1000" /etc/passwd | awk -F ':' '{print $1}')                                                                
# Url of the website with image links
url="https://images.mobian-project.org/pinephonepro/installer/weekly/"
arch_url="https://github.com/dreemurrs-embedded/Pine64-Arch/releases/"

# Show the initial message
echo "Connect the Pine Phone pro and press vol+ untill you'll see the blu led:"

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
deb_testing_posh=$(wget -q -O - "$url" | grep -oP 'mobian-installer-rockchip-phosh-\d{8}.img.xz' | sort -r | head -n 1)
deb_testing_plasma=$(wget -q -O - "$url" | grep -oP 'mobian-installer-rockchip-plasma-mobile-\d{8}.img.xz' | sort -r | head -n 1)
arch_testing_posh=$(wget -q -O - "$arch_url" | grep -oP 'archlinux-pinephone-pro-phosh-\d{8}.img.xz' | sort -r | head -n 1)

# Function to download the Mobian image with Phosh for PinePhone Pro
deb_img_testing_posh() {
    if [ -n "$deb_testing_posh" ]; then
        echo "File found: $deb_testing_posh"
        wget --progress=dot "$url$deb_testing_posh" -O "/tmp/image.xz"
        echo "Download finished: $deb_testing_posh"
    else
        echo "File not found."
    fi
}

# Function to download the Mobian image with Plasma for PinePhone Pro
deb_img_testing_plasma() {
    if [ -n "$deb_testing_plasma" ]; then
        echo "Most recent file found: $deb_testing_plasma"
        wget --progress=dot "$url$deb_testing_plasma" -O "/tmp/image.xz"
        echo "Download finished: $deb_testing_plasma"
    else
        echo "File not found."
    fi
}

# Function to download the latest Arch image for PinePhone Pro
arch_img_testing_posh() {
    # Get the latest Arch PinePhone Pro image with Phosh
    arch_testing=$(wget -q -O - "$arch_url" | grep -oP 'archlinux-pinephone-pro-phosh-\d{8}.img.xz' | sort -r | head -n 1)

    if [ -n "$arch_testing" ]; then
        echo "Most recent Arch image found: $arch_testing"
        wget --progress=dot "$arch_url$arch_testing" -O "/tmp/image.xz"
        echo "Download finished: $arch_testing"
    else
        echo "Arch image not found."
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
PS3="Choose an option (1-4): "
select menu in "Download and install Debian testing with Plasma mobile" \
               "Download and install Debian testing with Phosh mobile" \
               "Download and install Arch Linux with Phosh" \
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
        "Image burn")
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

