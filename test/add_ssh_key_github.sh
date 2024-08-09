#!/bin/bash

# Fonction pour vérifier si un programme est installé
function check_installation {
    command -v $1 >/dev/null 2>&1
}

# Fonction pour installer un programme si nécessaire
function install_program {
    local program_name=$1
    if ! check_installation $program_name; then
        read -p "$program_name n'est pas installé. Voulez-vous l'installer ? [O/n] " response
        if [[ "$response" =~ ^[Oo]$ || -z "$response" ]]; then
            sudo apt update
            sudo apt install -y $program_name
        else
            echo "$program_name est nécessaire pour continuer. Veuillez l'installer et réessayer."
            exit 1
        fi
    else
        echo "$program_name est déjà installé."
        # Option pour mettre à jour
        read -p "Voulez-vous vérifier les mises à jour de $program_name ? [O/n] " update_response
        if [[ "$update_response" =~ ^[Oo]$ || -z "$update_response" ]]; then
            sudo apt update
            sudo apt upgrade -y $program_name
        fi
    fi
}

# Vérifier et installer curl si nécessaire
install_program "curl"

# Vérifier et installer Git si nécessaire
install_program "git"

# Demander l'email de l'utilisateur
read -p "Entrez votre adresse email pour associer à la clé SSH: " email

# Générer la clé SSH
ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""

# Démarrer l'agent SSH
eval "$(ssh-agent -s)"

# Ajouter la clé privée à l'agent SSH
ssh-add ~/.ssh/id_rsa

# Lire la clé publique
pubkey=$(cat ~/.ssh/id_rsa.pub)

# Demander le jeton d'accès personnel GitHub
read -sp "Entrez votre GitHub Personal Access Token: " token

# Ajouter la clé SSH à GitHub via l'API
response=$(curl -s -H "Authorization: token $token"     --data "{"title":"$(hostname)","key":"$pubkey"}"     https://api.github.com/user/keys)

# Vérifier si l'opération a réussi
if echo "$response" | grep -q "key"; then
    echo -e "\nLa clé SSH a été ajoutée avec succès à votre compte GitHub."
else
    echo -e "\nUne erreur s'est produite :"
    echo "$response"
fi
