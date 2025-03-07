# Test Definitions

| Filename | Command | Path | Timeout | Description | Return Code Enabled | Return Code Value | Output Enabled | Output Value | Timeout Enabled | Additional Check Enabled | Additional Check Value 1 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| check_salt_ms_communication_basic_salt_communication.json | ./docker-compose.sh exec salt_syndic1 salt-call test.ping | NA | 3000 | Check basic Salt communication: This should return True if Salt is functioning correctly on the syndic. | true | 0 | true | True | false | false |  |
| check_salt_ms_communication_key_acceptance.json | ./docker-compose.sh exec salt_master salt-key -L | NA | 3000 | Check key acceptance: Check if the syndic's key is in the 'Accepted Keys' list. | true | 0 | true | salt_syndic[1-2] | false | false |  |
| check_salt_ms_communication_master_configuration.json | ./docker-compose.sh exec salt_master cat /etc/salt/master | NA | 1000 | Check master configuration: Ensure that order_masters is set to True on the master. | true | 0 | true | order_masters:.*True | false | false |  |
| check_salt_ms_communication_ports_open.json | ./docker-compose.sh exec salt_master netstat -tulpn | NA | 1000 | Check that the necessary ports (typically 4505 and 4506) are open. | true | 0 | true | .*4505|4506.* | false | false |  |
| check_salt_ms_communication_syndic_logs.json | ./docker-compose.sh exec salt_syndic1 tail -n 100 /var/log/salt/syndic | NA | 2000 | Check syndic logs for more detailed error messages. | true | 0 | true | ^!.*(ERROR|CRITICAL).* | false | false |  |
| check_salt_ms_communication_syndic_configuration.json | ./docker-compose.sh exec salt_syndic1 cat /etc/salt/master | NA | 3000 | Check syndic configuration: Check if syndic_master is correctly set to the master's address. | true | 0 | true | syndic_master:.*True | false | false |  |
| check_salt_ms_communication_master_logs.json | ./docker-compose.sh exec salt_master tail -n 100 /var/log/salt/master | NA | 2000 | Check master logs for any related errors. | true | 0 | true | ^(?!.*(ERROR|CRITICAL)).* | false | false |  |
