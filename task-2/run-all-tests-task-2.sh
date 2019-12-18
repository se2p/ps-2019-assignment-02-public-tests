#!/bin/bash
# Force run all the tests defined for the javascript implementation


if [ "$#" -ne 3 ]; then
echo "Illegal number of parameters. Provide public-tests home, project home and oracle home"
exit 1
fi

PUBLIC_TESTS_HOME="$(realpath "$1")"
PROJECT_HOME="$(realpath "$2")"
ORACLE_HOME="$(realpath "$3")"

# The following paths are hardcoded because the structure of the repositories is FIXED
TASK_HOME="$(realpath "${PROJECT_HOME}/task-2")"
TEST_TASK_HOME="$(realpath "${PUBLIC_TESTS_HOME}/task-2")"

# List all the test-* folder, for each call the test script
for TEST in $(find "${TEST_TASK_HOME}/tests" -type d -ipath "${TEST_TASK_HOME}/tests/test*" -maxdepth 1); do
    "${TEST_TASK_HOME}/test-task-2.sh" "${TEST}" "${PROJECT_HOME}" "${ORACLE_HOME}"
done
