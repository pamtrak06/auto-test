*** Settings ***
Library           Process

*** Variables ***
${GLOBAL_PATH}   ${GLOBAL_PATH}
${COMMAND}       ./docker-compose.sh salt_master salt-key -L
${EXPECTED}      <syndics_key>
${TIMEOUT}       1000
${DESCRIPTION}   Check key acceptance: Check if the syndic's key is in the 'Accepted Keys' list.

*** Test Cases ***
Run Command And Check Output
    [Documentation]    ${DESCRIPTION}
    ${result}=    Run Process    ${COMMAND}    timeout=${TIMEOUT}
    Should Contain    ${result.stdout}    ${EXPECTED}
