*** Settings ***
Library           Process

*** Variables ***
${GLOBAL_PATH}   ${GLOBAL_PATH}
${COMMAND}       ./docker-compose.sh salt_master netstat -tulpn | grep salt 
${EXPECTED}      "" 
${TIMEOUT}       1000 
${DESCRIPTION}   Check that the necessary ports (typically 4505 and 4506) are open. 

*** Test Cases *** 
Run Command And Check Output 
[Documentation]     ${DESCRIPTION}
$result=     Run Process     ${COMMAND}\ timeout=${TIMEOUT}

