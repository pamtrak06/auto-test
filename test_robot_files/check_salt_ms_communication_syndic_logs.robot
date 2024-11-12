*** Settings ***
Library           Process

*** Variables ***
${GLOBAL_PATH}   ${GLOBAL_PATH}
${COMMAND}       ./docker-compose.sh salt_syndic1 tail -f /var/log/salt/syndic
${EXPECTED}      0
${TIMEOUT}       1000
${DESCRIPTION}   Check syndic logs for more detailed error messages.

*** Test Cases ***
Run Command And Check Return Code
    [Documentation]    ${DESCRIPTION}
    ${result}=    Run Process    ${COMMAND}    timeout=${TIMEOUT}
    Should Be Equal As Numbers    ${result.returncode}    ${EXPECTED}
