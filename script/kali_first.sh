#!/bin/bash
# Fix repository's issue

# Funzione per eseguire un comando remoto con sudo tramite sshpass
run_with_sudo() {
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no -p "$sshport" "$remoteuser@$remoteip" "echo $password | sudo -S $1"
}

# Installa sshpass se non è installato sulla macchina remota
run_with_sudo "sudo apt-get update -y"
run_with_sudo "sudo apt-get install -y sshpass"

# Check se la prima riga di sources.list è già commentata
run_with_sudo "head -n 1 /etc/apt/sources.list | grep -q '^#' || sudo sed -i '1s/^/#/' /etc/apt/sources.list"

# Controlla se la riga per Kali è già presente
run_with_sudo "grep -q 'deb https://http.kali.org/kali kali-rolling main non-free contrib' /etc/apt/sources.list || echo 'deb https://http.kali.org/kali kali-rolling main non-free contrib' | sudo tee -a /etc/apt/sources.list"

# Esegui aggiornamenti e installazioni sulla macchina remota
run_with_sudo "sudo apt-get update"
run_with_sudo "sudo apt-get install aptitude -y"
run_with_sudo "sudo aptitude update"
run_with_sudo "sudo aptitude safe-upgrade -y"

# Installare make e vim sulla macchina remota
run_with_sudo "sudo apt-get install make vim -y"

# Riavvia la macchina remota
run_with_sudo "sudo reboot"

