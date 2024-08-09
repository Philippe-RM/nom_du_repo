
# Programme: Créer une Clé SSH et l'Ajouter à GitHub

## Description

Ce programme est un script bash qui automatise la création d'une clé SSH, la configuration de l'agent SSH, et l'ajout de la clé SSH à votre compte GitHub via l'API GitHub. Il vérifie également la présence des dépendances requises (`curl` et `git`), propose de les installer si elles ne sont pas présentes, et permet la mise à jour de ces programmes si nécessaire.

## Fonctionnalités

1. **Vérification des dépendances** : 
   - Le script vérifie si `curl` et `git` sont installés.
   - Il demande à l'utilisateur s'il souhaite installer les programmes manquants.
   - Offre une option de mise à jour des programmes installés.

2. **Génération de clé SSH** :
   - Crée une nouvelle paire de clés SSH avec une taille de 4096 bits.
   - Ajoute la clé privée à l'agent SSH.

3. **Ajout de la clé SSH à GitHub** :
   - Demande un Personal Access Token GitHub à l'utilisateur.
   - Envoie la clé publique SSH à GitHub via l'API REST.

## Utilisation

### Pré-requis

- Un système Linux avec accès à un terminal.
- Un compte GitHub.
- `curl` et `git` doivent être installés, mais le script s'assure qu'ils le sont.

### Instructions

1. **Création du script** :
   - Créez un fichier bash, par exemple `add_ssh_key_github.sh`, et collez-y le code du script.

2. **Rendre le script exécutable** :
   - Exécutez la commande : `chmod +x add_ssh_key_github.sh`.

3. **Exécution du script** :
   - Lancez le script : `./add_ssh_key_github.sh`.
   - Suivez les instructions à l'écran pour installer les dépendances, générer la clé SSH, et l'ajouter à GitHub.

## Code du script

```bash
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
```

## Notes

- Le script demande un GitHub Personal Access Token pour authentifier les requêtes API. Assurez-vous d'avoir créé ce jeton avec les permissions appropriées (`repo`, `admin:public_key`).
- L'utilisation de `sudo` dans le script suppose que l'utilisateur a les privilèges administratifs sur la machine.

## Avertissements

- Veillez à sécuriser votre clé privée (`~/.ssh/id_rsa`) et ne la partagez jamais.
- Ce script est conçu pour fonctionner sur les systèmes basés sur Debian/Ubuntu. Si vous utilisez une autre distribution Linux, vous devrez peut-être ajuster les commandes d'installation.
