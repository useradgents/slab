#!/bin/bash

################################################################################
#
# Localise.biz.sh
# Copyright © 2019-present USERADGENTS
# Version 1.0 (2021-08-02)
# Author: Cyrille Legrand <c@uad.io>
#
################################################################################
#
# This script fetches localization tables from localise.biz, and updates
# Localizable.strings files accordingly.
#
################################################################################
#
# Configuration is read from Xcode project settings.
# Please declare these "User-Defined settings" at the bottom of your Xcode
# build settings:
#
# LOCALISE_API_KEY
#    The API key used when calling Localise.biz APIs
#
# LOCALISE_LANGUAGES
#    The languages to generate.
#    Example: "en,fr"
#
# LOCALISE_SHORT_NAME
#    The short name of the project (in Project Settings)
#    Example: "lacoste-instant-delivery"
#
# LOCALISE_LOCALIZABLESTRINGS_PATH
#    The path, relative to the PROJECT_DIR, where Localizable.strings are
#    If unset, won't update Localizable.strings
#    Example: "Assets"
#
# LOCALISE_INFOPLISTSTRINGS_PATH
#    The path, relative to the PROJECT_DIR, where InfoPlist.strings are
#    If unset, won't update InfoPlist.strings
#    Example: "Supporting Files"
#
################################################################################


# Make preprocessor definitions available to Bash
eval "${GCC_PREPROCESSOR_DEFINITIONS}"

fail() {
    echo "$1"
    if [ -z ${LOCALISE_CONTINUE_ON_ERROR+x} ]; then
        exit 1
    else
        exit 0
    fi
}

##### PRECONDITIONS ############################################################

# Make sure we have an API key
[ -z ${LOCALISE_API_KEY+x} ] && fail "LOCALISE_API_KEY not set"
[ -z ${LOCALISE_SHORT_NAME+x}] && fail "LOCALISE_SHORT_NAME not set"

# Make sure we have a list of languages
[ -z ${LOCALISE_LANGUAGES+x} ] && fail "LOCALISE_LANGUAGES not set"
LANGUAGES=$(echo ${LOCALISE_LANGUAGES} | tr ',' '\n')

##### FETCH ####################################################################
rm -rf /tmp/localise_strings
mkdir -p /tmp/localise_strings
curl "https://localise.biz/api/export/archive/strings.zip?key=${LOCALISE_API_KEY}&filter=!android-only&fallback=${LOCALISE_FALLBACK_LANGUAGE+en}&random=$(date +%s)" --max-time 5 -s > /tmp/localise_strings.zip || exit 0
unzip /tmp/localise_strings.zip -d /tmp/localise_strings 2>/dev/null >/dev/null || exit 0
rm /tmp/localise_strings.zip

##### EXTRACT ##################################################################
for LANG in $LANGUAGES; do
    mkdir -p /tmp/localise_strings/${LOCALISE_SHORT_NAME}-strings-archive/${LANG}.lproj
    iconv -f UTF-16be -t UTF-8 /tmp/localise_strings/${LOCALISE_SHORT_NAME}-strings-archive/${LANG}.lproj/Localizable.strings > /tmp/foo.strings
    
    # Extract stuff for Localizable.strings
    [ -z ${LOCALISE_LOCALIZABLESTRINGS_PATH+x} ] || {
        cat /tmp/foo.strings | grep -v " \* Exported " | sed 's/%s/%@/' > /tmp/Localizable.strings
        iconv -f UTF-8 -t UTF-16 /tmp/Localizable.strings > "${PROJECT_DIR}/${LOCALISE_LOCALIZABLESTRINGS_PATH}/${LANG}.lproj/Localizable.strings"
    }
    
    # Extract stuff for Infoplist.strings
    [ -z ${LOCALISE_INFOPLISTSTRINGS_PATH+x} ] || {
        cat /tmp/foo.strings | grep "^\"ios_infoplist_" | sed 's/%s/%@/' | sed "s/ios_infoplist_//" > /tmp/infoplist.strings
        iconv -f UTF-8 -t UTF-16 /tmp/infoplist.strings > "${PROJECT_DIR}/${LOCALISE_INFOPLISTSTRINGS_PATH}/${LANG}.lproj/InfoPlist.strings"
    }
done

rm -rf /tmp/localise_strings
rm -rf /tmp/foo.strings
rm -rf /tmp/Localizable.strings
rm -rf /tmp/infoplist.strings
