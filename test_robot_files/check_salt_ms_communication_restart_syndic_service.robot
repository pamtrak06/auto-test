*** Settings ***
Library           Process

*** Variables ***
${GLOBAL_PATH}   ${GLOBAL_PATH}
${COMMAND}       ./${GLOBAL_PATH}/exec salt_syndic1 supervisorctl restart salt-syndic && ./${GLOBAL_PATH}/exec salt_syndic1 tail -f /var/log/salt/syndic 
${EXPECTED}      0 
${TIMEOUT}       1000 
${DESCRIPTION}   Restart the syndic service and check for any startup errors. 

*** Test Cases *** 
Run Command And Check Return Code 
[Documentation]     ${DESCRIPTION}
$result=     Run Process     ${COMMAND}\ timeout=${TIMEOUT}

