#!/bin/bash
# Test the javascript implementation which works by getting inputs and generating outputs.
# Tests are composed of inputs, expected outputs, assertions (on the output), secret code. Digits is always 4

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. Provide test home and project home"
    exit 1
fi

TEST_HOME="$(realpath "$1")"
PROJECT_HOME="$(realpath "$2")"

# The following paths are hardcoded because the structure of the repositories is FIXED
TASK_HOME="$(realpath "${PROJECT_HOME}/task-1")"
ASSERTIONS_HOME="$(realpath "${TEST_HOME}/../../assertions")"

# SWAP the secret.code if there's one already (manual test)
if [ -e ${TASK_HOME}/secret.code ]; then
    mv ${TASK_HOME}/secret.code ${TASK_HOME}/secret.code.orig
fi

# Ensures that the secret.code defined inside the test is where it is supposed to be
cp ${TEST_HOME}/secret.code ${TASK_HOME}

# Move in program folder
cd ${TASK_HOME}

# Pipe the inputs into the program, collect both output and error
cat ${TEST_HOME}/input | \
        node master-mild.js --enable-aspects > ${TEST_HOME}/output 2> ${TEST_HOME}/error

# Not really needed
cd -

# Clean up the project folder
rm ${TASK_HOME}/secret.code

# Restore the files that were there before execution
if [ -e ${TASK_HOME}/secret.code.orig ]; then
    mv ${TASK_HOME}/secret.code.orig ${TASK_HOME}/secret.code
fi

###########

# Move in test folder
cd ${TEST_HOME}

# Clean up stale report file.
if [ -e test-report ]; then rm test-report; fi

# Check common assertions game-assertions
for A in $(find ${ASSERTIONS_HOME}/game-assertions/ -type f); do
    # Assumption is that assertion produces error messages in case they fail
    $A 2> >(sed 's/^/    /') | cat >> test-report
done

# If the test leads to a WON game, check won game assertions
if [ "$(cat ${TEST_HOME}/game.result)" == "won" ]; then
    for A in $(find ${ASSERTIONS_HOME}/won-game-assertions/ -type f); do
        # Assumption is that assertion produces error messages in case they fail
        $A 2> >(sed 's/^/    /') | cat >> test-report
    done
fi

# If the test leads to a LOST game, check lost game assertions
if [ "$(cat ${TEST_HOME}/game.result)" == "lost" ]; then
    for A in $(find ${ASSERTIONS_HOME}/lost-game-assertions/ -type f); do
        # Assumption is that assertion produces error messages in case they fail
        $A 2> >(sed 's/^/    /') | cat >> test-report
    done
fi


TEST_NAME=$(cat ${TEST_HOME}/name)
TEST_TYPE="Public"
if [ -e ${TEST_HOME}/private ]; then
    TEST_TYPE="Private"
fi

if [[ -s test-report ]]; then
    TEST_STATUS="FAILED"
else
    TEST_STATUS="PASSED"
fi

echo "  ${TEST_NAME} ${TEST_STATUS} (${TEST_TYPE})" | cat - test-report > temp && mv temp test-report

cd -

# TODO Clean up should be ensured... RAII?! TRAP the errors?
# Clean up test execution files if test passed
if [ "${TEST_STATUS}" == "PASSED" ]; then
    rm ${TEST_HOME}/output      # Generated
    rm ${TEST_HOME}/output.diff # Generated
    rm ${TEST_HOME}/error       # Generated
fi