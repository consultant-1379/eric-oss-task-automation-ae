#!/bin/bash
set -o nounset
set -o errexit

CURRENT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${CURRENT_DIRECTORY}"
ROOT_DIRECTORY="$(cd ../ && pwd)"

ihc_auto="armdocker.rnd.ericsson.se/proj-adp-cicd-drop/bob-adp-release-auto:latest"
docker pull ${ihc_auto}
docker run -v "${ROOT_DIRECTORY}":/"${ROOT_DIRECTORY}" ${ihc_auto} helm package "${ROOT_DIRECTORY}"/charts/eric-oss-task-automation-ae/ --version=1.1.1 --destination "$CURRENT_DIRECTORY"
docker build ../testsuite/helm-chart-validator/ -t testsuite
docker run --rm -v "$CURRENT_DIRECTORY"/eric-oss-task-automation-ae-1.1.1.tgz:/eric-oss-task-automation-ae.tgz testsuite
