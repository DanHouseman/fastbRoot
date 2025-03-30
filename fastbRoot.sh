#!/bin/bash
clear

# Global variables
declare code_type code_length last_value charset devfile

# Function to read device data from file into global variables
read_devfile() {
  if [[ -f "$devfile" ]]; then
    while IFS='=' read -r key value; do
      case "$key" in
        code_type) code_type="$value" ;;
        code_length) code_length="$value" ;;
        last_value) last_value="$value" ;;
      esac
    done < "$devfile"
  fi
}

# Function to write device data to file
write_devfile() {
  cat > "$devfile" <<EOF
code_type=$code_type
code_length=$code_length
last_value=$last_value
EOF
}

# Function to convert a number to a code string using the charset
number_to_code() {
  local num=$1 length=$2 base index code=""
  base=${#charset}
  while (( ${#code} < length )); do
    index=$(( num % base ))
    code="${charset:index:1}$code"
    num=$(( num / base ))
  done
  echo "$code"
}

# Extract the current device name from fastboot devices using awk for robustness
device=$(fastboot devices | awk 'NF{print $1; exit}')
printf "Current device: %s\n" "$device"
devfile="./${device}.dat"

# If devfile doesn't exist, prompt for settings
if [[ ! -f "$devfile" ]]; then
  while true; do
    read -r -p "Does the device use numeric or alphanumeric codes? (n/a): " input_type
    case "$input_type" in
      n|numeric)
        code_type="numeric"
        break
        ;;
      a|alphanumeric)
        code_type="alphanumeric"
        break
        ;;
      *)
        echo "Please enter 'n' for numeric or 'a' for alphanumeric."
        ;;
    esac
  done

  # Validate code length input as a positive integer
  while true; do
    read -r -p "Enter code length (positive integer): " input_length
    if [[ "$input_length" =~ ^[1-9][0-9]*$ ]]; then
      code_length=$input_length
      break
    else
      echo "Invalid input. Please enter a positive integer."
    fi
  done
  last_value=0
  write_devfile
else
  read_devfile
fi

# Set charset based on code type
if [[ "$code_type" == "numeric" ]]; then
  charset='0123456789'
elif [[ "$code_type" == "alphanumeric" ]]; then
  charset='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
else
  echo "Invalid code type: $code_type"
  exit 1
fi

# Trap to save device data on exit or interrupt
trap 'write_devfile; exit' EXIT SIGINT

while true; do
  code=$(number_to_code "$last_value" "$code_length")
  
  # Try to unlock the device and capture output
  output=$(fastboot oem unlock "$code" 2>&1)
  
  # Check if the unlock was successful
  if ! grep -iqE 'fail(ed|ure)?' <<< "$output"; then
    echo -e "\nYour unlock code is: $code"
    break
  fi
  
  # Display the current attempt using printf
  printf "Trying code: %s\r" "$code"
  
  (( last_value++ ))
  write_devfile
done
