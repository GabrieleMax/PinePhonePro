#!/bin/bash

# Funzione per eseguire make per Mobian Testing con Posh
mobian_t_posh() {
  directory="./mobian_testing"  # Percorso per Mobian Testing
  comando="install_posh"        # Comando da eseguire
  echo "Eseguendo 'make -C $directory $comando'..."
  make -C "$directory" "$comando"
}

# Funzione per eseguire make per Mobian Testing con Plasma
mobian_t_plasma() {
  directory="./mobian_testing"  # Percorso per Mobian Testing
  comando="install_plasma"      # Comando da eseguire
  echo "Eseguendo 'make -C $directory $comando'..."
  make -C "$directory" "$comando"
}

# Funzione per eseguire make per Kali Official
kali_official() {
  directory="./kali_nethunterpro"  # Percorso per Kali Official
  comando="install"                # Comando da eseguire
  echo "Eseguendo 'make -C $directory $comando'..."
  make -C "$directory" "$comando"
}

# Menu di selezione
echo "Scegli un'opzione:"
select option in \
  "Install Mobian Testing with Posh" \
  "Install Mobian Testing with Plasma" \
  "Install Kali Official" \
  "Esci"; do
  case $option in
    "Install Mobian Testing with Posh")
      mobian_t_posh  # Richiama la funzione specifica per Mobian con Posh
      break
      ;;
    "Install Mobian Testing with Plasma")
      mobian_t_plasma  # Richiama la funzione specifica per Mobian con Plasma
      break
      ;;
    "Install Kali Official")
      kali_official  # Richiama la funzione specifica per Kali Official
      break
      ;;
    "Esci")
      echo "Uscita..."
      break
      ;;
    *)
      echo "Opzione non valida"
      ;;
  esac
done

