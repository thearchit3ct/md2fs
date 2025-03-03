#!/bin/bash

# Validation des arguments
if [ $# -ne 1 ]; then
    echo "Usage: $0 <markdown_file>"
    exit 1
fi

MARKDOWN_FILE="$1"

# Vérification de l'existence du fichier
if [ ! -f "$MARKDOWN_FILE" ]; then
    echo "Erreur : Le fichier '$MARKDOWN_FILE' n'a pas été trouvé"
    exit 1
fi

# Fonction de nettoyage du nom
clean_name() {
    local name="$1"
    # Supprimer les commentaires
    name=$(echo "$name" | sed -E 's/[[:space:]]+#.*$//')
    # Supprimer les espaces de début et de fin
    name=$(echo "$name" | xargs)
    echo "$name"
}

# Répertoire de base pour la création
BASE_DIR="."

# Chemin courant
current_path="$BASE_DIR"

# Lire le fichier ligne par ligne
while read -r line; do
    # Ignorer les lignes vides ou les délimiteurs de blocs de code
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*\`\`\`.*$ ]]; then
        continue
    fi
    
    # Déterminer si c'est un répertoire ou un fichier
    # Pour le format tree
    if [[ "$line" =~ ^[├└│─] ]]; then
        name=$(echo "$line" | sed -E 's/^[├└│─ ]+//')
    else
        # Pour le format avec espaces
        name=$(echo "$line" | sed -E 's/^[ ]*([-*+]|[0-9]+\.)[ ]+//')
    fi
    
    # Nettoyer le nom
    name=$(clean_name "$name")
    
    # Sauter les lignes vides après nettoyage
    [[ -z "$name" ]] && continue
    
    # Déterminer si c'est un répertoire
    if [[ "$name" == */ || ! "$name" =~ \. ]]; then
        # C'est un répertoire
        name=${name%/}
        current_path="$BASE_DIR/$name"
        
        echo "Création du répertoire : $current_path"
        mkdir -p "$current_path"
    else
        # C'est un fichier
        full_path="$current_path/$name"
        parent_dir=$(dirname "$full_path")
        
        echo "Création du fichier : $full_path"
        mkdir -p "$parent_dir"
        touch "$full_path"
        
        # Contenu minimal pour les fichiers Python
        if [[ "$full_path" == *.py ]]; then
            case "$name" in
                "__init__.py")
                    echo "# Package initialization" > "$full_path"
                    ;;
                "*_interface.py")
                    echo "# Interface definition" > "$full_path"
                    ;;
                "*.py")
                    echo "# Python module" > "$full_path"
                    ;;
            esac
        fi
    fi
done < "$MARKDOWN_FILE"

echo "Structure de projet créée avec succès !"