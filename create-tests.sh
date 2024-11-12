#!/bin/bash

mkdir -p run_def

cat << EOF > run_def/check_salt_ms_communication_syndic_configuration.json
{
    "command": "./docker-compose.sh exec salt_syndic1 cat /etc/salt/master",
    "path": "NA",
    "timeout": 3000,
    "description": "Check syndic configuration: Check if syndic_master is correctly set to the master's address.",
    "expected_result": {
        "return_code" : {
            "enabled" : "true",
            "value" : 0
        },
        "output" : {
            "enabled" : "true",
            "value" : "syndic_master:.*True"
        },
        "timeout" : {
            "enabled" : "false"
        },
        "additionnal_check" : {
            "enabled" : "false",
            "values" : {
                "value" : "",
                "value" : "",
                "value" : ""
            }
        }
    }
}
EOF

cat << EOF > run_def/check_salt_ms_communication_master_configuration.json
{
    "command": "./docker-compose.sh exec salt_master cat /etc/salt/master",
    "path": "NA",
    "timeout": 1000,
    "description": "Check master configuration: Ensure that order_masters is set to True on the master.",
    "expected_result": {
        "return_code" : {
            "enabled" : "true",
            "value" : 0
        },
        "output" : {
            "enabled" : "true",
            "value" : "order_masters:.*True"
        },
        "timeout" : {
            "enabled" : "false"
        },
        "additionnal_check" : {
            "enabled" : "false",
            "values" : {
                "value" : "",
                "value" : "",
                "value" : ""
            }
        }
    }
}
EOF

cat << EOF > run_def/check_salt_ms_communication_key_acceptance.json
{
    "command": "./docker-compose.sh exec salt_master salt-key -L",
    "path": "NA",
    "timeout": 3000,
    "description": "Check key acceptance: Check if the syndic's key is in the 'Accepted Keys' list.",
    "expected_result": {
        "return_code" : {
            "enabled" : "true",
            "value" : 0
        },
        "output" : {
            "enabled" : "true",
            "value" : "salt_syndic[1-2]"
        },
        "timeout" : {
            "enabled" : "false"
        },
        "additionnal_check" : {
            "enabled" : "false",
            "values" : {
                "value" : "",
                "value" : "",
                "value" : ""
            }
        }
    }
}
EOF

cat << EOF > run_def/check_salt_ms_communication_basic_salt_communication.json
{
    "command": "./docker-compose.sh exec salt_syndic1 salt-call test.ping",
    "path": "NA",
    "timeout": 3000,
    "description": "Check basic Salt communication: This should return True if Salt is functioning correctly on the syndic.",
    "expected_result": {
        "return_code" : {
            "enabled" : "true",
            "value" : 0
        },
        "output" : {
            "enabled" : "true",
            "value" : "True"
        },
        "timeout" : {
            "enabled" : "false"
        },
        "additionnal_check" : {
            "enabled" : "false",
            "values" : {
                "value" : "",
                "value" : "",
                "value" : ""
            }
        }
    }
}
EOF

cat << EOF > run_def/check_salt_ms_communication_syndic_logs.json
{
    "command": "./docker-compose.sh exec salt_syndic1 tail -n 100 /var/log/salt/syndic",
    "path": "NA",
    "timeout": 2000,
    "description": "Check syndic logs for more detailed error messages.",
    "expected_result": {
        "return_code" : {
            "enabled" : "true",
            "value" : 0
        },
        "output" : {
            "enabled" : "true",
            "value" : "^!.*(ERROR|CRITICAL).*"
        },
        "timeout" : {
            "enabled" : "false"
        },
        "additionnal_check" : {
            "enabled" : "false",
            "values" : {
                "value" : "",
                "value" : "",
                "value" : ""
            }
        }
    }
}
EOF

cat << EOF > run_def/check_salt_ms_communication_master_logs.json
{
    "command": "./docker-compose.sh exec salt_master tail -n 100 /var/log/salt/master",
    "path": "NA",
    "timeout": 2000,
    "description": "Check master logs for any related errors.",
    "expected_result": {
        "return_code" : {
            "enabled" : "true",
            "value" : 0
        },
        "output" : {
            "enabled" : "true",
            "value" : "^(?!.*\b(ERROR|CRITICAL)\b).*"
        },
        "timeout" : {
            "enabled" : "false"
        },
        "additionnal_check" : {
            "enabled" : "false",
            "values" : {
                "value" : "",
                "value" : "",
                "value" : ""
            }
        }
    }
}
EOF

cat << EOF > run_def/check_salt_ms_communication_ports_open.json
{
    "command": "./docker-compose.sh exec salt_master netstat -tulpn",
    "path": "NA",
    "timeout": 1000,
    "description": "Check that the necessary ports (typically 4505 and 4506) are open.",
    "expected_result": {
        "return_code" : {
            "enabled" : "true",
            "value" : 0
        },
        "output" : {
            "enabled" : "true",
            "value" : ".*4505|4506.*"
        },
        "timeout" : {
            "enabled" : "false"
        },
        "additionnal_check" : {
            "enabled" : "false",
            "values" : {
                "value" : "",
                "value" : "",
                "value" : ""
            }
        }
    }
}
EOF

echo "All JSON test files have been generated in the run_def directory."