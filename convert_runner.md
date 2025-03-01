# Test Runner Script

This script is designed to execute tests defined in JSON files. It logs the results and can convert JSON test definitions into CSV and Markdown formats.

## Features

- Execute commands specified in JSON files.
- Log outputs to both console and file.
- Convert JSON test definitions into CSV and Markdown formats.
- Filter tests based on specified criteria.

## Requirements

- Python 3.x
- Required Python packages:
  - pandas

You can install the required packages using pip:

```bash
pip install pandas
```

## Configuration
The script uses a configuration file named convert_runner.json that should be located in the same directory as the script. The configuration file should have the following structure:

```json
{
    "log_path": "./logs",
    "results_path": "./outputs",
    "filter_tests": ".*",
    "log_level": "INFO",
    "log_output": "file,console",
    "csv_separator": "\t",
    "output_base_name": "test_definitions"
}
```

## Configuration Fields
- log_path: Directory where log files will be saved.
- results_path: Directory where output result files (CSV, Markdown) will be saved.
- filter_tests: A regex pattern used to filter which tests to execute.
- log_level: Sets the logging level (e.g., DEBUG, INFO, WARNING, ERROR).
- log_output: Determines where logs will be directed (e.g., to a file, console, or both).
- csv_separator: Character used as a separator in CSV files (e.g., tab).
- output_base_name: Base name for output files (CSV and Markdown).

## Usage
### Running Tests
To execute the tests defined in JSON files, use the following command:
```bash
convert_runner.sh --json-dir /path/to/json/files --convert-to csv_def
```

### Converting CSV Files Back to JSON
To convert a CSV file back into multiple JSON files:
```bash
convert_runner.sh --json-dir /path/to/csv/file --convert-to json_run
```

### Arguments
```bash
--json-dir: Directory containing JSON files (mandatory when converting to CSV).
--convert-to: Specifies the conversion direction (json_run or csv_def).
```

### Logging
The script logs its actions based on the configuration specified in convert_runner.json. Logs can be directed to both a file and the console as per your configuration settings.

### Output
After execution, results will be saved in:
- CSV format: test_definitions.csv
- Markdown format: test_definitions.md
- Log files will be saved in the specified log directory.

### Example Structure
Here’s an example of how your project directory might look:
```bash
/your_project_directory
│
├── convert_runner.py
├── convert_runner.json
├── logs/
├── outputs/
└── json_files/
    ├── test1.json
    ├── test2.json
    └── ...
```

### License
This project is licensed under the MIT License - see the LICENSE file for details.


### Explanation of Sections:

1. **Title**: The title of the README.
2. **Features**: A brief overview of what the script does.
3. **Requirements**: Lists necessary software and packages.
4. **Configuration**: Details how to set up the configuration file.
5. **Usage**: Instructions on how to run the script with examples.
6. **Logging**: Information on how logging works within the script.
7. **Output**: Describes what outputs are generated by the script.
8. **Example Structure**: Provides an example of how to organize project files.
9. **License**: Mentions licensing information.

This README provides clear guidance on setting up and using your script effectively. If you need further modifications or additional sections, feel free to ask!