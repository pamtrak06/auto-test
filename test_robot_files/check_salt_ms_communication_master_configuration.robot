*** Settings ***
Library           Process

*** Variables ***
${GLOBAL_PATH}   ${GLOBAL_PATH}
${COMMAND}       ./docker-compose.sh salt_master cat /etc/salt/master | grep order_masters
${EXPECTED}      order_masters: True
${TIMEOUT}       1000
${DESCRIPTION}   Check master configuration: Ensure that order_masters is set to True on the master.

*** Test Cases ***
Run Command And Check Output
    [Documentation]    ${DESCRIPTION}
    ${result}=    Run Process    ${COMMAND}    timeout=${TIMEOUT}
    Should Contain    ${result.stdout}    ${EXPECTED}
