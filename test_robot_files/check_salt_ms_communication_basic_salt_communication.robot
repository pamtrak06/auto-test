*** Settings ***
Library           Process

*** Variables ***
${GLOBAL_PATH}   ${GLOBAL_PATH}
${COMMAND}       ./docker-compose.sh salt_syndic1 salt-call test.ping
${EXPECTED}      0
${TIMEOUT}       1000
${DESCRIPTION}   Check basic Salt communication: This should return True if Salt is functioning correctly on the syndic.

*** Test Cases ***
Run Command And Check Return Code
    [Documentation]    ${DESCRIPTION}
    ${result}=    Run Process    ${COMMAND}    timeout=${TIMEOUT}
    Should Be Equal As Numbers    ${result.returncode}    ${EXPECTED}
