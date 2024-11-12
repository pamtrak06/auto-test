*** Settings ***
Library           Process

*** Variables ***
${GLOBAL_PATH}   ${GLOBAL_PATH}
${COMMAND}       ./docker-compose.sh salt_master tail -f /var/log/salt/master
${EXPECTED}      0
${TIMEOUT}       1000
${DESCRIPTION}   Check master logs for any related errors.

*** Test Cases ***
Run Command And Check Return Code
     [Documentation]     ${DESCRIPTION}
     ${result}=     Run Process     ${COMMAND}     timeout=${TIMEOUT}
     Should Be Equal As Numbers     ${result.returncode}     ${EXPECTED}
