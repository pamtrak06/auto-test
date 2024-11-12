#!/bin/bash

# Créer le répertoire pour les fichiers Robot Framework
mkdir -p test_robot_files && cd test_robot_files

# Définir le chemin global pour l'exécution des commandes
GLOBAL_PATH="./docker-compose.sh exec"

# Générer le fichier pour vérifier la configuration du syndic
cat << EOF > check_salt_ms_communication_syndic_configuration.robot
*** Settings ***
Library           Process

*** Variables ***
\${GLOBAL_PATH}   \${GLOBAL_PATH}
\${COMMAND}       \${GLOBAL_PATH} salt_syndic1 cat /etc/salt/master | grep syndic_master
\${EXPECTED}      syndic_master
\${TIMEOUT}       1000
\${DESCRIPTION}   Check syndic configuration: Check if syndic_master is correctly set to the master's address.

*** Test Cases ***
Run Command And Check Output
    [Documentation]    \${DESCRIPTION}
    \${result}=    Run Process    \${COMMAND}    timeout=\${TIMEOUT}
    Should Contain    \${result.stdout}    \${EXPECTED}
EOF

# Générer le fichier pour vérifier la configuration du master
cat << EOF > check_salt_ms_communication_master_configuration.robot
*** Settings ***
Library           Process

*** Variables ***
\${GLOBAL_PATH}   \${GLOBAL_PATH}
\${COMMAND}       \${GLOBAL_PATH} salt_master cat /etc/salt/master | grep order_masters
\${EXPECTED}      order_masters: True
\${TIMEOUT}       1000
\${DESCRIPTION}   Check master configuration: Ensure that order_masters is set to True on the master.

*** Test Cases ***
Run Command And Check Output
    [Documentation]    \${DESCRIPTION}
    \${result}=    Run Process    \${COMMAND}    timeout=\${TIMEOUT}
    Should Contain    \${result.stdout}    \${EXPECTED}
EOF

# Générer le fichier pour vérifier l'acceptation des clés
cat << EOF > check_salt_ms_communication_key_acceptance.robot
*** Settings ***
Library           Process

*** Variables ***
\${GLOBAL_PATH}   \${GLOBAL_PATH}
\${COMMAND}       \${GLOBAL_PATH} salt_master salt-key -L
\${EXPECTED}      <syndics_key>
\${TIMEOUT}       1000
\${DESCRIPTION}   Check key acceptance: Check if the syndic's key is in the 'Accepted Keys' list.

*** Test Cases ***
Run Command And Check Output
    [Documentation]    \${DESCRIPTION}
    \${result}=    Run Process    \${COMMAND}    timeout=\${TIMEOUT}
    Should Contain    \${result.stdout}    \${EXPECTED}
EOF

# Générer le fichier pour vérifier la communication de base avec Salt
cat << EOF > check_salt_ms_communication_basic_salt_communication.robot
*** Settings ***
Library           Process

*** Variables ***
\${GLOBAL_PATH}   \${GLOBAL_PATH}
\${COMMAND}       \${GLOBAL_PATH} salt_syndic1 salt-call test.ping
\${EXPECTED}      0
\${TIMEOUT}       1000
\${DESCRIPTION}   Check basic Salt communication: This should return True if Salt is functioning correctly on the syndic.

*** Test Cases ***
Run Command And Check Return Code
    [Documentation]    \${DESCRIPTION}
    \${result}=    Run Process    \${COMMAND}    timeout=\${TIMEOUT}
    Should Be Equal As Numbers    \${result.returncode}    \${EXPECTED}
EOF

# Générer le fichier pour vérifier les logs du syndic
cat << EOF > check_salt_ms_communication_syndic_logs.robot
*** Settings ***
Library           Process

*** Variables ***
\${GLOBAL_PATH}   \${GLOBAL_PATH}
\${COMMAND}       \${GLOBAL_PATH} salt_syndic1 tail -f /var/log/salt/syndic
\${EXPECTED}      0
\${TIMEOUT}       1000
\${DESCRIPTION}   Check syndic logs for more detailed error messages.

*** Test Cases ***
Run Command And Check Return Code
    [Documentation]    \${DESCRIPTION}
    \${result}=    Run Process    \${COMMAND}    timeout=\${TIMEOUT}
    Should Be Equal As Numbers    \${result.returncode}    \${EXPECTED}
EOF

# Générer le fichier pour vérifier les logs du master
cat << EOF > check_salt_ms_communication_master_logs.robot
*** Settings ***
Library           Process

*** Variables ***
\${GLOBAL_PATH}   \${GLOBAL_PATH}
\${COMMAND}       \${GLOBAL_PATH} salt_master tail -f /var/log/salt/master
\${EXPECTED}      0
\${TIMEOUT}       1000
\${DESCRIPTION}   Check master logs for any related errors.

*** Test Cases ***
Run Command And Check Return Code
     [Documentation]     \${DESCRIPTION}
     \${result}=     Run Process     \${COMMAND}     timeout=\${TIMEOUT}
     Should Be Equal As Numbers     \${result.returncode}     \${EXPECTED}
EOF

# Générer le fichier pour vérifier que les ports sont ouverts
cat << EOF > check_salt_ms_communication_ports_open.robot
*** Settings ***
Library           Process

*** Variables ***
\${GLOBAL_PATH}   \${GLOBAL_PATH}
\${COMMAND}       \${GLOBAL_PATH} salt_master netstat -tulpn | grep salt 
\${EXPECTED}      "" 
\${TIMEOUT}       1000 
\${DESCRIPTION}   Check that the necessary ports (typically 4505 and 4506) are open. 

*** Test Cases *** 
Run Command And Check Output 
[Documentation]     \${DESCRIPTION}
\$result=     Run Process     \${COMMAND}\ timeout=\${TIMEOUT}

EOF

# Générer le fichier pour redémarrer le service syndic et vérifier les erreurs de démarrage.
cat << EOF > check_salt_ms_communication_restart_syndic_service.robot
*** Settings ***
Library           Process

*** Variables ***
\${GLOBAL_PATH}   \${GLOBAL_PATH}
\${COMMAND}       ./\${GLOBAL_PATH}/exec salt_syndic1 supervisorctl restart salt-syndic && ./\${GLOBAL_PATH}/exec salt_syndic1 tail -f /var/log/salt/syndic 
\${EXPECTED}      0 
\${TIMEOUT}       1000 
\${DESCRIPTION}   Restart the syndic service and check for any startup errors. 

*** Test Cases *** 
Run Command And Check Return Code 
[Documentation]     \${DESCRIPTION}
\$result=     Run Process     \${COMMAND}\ timeout=\${TIMEOUT}

EOF

# Générer le fichier pour établir une connexion manuelle depuis le syndic au master.
cat << EOF > check_salt_ms_communication_establish_connection.robot 
*** Settings *** 
Library           Process 

*** Variables *** 
\${GLOBAL_PATH}\         \${GLOBAL_PATH}/exec salt_syndic1 salt-syndic -d 
\${EXPECTED}\        0 
\${TIMEOUT}\         1000 
\${DESCRIPTION}\     Establish a connection from the syndic to the master manually. 

*** Test Cases *** 
Run Command And Check Return Code 
[Documentation]\     \${DESCRIPTION}\ 
\${result}\ =     Run Process     \${COMMAND}\ timeout=\${TIMEOUT}\ 
Should Be Equal As Numbers     \${result.returncode}\ \${EXPECTED}\ 
EOF 

echo "Tous les fichiers Robot Framework ont été générés dans le répertoire test_robot_files."