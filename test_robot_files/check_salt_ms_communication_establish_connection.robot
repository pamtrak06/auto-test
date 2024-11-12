*** Settings *** 
Library           Process 

*** Variables *** 
${GLOBAL_PATH}\         ${GLOBAL_PATH}/exec salt_syndic1 salt-syndic -d 
${EXPECTED}\        0 
${TIMEOUT}\         1000 
${DESCRIPTION}\     Establish a connection from the syndic to the master manually. 

*** Test Cases *** 
Run Command And Check Return Code 
[Documentation]\     ${DESCRIPTION}\ 
${result}\ =     Run Process     ${COMMAND}\ timeout=${TIMEOUT}\ 
Should Be Equal As Numbers     ${result.returncode}\ ${EXPECTED}\ 
EOF 

echo "Tous les fichiers Robot Framework ont été générés dans le répertoire test_robot_files."
