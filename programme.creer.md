# Instructions pour ChatGPT : Création de Programmes

## Objectif

Ce document décrit les étapes et règles que ChatGPT doit suivre pour créer un programme lorsque l'utilisateur en fait la demande. Le programme doit être un utilitaire shell ou un autre type de programme pouvant être exécuté via la ligne de commande.

## Structure Générale du Programme

Le programme doit être organisé avec les répertoires et fichiers suivants :

programmeX/
├── bin/
│ └── programmeX.sh
├── lib/
│ ├── config.sh
│ ├── uninstall.sh
│ ├── help.sh
│ ├── man.sh
│ └── [autres scripts].sh
├── programmeX.install.sh
├── README.md
└── VERSION


- **programmeX.sh** : Le point d'entrée du programme, situé dans le répertoire `bin`.
- **config.sh** : Fichier de configuration contenant toutes les variables globales utilisées par les scripts, situé dans le répertoire `lib`.
- **uninstall.sh** : Script de désinstallation, situé dans le répertoire `lib`.
- **help.sh** : Script affichant les options disponibles, situé dans le répertoire `lib`.
- **man.sh** : Script fournissant la documentation, situé dans le répertoire `lib`.
- **programmeX.install.sh** : Script d'installation du programme.
- **README.md** : Fichier de documentation pour expliquer le fonctionnement et l'installation du programme.
- **VERSION** : Fichier contenant le numéro de version du programme.

## Variables

Toutes les variables de configuration doivent être définies dans `config.sh` et utilisées de manière cohérente dans tous les scripts. Voici un exemple de contenu pour `config.sh` :

```config.sh
#!/bin/bash

PROGRAM_NAME="programmeX"
INSTALL_DIR="/usr/local/bin"
PROGRAM_PATH="${INSTALL_DIR}/${PROGRAM_NAME}"
PROGRAM_LIB_DIR="${INSTALL_DIR}/${PROGRAM_NAME}"
BIN_DIR="${PROGRAM_NAME}/bin"
LIB_DIR="${PROGRAM_NAME}/lib"
```

Règles de Nomination
Le nom du programme doit être défini dans la variable PROGRAM_NAME.
Les noms des fichiers et répertoires doivent utiliser PROGRAM_NAME pour construire leurs chemins.
Scripts
${PROGRAM_NAME}.install.sh

Ce script installe le programme sur le système.
Il doit copier les scripts dans les répertoires appropriés et rendre les scripts exécutables.
Le script demande une confirmation avant l'installation.
Exemple de contenu :

```${PROGRAM_NAME}.install.sh
#!/bin/bash

source programmeX/lib/config.sh

install_program() {
    echo "Installation de ${PROGRAM_NAME}..."
    sudo mkdir -p ${PROGRAM_LIB_DIR}
    sudo cp ${BIN_DIR}/${PROGRAM_NAME}.sh ${PROGRAM_PATH}
    sudo chmod +x ${PROGRAM_PATH}
    sudo cp ${LIB_DIR}/*.sh ${PROGRAM_LIB_DIR}/
    sudo chmod +x ${PROGRAM_LIB_DIR}/*.sh
    sudo cp ${LIB_DIR}/config.sh ${PROGRAM_LIB_DIR}/
    sudo chmod +x ${PROGRAM_LIB_DIR}/config.sh
    echo "${PROGRAM_NAME} a été installé avec succès et est accessible depuis le PATH."
}

read -p "Ce script va installer ${PROGRAM_NAME} sur votre machine et nécessite des droits administratifs. Voulez-vous continuer ? (oui/non) " response
case "$response" in
    [oO][uU][iI]|[yY][eE][sS])
        install_program
        ;;
    *)
        echo "Installation annulée."
        exit 1
        ;;
esac
```


