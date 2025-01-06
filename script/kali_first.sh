#! /bin/bash
# Fix repository's issue

# Check if the first line is already commented
if ! head -n 1 /etc/apt/sources.list | grep -q "^#"; then
    # Commenta la prima riga del file sources.list
    sudo sed -i '1s/^/#/' /etc/apt/sources.list
else
    echo "La prima riga è già commentata."
fi

# Controlla se la riga per Kali è già presente
if ! grep -q "deb https://http.kali.org/kali kali-rolling main non-free contrib" /etc/apt/sources.list; then
    # Aggiungi la riga per Kali al file sources.list
    echo "deb https://http.kali.org/kali kali-rolling main non-free contrib" | sudo tee -a /etc/apt/sources.list
else
    echo "La riga per Kali è già presente in /etc/apt/sources.list"
fi

sudo apt-get update
sudo apt-get install aptitude -y
sudo aptitude update
sudo aptitude safe-upgrade -y

# Install make
sudo apt-get install make vim -y
sudo reboot
