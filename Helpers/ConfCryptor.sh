#!/bin/bash

#  ConfCryptor.sh
#  Copyright © 2017-present userADgents. All rights reserved.

# Don't run when compiling for Previews. This would invalidate the current
# build and Previews would fail.
[[ $(echo "$BUILD_ROOT" | grep "Previews" | wc -l) -eq 1 ]] && {
     echo "Bailing out while compiling Previews"
     exit 0
}

which jq 1>/dev/null || {
    brew update
    brew install jq
    which jq 1>/dev/null || {
        echo "❌ jq is missing. Please install it with `brew install jq` and try again."
        exit 1
    }
}

CRYPTOR="$(echo "$BUILD_ROOT" | sed 's%/Build/.*%%')/SourcePackages/checkouts/Slab/Helpers/ConfCryptor"
[[ -x "$CRYPTOR" ]] || {
    echo "❌ Cannot find ConfCryptor tool. Make sure the project is setup in accordance to the README.md of Slab"
    exit 1
}

[[ -d "$SCRIPT_INPUT_FILE_0" ]] || {
    echo "❌ Please provide the full path to your Environments directory in the Input Files section of your Run Script build phase."
    exit 1
}

cd "$SCRIPT_INPUT_FILE_0"

function realpath { echo $(cd $(dirname $1); pwd)/$(basename $1); }
tmp=$(mktemp)

ls *.json | while read i; do
    cat "$i" | jq . >/dev/null || {
        echo "❌ jq says that $(basename "$i") is not valid json. Aborting."
        exit 2
    }
    echo -n "$(basename "$i") "
    "$CRYPTOR" "$(realpath "$i")"
done
