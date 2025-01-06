#!/bin/bash

# Funzione per eseguire make per Mobian Testing con Posh
mobian_t_posh() {
  echo "Mobian testing posh tuning"
  bash ./mobian_testing.sh install_posh  # Esegui il comando direttamente
}

# Funzione per eseguire make per Mobian Testing con Plasma
mobian_t_plasma() {
  echo "Mobian testing plasma tuning"
  bash ./mobian_testing.sh install_plasma  # Esegui il comando direttamente
}

# Funzione per eseguire make per Kali Official
kali_official() {
  echo "Kali Linux with posh tuning"
  bash ./kali_conf.sh  # Esegui il comando direttamente
}

# Menu di selezione
echo "Scegli un'opzione:"
select option in \
  "Mobian Testing with Posh tuning" \
  "Mobian Testing with Plasma tuning" \
  "Kali Official tuning" \
  "Esci"; do
  case $option in
    "Mobian Testing with Posh tuning")
      mobian_t_posh  # Richiama la funzione specifica per Mobian con Posh
      break
      ;;
    "Mobian Testing with Plasma tuning")
      mobian_t_plasma  # Richiama la funzione specifica per Mobian con Plasma
      break
      ;;
    "Kali Official tuning")
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

