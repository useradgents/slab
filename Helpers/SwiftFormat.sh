#!/bin/bash

######################################################################################
#
# SwiftFormat.sh
# Copyright © 2019-present USERADGENTS
# Version 1.0 (2023-11-21)
# Authors: Emilien Roussel and Guillaume Afanou
#
######################################################################################
#
# ⚠️ PLEASE READ THIS AT LEAST ONCE, AND UNDERSTAND IT FULLY BEFORE MAKING CHANGES
#     TO YOUR VERSION MANAGEMENT SYSTEM.
#     Should you have any doubt, please contact us.
#
#
######################################################################################
#
# Configuration for this project is read from Xcode project settings.
# Please declare these "User-Defined settings" at the bottom of your Xcode build settings:
#
# RULES_PATH
#    The destination path for the swiftFormat file configuration
#
#
######################################################################################
# Set the URL of the .swiftformat file
SWIFTFORMAT_FILE_URL="https://bitbucket.org/useradgents/main/raw/HEAD/.swiftformat"

# Download the .swiftformat file
curl -L -o "${RULES_PATH}" "${SWIFTFORMAT_FILE_URL}"

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo ".swiftformat file downloaded successfully."
    
    # Make sure jq is installed
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    which jq >/dev/null || fail "jq is not installed"
    
    # Check if SwiftFormat is available in the PATH
    if which swiftformat > /dev/null; then
      swiftformat .
    else
      echo "error: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
    fi
else
    echo "Failed to download .swiftformat file."
    exit 1
fi
