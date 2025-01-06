#!/bin/bash

# Chiedi le informazioni per la macchina remota
read -p "Insert the PinePhone IP address: " remoteip
read -p "Insert the PinePhone SSH port: " sshport
read -p "Insert the PinePhone username: " remoteuser
read -sp "Enter password for $remoteuser on $remoteip: " remotepassword
echo

# Mostra le informazioni
echo "The PinePhone IP address is $remoteip and the remote SSH port is $sshport. The remote user is $remoteuser."

# Install sshpass se non è installato sulla macchina locale
echo "sshpass non trovato, installazione in corso..."
sudo apt-get update
sudo apt-get install -y sshpass

# Esporta le variabili per l'uso nei successivi script
export remoteip
export sshport
export remoteuser
export remotepassword

# Funzione per eseguire comandi remoti usando sshpass e sudo
run_remote_command() {
    sshpass -p "$remotepassword" ssh -o StrictHostKeyChecking=no -p "$sshport" "$remoteuser@$remoteip" "echo $remotepassword | sudo -S $1"
}

# Esegui i comandi remoti per aggiornamenti e configurazione
run_remote_command "sudo apt-get update"
run_remote_command "sudo apt-get install -y sshpass aptitude make vim"
run_remote_command "sudo aptitude update"
run_remote_command "sudo aptitude safe-upgrade -y"

# Menu di opzioni
echo "Choose an option:"
select option in \
    "Mobian Testing with Posh tuning" \
    "Mobian Testing with Plasma tuning" \
    "Kali Official tuning" \
    "Exit"; do
    case $option in
        "Mobian Testing with Posh tuning")
            echo "Executing Mobian Testing with Posh tuning on remote machine..."
            run_remote_command "bash -s" < ~/install/script/mobian_testing.sh install_posh
            break
            ;;
        "Mobian Testing with Plasma tuning")
            echo "Executing Mobian Testing with Plasma tuning on remote machine..."
            run_remote_command "bash -s" <  ~/install/script/mobian_testing.sh install_plasma
            break
            ;;
        "Kali Official tuning")
            echo "Executing Kali Official tuning on remote machine..."
            run_remote_command "bash -s" < ~/install/script/kali_first.sh
            run_remote_command "bash -s" < ~/install/script/kali_conf.sh
            break
            ;;
        "Exit")
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done

