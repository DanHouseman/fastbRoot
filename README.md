# FastbRoot, an Fastboot Unlock Code Generator
(For educational purposes only)

A simple Bash script that generates and tests unlock codes for devices using `fastboot`. It iterates through possible code combinations until the correct unlock code is found. The script supports both numeric and alphanumeric codes, and it maintains its state between runs with a device-specific data file.

## Features

- **Dynamic Code Generation:** Converts numeric iteration values into codes using a custom character set.
- **Persistent State:** Stores current state (`code_type`, `code_length`, and `last_value`) in a device-specific data file.
- **Robust Input Validation:** Prompts for and validates user input for code type and length.
- **Graceful Exit:** Saves the current state on exit or interruption using signal traps.

## Prerequisites

- **Bash:** The script is written for Bash and requires a Unix-like shell.
- **fastboot:** Ensure that the `fastboot` command is installed and available in your system’s PATH.  
  - Install via your package manager or as part of the Android SDK.
- **Device in Fastboot Mode:** A connected device recognized by `fastboot devices` is necessary for the script to function.

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/DanHousemab/fastbRoot.git
   cd fastbRoot
   ```

2. **Make the Script Executable:**

   ```bash
   chmod +x fastbRoot.sh
   ```

## Usage

Run the script from the terminal:

```bash
./fastbRoot.sh
```

### What to Expect

- **Device Detection:** The script uses `fastboot devices` to determine the connected device. It then creates a data file named `<device>.dat` in the current directory.
- **Initial Setup:** If the data file does not exist, you will be prompted to specify:
  - The code type (`numeric` or `alphanumeric`)
  - The code length (validated as a positive integer)
- **Code Generation Loop:** The script iteratively generates unlock codes and attempts to unlock the device using `fastboot oem unlock <code>`. It displays the current attempt and updates the data file with the current state.
- **Success Notification:** Once a code does not trigger a failure response from `fastboot`, the script prints out the successful unlock code and exits.

## Configuration Details

- **Data File:** A file (`<device>.dat`) is created to persist the configuration and state. This includes:
  - `code_type`: Either `numeric` or `alphanumeric`
  - `code_length`: Length of the unlock code
  - `last_value`: The current iteration count used to generate the unlock code
- **Unlock Code Generation:** Uses a custom function to convert a number (`last_value`) into a code string based on the provided character set.

## Troubleshooting

- **fastboot Not Found:**  
  Ensure that `fastboot` is installed and accessible. Test with:
  ```bash
  fastboot --version
  ```
- **No Device Detected:**  
  Verify that your device is in fastboot mode and properly connected.
- **Permission Issues:**  
  If you encounter permission errors, double-check that the script is executable:
  ```bash
  chmod +x fastbRoot.sh
  ```
