#!/bin/bash

# Définir le chemin global
GLOBAL_PATH="/Users/jpjanecek/Documents/workspace/saltstack/docker-compose"
PYTHON_PATH="/Users/jpjanecek/Documents/workspace/saltstack/docker-compose"

# Vérifier si le répertoire test_robot_files existe
if [ ! -d "test_robot_files" ]; then
    echo "Le répertoire test_robot_files n'existe pas."
    exit 1
fi

# Boucler sur tous les fichiers .robot dans le répertoire test_robot_files
for robot_file in test_robot_files/*.robot; do
    if [ -f "$robot_file" ]; then
        echo "Exécution du test : $robot_file"
        robot --pythonpath $PYTHON_PATH --variable GLOBAL_PATH:"$GLOBAL_PATH" "$robot_file"
    fi
done