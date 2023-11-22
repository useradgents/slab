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
# Create a temporary file
CONFIG_FILE=`mktemp`.swiftformat || fail "Unable to create temporary file"

# Download the .swiftformat file
curl "https://bitbucket.org/useradgents/main/raw/HEAD/.swiftformat" -o $CONFIG_FILE 2>/dev/null

# Check if the download was successful
[ $? -eq 0  ] || {
    echo "Failed to download config file";
    exit 1
}

# Check if Swiftformat is correctly installed
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
which swiftformat >/dev/null || {
    echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
    exit 0
}

# Use the temporary file to perform the swiftformat process
swiftformat --config $CONFIG_FILE .

# Remove the unecessary temporary file
rm $CONFIG_FILE
