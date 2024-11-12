*** Settings ***
Library           Process

*** Variables ***
${GLOBAL_PATH}   ${GLOBAL_PATH}
${COMMAND}       ./docker-compose.sh salt_syndic1 cat /etc/salt/master | grep syndic_master
${EXPECTED}      syndic_master
${TIMEOUT}       1000
${DESCRIPTION}   Check syndic configuration: Check if syndic_master is correctly set to the master's address.

*** Test Cases ***
Run Command And Check Output
    [Documentation]    ${DESCRIPTION}
    ${result}=    Run Process    ${COMMAND}    timeout=${TIMEOUT}
    Should Contain    ${result.stdout}    ${EXPECTED}
