#!/bin/bash
# Force run all the tests defined for the javascript implementation


if [ "$#" -ne 2 ]; then
echo "Illegal number of parameters. Provide public-tests home and project home"
exit 1
fi

PUBLIC_TESTS_HOME="$(realpath "$1")"
PROJECT_HOME="$(realpath "$2")"

# The following paths are hardcoded because the structure of the repositories is FIXED
TASK_HOME="$(realpath "${PROJECT_HOME}/task-1")"
TEST_TASK_HOME="$(realpath "${PUBLIC_TESTS_HOME}/task-1")"

# List all the test-* folder, for each call the test script
for TEST in $(find "${TEST_TASK_HOME}/tests" -type d -ipath "${TEST_TASK_HOME}/tests/test*" -maxdepth 1); do
    if [ -e "${TEST}/test-report" -a $(grep -c "FAILED" "${TEST}/test-report") -gt 0 ]; then
        "${TEST_TASK_HOME}/test-task-1.sh" "${TEST}" "${PROJECT_HOME}"
    fi
done
