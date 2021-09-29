#!/bin/bash

######################################################################################
#
# versionWizard.sh
# Copyright © 2019-present USERADGENTS
# Version 2.0 (2021-09-10)
# Author: Cyrille Legrand <c@uad.io>
#
######################################################################################
#
# ⚠️ PLEASE READ THIS AT LEAST ONCE, AND UNDERSTAND IT FULLY BEFORE MAKING CHANGES
#     TO YOUR VERSION MANAGEMENT SYSTEM.
#     Should you have any doubt, please contact me.
#
#
# The goal of this script is to automatically handle updating build number and
# synchronizing public version of an iOS app.
#
# Build numbers are auto-incremented on each Archive action, and multiple builds
# from the same commit yield the same build number, which is useful for having
# synchronized Development and Distribution targets for an app.
#
# Public version numbers are managed by defining a "train", and the script
# automatically picks a correct public version based on the status of this
# version on iTunes Connect. (See section below for detailed explanations)
#
# Make sure this script has "Run script only when installing" checked, so that it
# only operates on Archive builds. Otherwise, every single build-and-run will increase
# the build number.
#
# You will need an App Store Connect API key, which the Account Holder can generate
# on https://appstoreconnect.apple.com/access/api
# It needs to have at least the "App Manager" role.
# Documentation for creating it can be found on Apple's Developer website, at:
# https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api
#
######################################################################################
#
# Configuration for this project is read from Xcode project settings.
# Please declare these "User-Defined settings" at the bottom of your Xcode build settings:
#
# VW_APP_ID
#    The Apple ID of this app (digits only)
#
# VW_KEY_ISSUER
# VW_KEY_ID
# VW_KEY_P8
#    App Store Connect public key information.
#    The P8 is the full file path, not the contents of the P8. Double-quote it if
#    it contains spaces.
#    See "Continuous Integration" below for a way to keep the key secret.
#
# VW_PREPEND_PUBLIC_TO_BUILD
#    If set, the build number will be prefixed by the public version.
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
# Starting with version 2, the public version is controlled by two things:
# - the presence (or absence) of a "train" in the current git branch name
# - the last published version on the App Store.
#
# A "train" is the leading part of a public version number.
# For example, the train "1" yields public versions "1.0", "1.1", "1.2" and so on.
# The train "1.0" yields public versions "1.0.0", "1.0.1", "1.0.2" and so on.
#
# The train is extracted from the name of the built git branch: if it ends
# with numbers and dots that look like a version number, it'll be used.
# Examples:
#  Branch name  → Train used → Versions
#  sprint61     → 61         → 61.x
#  test2        → 2          → 2.x   (achtung! you don't want this)
#  test2a       → none       → see below
#  release/v2.3 → 2.3        → 2.3.x
#  develop      → none       → see below
#
# When a train is found, the last published* version is extracted from App Store Connect,
# and the scripts increments it. If no version has been published yet for this train,
# it will start at .0
# Example:
#  Train used   Last published version    This build will be
#   1             (none)                   1.0
#   1             1.0                      1.1
#   1             1.3                      1.4
#   1             1.0.0                    1.0.1 **
#   1             1.4.2                    1.4.3 **
#   1.0           (none)                   1.0.0
#   1.0           1.0                      1.0.1 **
#   1.0           1.0.0                    1.0.1
#   1.0           1.4.2                    1.0.x+1 (depending on last 1.0.x)
#
# * "published" means: a version that is, or has been, on sale or ready for sale
# on the App Store.
# Technically, state ∈ [.developerRemovedFromSale, .pendingAppleRelease,
# .pendingDeveloperRelease, .preorderReadyForSale, .processingForAppStore,
# .readyForSale, .removedFromSale, .replacedWithNewVersion]
#
# ** This is not supposed to happen if you have been using versionWizard since
# the first release ever of your app. Train 1 will only ever product 1.x public
# versions. However, if other versioning systems have been used, you may well
# encounter this situation, and it should work anyway.
#
# If no train is found in the branch name, then the last train published on App Store
# Connect is simply used. In this case, the train will be all components of the
# public version, minus the last one (eg. last published version 3.14.16 yields
# a train 3.14).
# If no version has ever been released, the train falls back to 1 (hence, version
# will be 1.0)
#
# --------------------
#
# The build number is derived from the git commit hash.
# If one build was already done on this hash, then it gets the same build number.
# If no build has ever been done on this hash, it gets the highest build number
# already done, +1.
# (If no build has ever been done at all, first build gets build number 1).
#
# If you're migrating from v1.x of this script, you need to synchronize the last
# build number.
# Simply run this command once:
# curl "https://uad.io/versions.php?app-id=123456&commit=<lastHash>&force=<lastBuildNumber>"
#
# --------------------
#
# Why does it work this way?
#
# This process has several advantages over all previous solutions:
#
# - several targets can be built with the same build/public numbers, if they're configured
#   with the same App ID. This allows a private, test-only app ("MyApp Dev") to be
#   distributed on TestFlight, allowing for more customization and debug flags than
#   the public, AppStore-published app ("MyApp").
#   Once the test-only target has been tested and deemed ready, one can safely compile
#   a production target from the same commit, and get the exact same version numbers.
#   You'd be well advised to use the App ID of the production app, because test-only
#   apps should never be published on the App Store, and I can't guarantee their
#   status on App Store Connect, so the auto-train may not work.
#
# - no "version bump" commit needs to be made, ever. Public versions are derived from
#   the repository branches and App Store Connect, and build numbers are guaranteed to
#   be incremental (and synchronized between multi-target apps).
#
# - it supports multiple versioning schemes (M.m or M.m.p or YYMM.p) just by correctly
#   naming branches.
#
# - it supports multiple releases in parallel, by building several branches at once.
#
# - bonus: project managers can manage versioning themselves just by renaming branches.
#
######################################################################################
#
# CONTINUOUS INTEGRATION
#
# In order to keep the P8 key secret, it must not be included in your source repository.
# Instead, you can either provide it with a local absolute file when you build from
# your computer, and from a secret in Bitrise when you build in CI.
#
# The "Run Script" build phase can look like this:
#
###  if [ -z ${VW_KEY_P8_CONTENTS+x} ]
###  then
###      export VW_KEY_ISSUER="69a6de71-a904-47e3-e053-5b8c7c11a4d1"
###      export VW_KEY_ID="V9962BU5V7"
###      export VW_KEY_P8="/path/to/an/absolute/directory/outside/git/AuthKey_V9962BU5V7.p8"
###  else
###      echo "$VW_KEY_P8_CONTENTS" > /tmp/bitrise_key.p8
###      export VW_KEY_P8="/tmp/bitrise_key.p8"
###  fi
###
###  "${BUILD_DIR%Build/*}/SourcePackages/checkouts/Slab/Helpers/VersionWizard2.sh"
#
# Then, in Bitrise, you declare VW_KEY_ISSUER, VW_KEY_ID and VW_KEY_P8_CONTENTS as Secrets.
# (Put the *contents* of the P8 in the secret, as there's no way to secret-ize whole files).
#
######################################################################################
#
# Version History
#
#   2.0 - September 10, 2021: New automatic train system for public versions
#   1.4 - August 2021: Don't run when compiling for SwiftUI Previews
#   1.3 - May 14, 2021: Add support for App Clips
#   1.2 - March 2021: Integrate into Slab
#
######################################################################################

# Don't run when compiling for Previews. This would mark the current build as "dirty"
# and SwiftUI Previews would fail.
[[ $(echo "$BUILD_ROOT" | grep "Previews" | wc -l) -eq 1 ]] && {
     echo "Bailing out while compiling Previews"
     exit 0
}

# Make preprocessor definitions available to Bash
eval "${GCC_PREPROCESSOR_DEFINITIONS}"

fail() {
    echo "$1"
    [ -z ${VW_CONTINUE_ON_ERROR+x} ] && exit 1 || exit 0
}


##### PRECONDITIONS ###########################################

# Make sure we have needed values defined
[ -z ${VW_APP_ID+x} ] && fail "VW_APP_ID not set"
[ -z ${VW_KEY_ISSUER} ] && fail "VW_KEY_ISSUER not set"
[ -z ${VW_KEY_ID} ] && fail "VW_KEY_ID not set"
[ -z "${VW_KEY_P8}" ] && fail "VW_KEY_P8 not set"

# Make sure jq is installed
which jq >/dev/null || fail "jq is not installed"

# Make sure PlistBuddy is there
[ -f "/usr/libexec/PlistBuddy" ] || fail "PlistBuddy is not installed"

# Find native versionWizard tool
WIZARD="${BUILD_DIR%Build/*}/SourcePackages/checkouts/Slab/Helpers/versionWizard"
[[ -x "$WIZARD" ]] || fail "versionWizard native binary not found."


##### PREPARATION ###########################################3

# Get the hash of HEAD
COMMIT=$(git rev-parse --verify HEAD)

# If we're building from Bitrise, we'll always be on an unnamed HEAD branch.
# → Take branch name from BITRISE_GIT_BRANCH if set
# Otherwise, ask git which branch we're on.
BRANCH="${BITRISE_GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

echo "Building from branch $BRANCH, commit $COMMIT"

# If branch name ends with what looks like a version number, use it as train
if [[ "$BRANCH" =~ [0-9][0-9.]*$ ]]; then
    TRAIN="$(echo "$BRANCH" | grep -o '[0-9][0-9.]*$')"
    TRAINOPT="--train \"$TRAIN\""
    echo "Will use train $TRAIN from git branch name."
else
    TRAINOPT=""
    echo "No suitable git branch name, will use the last public version from Apple."
fi

# Get the public version from Apple and build number from uad.io
# (Full source code for versionWizard available on our bitbucket repository,
# alongside Slab)
JSON=`mktemp`.json || fail "Unable to create temporary file"
"$WIZARD" --issuer=${VW_KEY_ISSUER} --key-id=${VW_KEY_ID} --p8="$VW_KEY_P8" --app-id=${VW_APP_ID} --commit=${COMMIT} ${TRAINOPT} > $JSON || fail "Failed to run versionWizard native script"
PUBLIC="$(jq -r '.public' $JSON)"
BUILD="$(jq -r '.build' $JSON)"
rm $JSON

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
