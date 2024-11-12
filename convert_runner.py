import os
import json
import csv
import argparse
import logging
from datetime import datetime

def load_config(config_path):
    with open(config_path, 'r') as config_file:
        return json.load(config_file)

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
        logging.getLogger().addHandler(console_handler)

def json_to_csv(json_file, csv_writer):
    with open(json_file, 'r') as f:
        data = json.load(f)
    
    additional_check_values = data['expected_result']['additionnal_check']['values']
    if isinstance(additional_check_values, dict):
        additional_check_values = list(additional_check_values.values())
    elif not isinstance(additional_check_values, list):
        additional_check_values = [additional_check_values]
    
    row = [
        os.path.basename(json_file),
        data['command'],
        data['path'],
        data['timeout'],
        data['description'],
        data['expected_result']['return_code']['enabled'],
        data['expected_result']['return_code']['value'],
        data['expected_result']['output']['enabled'],
        data['expected_result']['output']['value'],
        data['expected_result']['timeout']['enabled'],
        data['expected_result']['additionnal_check']['enabled'],
    ] + additional_check_values
    
    csv_writer.writerow(row)
    return row

def csv_to_json(csv_file, output_dir):
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            additional_check_values = [value for key, value in row.items() if key.startswith('additionnal_check_value') and value]
            json_obj = {
                "command": row['command'],
                "path": row['path'],
                "timeout": int(row['timeout']),
                "description": row['description'],
                "expected_result": {
                    "return_code": {
                        "enabled": row['return_code_enabled'],
                        "value": int(row['return_code_value'])
                    },
                    "output": {
                        "enabled": row['output_enabled'],
                        "value": row['output_value']
                    },
                    "timeout": {
                        "enabled": row['timeout_enabled']
                    },
                    "additionnal_check": {
                        "enabled": row['additionnal_check_enabled'],
                        "values": additional_check_values
                    }
                }
            }
            
            output_file = os.path.join(output_dir, row['filename'])
            with open(output_file, 'w') as json_file:
                json.dump(json_obj, json_file, indent=4)

def generate_markdown(rows, md_file):
    with open(md_file, 'w') as f:
        f.write("# Test Definitions\n\n")
        headers = ["Filename", "Command", "Path", "Timeout", "Description", 
                   "Return Code Enabled", "Return Code Value", 
                   "Output Enabled", "Output Value", 
                   "Timeout Enabled", "Additional Check Enabled"]
        
        max_additional_checks = max(len(row) - len(headers) for row in rows)
        
        for i in range(max_additional_checks):
            headers.append(f"Additional Check Value {i+1}")
        
        f.write("| " + " | ".join(headers) + " |\n")
        f.write("|" + "---|" * len(headers) + "\n")
        
        for row in rows:
            f.write("| " + " | ".join(str(cell) for cell in row) + " |\n")

def main():
    parser = argparse.ArgumentParser(description='Convert between JSON and CSV formats for test definitions.')
    parser.add_argument('--json-dir', required=False, help='Directory containing JSON files (mandatory if converting to CSV)')
    parser.add_argument('--convert-to', choices=['json_run', 'csv_def'], required=True, help='Conversion direction')
    args = parser.parse_args()

    # Load configuration from a JSON file with the same name as the script
    script_name = os.path.splitext(os.path.basename(__file__))[0]
    config_path = os.path.join(os.path.dirname(__file__), f"{script_name}.json")
    
    config = load_config(config_path)

    # Setup logging based on configuration
    setup_logging(config["log_path"], config["log_level"], config["log_output"])

    if args.convert_to == 'csv_def':
        if not args.json_dir:
            print("Error: --json-dir is mandatory when --convert-to=csv_def.")
            return
        
        csv_file_name = f"{config['output_base_name']}.csv"
        md_file_name = f"{config['output_base_name']}.md"
        
        rows = []
        
        with open(csv_file_name, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile, delimiter=config["csv_separator"])
            headers = ['filename', 'command', 'path', 'timeout', 'description', 
                       'return_code_enabled', 'return_code_value',
                       'output_enabled', 'output_value',
                       'timeout_enabled',
                       'additionnal_check_enabled']
            
            for json_file in os.listdir(args.json_dir):
                if json_file.endswith('.json'):
                    file_path = os.path.join(args.json_dir, json_file)
                    row = json_to_csv(file_path, writer)
                    rows.append(row)
                    
                    # Update headers if necessary
                    while len(headers) < len(row):
                        headers.append(f'additionnal_check_value{len(headers) - 10}')
            
            # Write headers after processing all files
            writer.writerow(headers)
            
            # Write rows again with correct headers
            for row in rows:
                writer.writerow(row)
        
        generate_markdown(rows, md_file_name)
        print(f"CSV file '{csv_file_name}' and Markdown file '{md_file_name}' have been created.")

    elif args.convert_to == 'json_run':
        input_file = os.path.join(args.json_dir, f"{config['output_base_name']}.csv")
        
        if not os.path.exists(input_file):
            print(f"Error: {input_file} not found.")
            return
        
        output_dir = os.path.join(args.json_dir, 'json_output')
        os.makedirs(output_dir, exist_ok=True)
        
        csv_to_json(input_file, output_dir)
        print(f"JSON files have been created in '{output_dir}'.")

if __name__ == "__main__":
    main()