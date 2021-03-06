#!/usr/bin/env bash
#
# devops/core/includes/fixup-source.sh
#
#   Changes to source directories to make everything go better
#

#
# "Declarations" of the variables this script assumes
#
declare=${CIRCLE_ARTIFACTS:=}
declare=${CIRCLE_BUILD_NUM:=}
declare=${CIRCLE_BRANCH:=}
declare=${SHARED_SCRIPTS:=}
declare=${SOURCE_INDEX:=}
declare=${SOURCE_CONTENT:=}
declare=${BUILD_TAG:=}
declare=${ARTIFACTS_FILE:=}

#
# Set artifacts file for this script
#
ARTIFACTS_FILE="${CIRCLE_ARTIFACTS}/fixup-source.log"

#
# Changing directory to test root
#
announce "...Changing to directory ${SOURCE_INDEX}"
cd "${SOURCE_INDEX}"

#
# Stash any local changes, in case there are any, so we can drop them
# (local changes may come from caching)
#
announce "...Stash any cached files that would overwrite potential updates"
STASH_MSG="$(git stash)"
echo "${STASH_MSG}" >> $ARTIFACTS_FILE 2>&1

if [ "No local changes to save" != "${STASH_MSG}" ] ; then
    #
    # Since we do have local changes, drop them
    #
    announce "...Drop stashed cached files"
    git stash drop >> $ARTIFACTS_FILE 2>&1
fi

#
# Discard any new files or directories not in the latest git commit
#
announce "...Discard any new files or directories not in the latest git commit"
git clean -f >> $ARTIFACTS_FILE 2>&1

announce "...Inspecting current branch"
CURRENT_BRANCH="$(git symbolic-ref --short HEAD 2>&1)"

announce "...Current branch is ${CURRENT_BRANCH}"
if [ "${CURRENT_BRANCH}" != "${CIRCLE_BRANCH}" ]; then
    #
    # Checking out the expected branch
    #
    announce "...Checking out branch ${CIRCLE_BRANCH}"
    git checkout "${CIRCLE_BRANCH}" >> $ARTIFACTS_FILE 2>&1
fi

#
# Run a git status for the artifacts file
#
announce "...Run a git status for the artifacts file"
git status >> $ARTIFACTS_FILE 2>&1

#
# Do a git pull to make sure we have the latest, just in case.
#
announce "...Pulling from origin/${CIRCLE_BRANCH} to get the latest before changes"
git pull origin ${CIRCLE_BRANCH} --no-edit >> $ARTIFACTS_FILE 2>&1

#
# Create a directory for uploads so Circle CI
# won't complain about caching the darn thing.
#
announce "...Create directory ${SOURCE_CONTENT}/uploads"
mkdir -p "${SOURCE_CONTENT}/uploads"

#
# Adding build tag
#
announce "...Tagging build with '${BUILD_TAG}'"
git tag -a "${BUILD_TAG}" -m "Build #${CIRCLE_BUILD_NUM}" >> $ARTIFACTS_FILE 2>&1

#
# Pushing build commit and tag
#
# @see https://stackoverflow.com/a/3745250/102699
#
announce "...Pushing tag ${BUILD_TAG}"
git push --tags  >> $ARTIFACTS_FILE 2>&1

announce "Fixup of source complete."