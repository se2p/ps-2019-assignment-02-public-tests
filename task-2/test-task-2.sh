#!/bin/bash
# Test the java implementation which works by getting automatically generating input and outputs.
# Tests are composed of assertions (on the output) and secret code. Digits is always 4
# To check the assertions an input file will be derived from the output that your program produces and an expected.output file must be produced by an oracle that implement correctly the system. Most likely this the code you implemented for your previous assignment, or an updated version of that.

#
#
#   The ORACLE MUST BE JAVA AND MUST RUN WITH THE FOLLOWING COMMAND:
#
#   cat ${TEST_HOME}/input | \
#        java MasterMild > ${TEST_HOME}/expected.output 2> ${TEST_HOME}/oracle.error
#
#

function skip_test_and_exit_with_error(){
    # If run.sh is not present the test cannot run
    cd ${TEST_HOME}

    # Clean up stale report file.
    if [ -e test-report ]; then rm test-report; fi

    # Write in the test-report
    echo "    Test did not run, I cannot find run.sh" >> test-report

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

    # Exit with error - TODO Will this exit or return ?
    exit 1
}

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters. Provide test home, project home and oracle home"
    exit 1
fi

TEST_HOME="$(realpath "$1")"
PROJECT_HOME="$(realpath "$2")"
ORACLE_HOME="$(realpath "$3")"

# The following paths are hardcoded because the structure of the repositories is FIXED
TASK_HOME="$(realpath "${PROJECT_HOME}/task-2")"
ASSERTIONS_HOME="$(realpath "${TEST_HOME}/../../assertions")"

# SWAP the secret.code if there's one already (manual test)
if [ -e ${TASK_HOME}/secret.code ]; then
    mv ${TASK_HOME}/secret.code ${TASK_HOME}/secret.code.orig
fi

# Ensures that the secret.code defined inside the test is where it is supposed to be
cp ${TEST_HOME}/secret.code ${TASK_HOME}

# Move in program folder
cd ${TASK_HOME}

# We assume that the program can be started with a run.sh script which provides the right parameters, e.g., valid URL for plugin and such. If the run.sh file is not there the test automatically fails
if [ -e "${TEST_HOME}/default" ]; then
    # This should trigger the DEFAULT CLIENT. Untested.
    java -cp $(echo lib/*.jar | tr ' ' ':') > ${TEST_HOME}/output 2> ${TEST_HOME}/error
elif [ -e ./run.sh ]; then
    ./run.sh > ${TEST_HOME}/output 2> ${TEST_HOME}/error
else
    skip_test_and_exit_with_error
fi

### At this point the test ran

# Not really needed
cd -

# Clean up the project folder
rm ${TASK_HOME}/secret.code

# Restore the files that were there before execution
if [ -e ${TASK_HOME}/secret.code.orig ]; then
    mv ${TASK_HOME}/secret.code.orig ${TASK_HOME}/secret.code
fi

# Produce the input file for the oracle by extracting input from outputs
cat ${TEST_HOME}/output | grep -A 1 -i ">> Guess" | grep -v ">> Guess" | grep -v "\-\-" > ${TEST_HOME}/input

###########

set -x

# Move in oracle folder
cd ${ORACLE_HOME}

# Ensures that the secret.code file is where it is supposed to be also for the oracle. This time we assume there's no manual testing going on so we overwrite and delete everything each time
cp ${TEST_HOME}/secret.code ${ORACLE_HOME}

# Run the oracle with the generated input to obtain the expected.output
cat ${TEST_HOME}/input | \
    java MasterMild > ${TEST_HOME}/expected.output 2> ${TEST_HOME}/expected.error

# Was this a won match or a lost match? Compare the input with the value inside "secret" and then decide
# ALTERNATIVE: Check using the oracle's output (expected output). SAFE: do both
if [ $(grep -c $(cat ${TEST_HOME}/secret) ${TEST_HOME}/input) -eq 0 ]; then
    # The secret code never happeared in the input
    echo "lost" > ${TEST_HOME}/game.result
else
    # The secret code happeared at least once in the output
    echo "won" > ${TEST_HOME}/game.result
fi

# Clean up oracle folder
rm ${ORACLE_HOME}/secret.code

set +x

#######

# Move in test folder
cd ${TEST_HOME}

# Clean up stale report file. This should never happen...
if [ -e test-report ]; then rm test-report; fi

# Check common assertions game-assertions
for A in $(find  ${ASSERTIONS_HOME}/game-assertions/ -type f); do
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
    rm ${TEST_HOME}/input           # Generated
    rm ${TEST_HOME}/output          # Generated
    rm ${TEST_HOME}/output.diff     # Generated
    rm ${TEST_HOME}/expected.output # Generated
    rm ${TEST_HOME}/error           # Generated
    rm ${TEST_HOME}/expected.error  # Generated
    rm ${TEST_HOME}/game.result     # Generated
fi