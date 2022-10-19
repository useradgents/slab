#!/bin/bash

######################################################################################
#
# versionWizard.sh
# Copyright © 2019-present USERADGENTS
# Version 1.3 (2021-05-14)
# Author: Cyrille Legrand <c@uad.io>
#
######################################################################################
#
# The goal of this script is to automatically handle updating build number and
# synchronizing public version of an iOS app.
#
# Build numbers are auto-incremented on each Archive action, and multiple builds
# from the same commit yield the same build number, which is useful for having
# synchronized Development and Distribution targets for an app.
#
# Make sure this script has "Run script only when installing" checked, so that it
# only operates on Archive builds. Otherwise, every single build-and-run will increase
# the build number.
#
######################################################################################
#
# Configuration for this project is read from Xcode project settings.
# Please declare these "User-Defined settings" at the bottom of your Xcode build settings:
#
# VW_APP_ID
#    The id of this app. Usually `ios.myAppName`. Mandatory.
#
# VW_PUBLIC_VERSION_MODE
#    Define how we handle public version numbers
#    Values :
#      `semver`: use X.Y.Z public versions (even if Z=0). This is the default value
#      `semver_nozero`: use X when Y=Z=0, X.Y when Z=0, X.Y.Z otherwise
#      `semver_nozerobuild`: use X.Y when Z=0, X.Y.Z otherwise
#      `skip`: don't touch public version at all
#
# VW_PREPEND_PUBLIC_TO_BUILD
#    If set, the build number will be prepended by the public version.
#    This way, build number will look like X.Y.Z.BBBB
#
# VW_CONTINUE_ON_ERROR
#    By default, any error will halt the build.
#    Setting this flag will allow the build to continue.
#    Beware: resulting IPA will probably be rejected by publishing services
#    because the build number will already have been used.
#
# VW_NO_TAG
#    By default, a tag named "v$PUBLIC-build$BUILD" will be pushed to the origin
#    repository. Setting VW_NO_TAG will avoid tagging the commit.
#
######################################################################################
#
# Should you want to manually define the public version:
#
# To go from X.Y.Z to (X+1).0.0 :
#    curl "https://uad.io/versionWizard.php?id=${VW_APP_ID}&nextMajor"
#
# To go from X.Y.Z to X.(Y+1).0 :
#    curl "https://uad.io/versionWizard.php?id=${VW_APP_ID}&nextMinor"
#
# To go from X.Y.Z to X.Y.(Z+1) :
#    curl "https://uad.io/versionWizard.php?id=${VW_APP_ID}&nextPatch"
#
# To go manually to X.Y.Z :
#    curl "https://uad.io/versionWizard.php?id=${VW_APP_ID}&setPublicVersion=X.Y.Z"
#
# To go manually to X.Y.Z, build BBBB :
#    curl "https://uad.io/versionWizard.php?id=${VW_APP_ID}&setPublicVersion=X.Y.Z&setBuildNumber=BBBB"
#
######################################################################################
#
# Version History
#
#   1.2 - March 2021: Integrate into Slab
#   1.3 - May 14, 2021: Add support for App Clips
#
######################################################################################

# Don't run when compiling for Previews. This would invalidate the current
# build and Previews would fail.
[[ $(echo "$BUILD_ROOT" | grep "Previews" | wc -l) -eq 1 ]] && {
     echo "Bailing out while compiling Previews"
     exit 0
}

# Make preprocessor definitions available to Bash
eval "${GCC_PREPROCESSOR_DEFINITIONS}"

fail() {
    echo "$1"
    if [ -z ${VW_CONTINUE_ON_ERROR+x} ]; then
        exit 1
    else
        exit 0
    fi
}


##### PRECONDITIONS ###########################################3

# Make sure we have an id
[ -z ${VW_APP_ID+x} ] && fail "VW_APP_ID not set"

# Make sure jq is installed
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
which jq >/dev/null || fail "jq is not installed"

# Make sure PlistBuddy is there
[ -f "/usr/libexec/PlistBuddy" ] || fail "PlistBuddy is not installed"

# Make sure server is reachable
curl -m 3 -f "https://uad.io/versionWizard.php?id=${VW_APP_ID}" 1>/dev/null 2>/dev/null || fail "Server not reachable"

##### PREPARATION ###########################################3

# Get the hash of HEAD
COMMIT=$(git rev-parse --verify HEAD)

# Call the API to get an incremented build number
JSON=`mktemp`.json || fail "Unable to create temporary file"
curl "https://uad.io/versionWizard.php?id=${VW_APP_ID}&commit=${COMMIT}" -o $JSON 2>/dev/null
PUBLIC="$(jq -r '.publicVersion' $JSON)"
BUILD="$(jq -r '.buildNumber' $JSON)"
rm $JSON

# Change public version format based on flags
if [ "${VW_PUBLIC_VERSION_MODE}" = "semver_nozero" ]; then
    # Skip all trailing .0
    PUBLIC="$(echo "$PUBLIC" | sed 's/\(\.0\)*$//')"
elif [ "${WM_PUBLIC_VERSION_MODE}" = "semver_nozerobuild" ]; then
    # Skip only last .0 (for build number only)
    PUBLIC="$(echo "$PUBLIC" | sed 's/\(\.0\)$//')"
fi

# Change build number into public.build if needed
[ -z ${VW_PREPEND_PUBLIC_TO_BUILD+x} ] || BUILD="$PUBLIC.$BUILD"

##### ACTUAL SETTING OF VALUES ###########################################3

# Update or add build info to the main app
/usr/libexec/PlistBuddy -c "Set :BuildCommit \"$(git log --pretty=format:'%h' -n 1)\"" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :BuildCommit string \"$(git log --pretty=format:'%h' -n 1)\"" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" 2>/dev/null
/usr/libexec/PlistBuddy -c "Set :BuildTime \"$(date)\"" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :BuildTime string \"$(date)\"" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" 2>/dev/null
/usr/libexec/PlistBuddy -c "Set :BuildMachine \"$(uname -a)\"" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :BuildMachine string \"$(uname -a)\"" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}" 2>/dev/null

# Write version numbers and build info to main app
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion \"$BUILD\"" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
[ "${VW_PUBLIC_VERSION_MODE}" = "skip" ] ||
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString \"$PUBLIC\"" "${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
    
# Carry over to DSYM Info.plist
DSYM_INFO_PLIST="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist"
if [ -f "$DSYM_INFO_PLIST" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion \"$BUILD\"" "$DSYM_INFO_PLIST"
    [ "${VW_PUBLIC_VERSION_MODE}" = "skip" ] ||
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString \"$PUBLIC\"" "$DSYM_INFO_PLIST"
fi

# Carry over to embedded app extensions (aka plugins) if they exist
[ -d "${TARGET_BUILD_DIR}/${PLUGINS_FOLDER_PATH}" ] && find "${TARGET_BUILD_DIR}/${PLUGINS_FOLDER_PATH}" -maxdepth 1 -name "*.appex" 2>/dev/null | while read appex; do
    if [ -f "${appex}/Info.plist" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion \"$BUILD\"" "${appex}/Info.plist"
        [ "${VW_PUBLIC_VERSION_MODE}" = "skip" ] ||
            /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString \"$PUBLIC\"" "${appex}/Info.plist"
    fi
done

# Carry over to embedded App Clips if they exist
[ -d "${TARGET_BUILD_DIR}/${EXECUTABLE_FOLDER_PATH}/AppClips" ] && find "${TARGET_BUILD_DIR}/${EXECUTABLE_FOLDER_PATH}/AppClips" -maxdepth 1 -name "*.app" 2>/dev/null | while read appclip; do
    if [ -f "${appclip}/Info.plist" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion \"$BUILD\"" "${appclip}/Info.plist"
        [ "${VW_PUBLIC_VERSION_MODE}" = "skip" ] ||
            /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString \"$PUBLIC\"" "${appclip}/Info.plist"
    fi
done

echo "✅ Build number synchronized to ${BUILD}, version ${PUBLIC}"

# Create and push a git tag
[ -z ${VW_NO_TAG+x} ] && {
    echo "Pushing tag…"
    git tag "v$PUBLIC-build$BUILD" 2>&1
    git push origin "v$PUBLIC-build$BUILD" 2>&1
    echo "✅ Tag pushed to origin"
}
