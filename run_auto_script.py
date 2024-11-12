import os
import json
import re
import logging
import argparse
import subprocess
import pandas as pd
from datetime import datetime

csv_file = None
md_file = None

def setup_logging(log_path, log_level, log_output):
    log_filename = os.path.join(log_path, f"{os.path.basename(__file__).split('.')[0]}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")
    if not logging.getLogger().hasHandlers():
        logging.basicConfig(level=log_level, format='%(asctime)s - %(levelname)s - %(message)s')
    outputs = [output.strip() for output in log_output.split(',')]
    if 'file' in outputs:
        file_handler = logging.FileHandler(log_filename)
        file_handler.setLevel(log_level)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        file_handler.setFormatter(formatter)
        logging.getLogger().addHandler(file_handler)
    if 'console' in outputs:
        console_handler = logging.StreamHandler()
        console_handler.setLevel(log_level)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        console_handler.setFormatter(formatter)
        if not any(isinstance(h, logging.StreamHandler) for h in logging.getLogger().handlers):
            logging.getLogger().addHandler(console_handler)

def load_config(config_path):
    with open(config_path, 'r') as config_file:
        return json.load(config_file)

def execute_command(command, run_path, timeout):
    try:
        result = subprocess.run(command, cwd=run_path, shell=True, capture_output=True, text=True, timeout=timeout / 1000)
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except subprocess.TimeoutExpired:
        logging.error(f"Timeout expired for command: {command}")
        return None, "", "Timeout expired"
    except Exception as e:
        logging.error(f"Error executing command '{command}': {e}")
        return None, "", str(e)

def filter_json_files(json_files, filter_regex):
    return [f for f in json_files if re.search(filter_regex, f)]

def create_directories(paths):
    for path in paths:
        if not os.path.exists(path):
            os.makedirs(path)

def escape_markdown(value):
    return str(value).replace('|', '[PIPE]')

def clean_output(output):
    cleaned_output = re.sub(r'\s+', ' ', output)
    cleaned_output = re.sub(r'[^\w\s,.!]', '', cleaned_output)
    return cleaned_output[:40]

def check_output_against_regex(output_message, expected_value):
    return re.search(expected_value, output_message, re.MULTILINE) is not None

def extract_error_message(output):
    match = re.search(r'(ERROR|CRITICAL):?\s*(.*)', output)
    return match.group(2).strip() if match else output

def save_results(results):
    global csv_file, md_file
    df = pd.DataFrame(results, columns=["Timestamp", "Description", "Command", "Expected Result", "Timeout", "Rule", "Output", "Status"])
    df.to_csv(csv_file, index=False)
    with open(md_file, 'w') as file:
        file.write("# Test Results\n\n")
        file.write("| Timestamp | Description | Command | Expected Result | Timeout | Rule | Output | Status |\n")
        file.write("|-----------|-------------|---------|-----------------|---------|------|--------|--------|\n")
        for result in results:
            escaped_result = [escape_markdown(item) for item in result]
            file.write(f"| {' | '.join(escaped_result)} |\n")

def run_test(test_definition, run_path):
    command = test_definition['command']
    path = test_definition.get('path', run_path)
    if path in ["", "NA", "N/A"]:
        path = run_path
    timeout = test_definition.get('timeout', 1000)
    description = test_definition['description']
    expected_result = test_definition['expected_result']

    return_code, output_message, error_message = execute_command(command, path, timeout)

    status = "SUCCESS"
    reasons = []

    if expected_result['return_code']['enabled'] == "true":
        expected_return_code = int(expected_result['return_code']['value'])
        if return_code != expected_return_code:
            status = "FAILED"
            reasons.append(f"Expected return code {expected_return_code}, got {return_code}")

    if expected_result['output']['enabled'] == "true":
        expected_output = expected_result['output']['value']
        if not check_output_against_regex(output_message, expected_output):
            status = "FAILED"
            reasons.append(f"Output did not match expected regex: {expected_output}")

    if expected_result['timeout']['enabled'] == "true":
        if return_code is None:
            status = "FAILED"
            reasons.append("Command timed out")

    if expected_result['additionnal_check']['enabled'] == "true":
        for value in expected_result['additionnal_check']['values'].values():
            # Implement additional check logic here if needed
            pass

    output_contracted = clean_output(extract_error_message(output_message or error_message or ""))

    return {
        "timestamp": datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        "description": description,
        "command": command,
        "expected_result": json.dumps(expected_result),
        "timeout": timeout,
        "output": output_contracted,
        "status": status,
        "reasons": reasons
    }

def main():
    global csv_file, md_file
    parser = argparse.ArgumentParser(description='Execute tests defined in JSON files.')
    parser.add_argument('--filter-tests', type=str, help='Filter to select tests to execute.')
    parser.add_argument('--run-path', type=str, help='Working path for command execution.')
    args = parser.parse_args()

    config = load_config('run_auto_script')
    TEST_SCRIPTS_PATH = config['TEST_SCRIPTS_PATH']
    LOG_PATH = config['LOG_PATH']
    RESULTS_PATH = config['RESULTS_PATH']
    FILTER_TESTS = args.filter_tests if args.filter_tests else config['FILTER_TESTS']
    RUN_PATH = args.run_path if args.run_path else config['RUN_WORKDIR']

    log_level = getattr(logging, config.get('LOG_LEVEL', 'INFO').upper(), logging.INFO)
    log_output = config.get('LOG_OUTPUT', 'file,console')

    create_directories([LOG_PATH, RESULTS_PATH])
    setup_logging(LOG_PATH, log_level, log_output)

    if not os.path.exists(TEST_SCRIPTS_PATH):
        logging.error(f"TEST_SCRIPTS_PATH does not exist: {TEST_SCRIPTS_PATH}")
        return

    if not os.path.exists(RUN_PATH) and RUN_PATH != "":
        logging.error(f"RUN_PATH does not exist: {RUN_PATH}")
        return

    csv_file = os.path.join(RESULTS_PATH, 'results.csv')
    md_file = os.path.join(RESULTS_PATH, 'results.md')

    json_files = [f for f in os.listdir(TEST_SCRIPTS_PATH) if f.endswith('.json')]
    filtered_files = filter_json_files(json_files, FILTER_TESTS)

    results = []
    for json_file in filtered_files:
        with open(os.path.join(TEST_SCRIPTS_PATH, json_file), 'r') as file:
            test_definition = json.load(file)
        
        result = run_test(test_definition, RUN_PATH)
        
        rule_name_shortened = f"[{json_file}]({os.path.join('..', TEST_SCRIPTS_PATH, json_file)})"
        
        results.append([
            result['timestamp'],
            result['description'],
            result['command'],
            result['expected_result'],
            result['timeout'],
            rule_name_shortened,
            result['output'],
            result['status']
        ])
        
        logging.info(f"Test executed: {result['description']} - Status: {result['status']}")
        
        test_log_filename = os.path.join(LOG_PATH, f"{os.path.splitext(json_file)[0]}_log.yaml")
        with open(test_log_filename, 'w') as test_log_file:
            json.dump(result, test_log_file, indent=2)
        
        results[-1][-1] += f" [Log]({os.path.relpath(test_log_filename, RESULTS_PATH)})"

    save_results(results)
    logging.info(f"Results saved in file: {md_file}")

if __name__ == "__main__":
    main()