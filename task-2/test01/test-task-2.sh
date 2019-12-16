#!/bin/bash

function add_test_header(){
    TEST_NAME=$(cat ${TEST_HOME}/name)
    TEST_TYPE="Public"
    if [ -e ${TEST_HOME}/private ]; then
        TEST_TYPE="Private"
    fi

    if [[ -s test-report ]]; then
        echo "  ${TEST_NAME} FAILED (${TEST_TYPE})" | cat - test-report > temp && mv temp test-report
    else
        echo "  ${TEST_NAME} PASSED (${TEST_TYPE})" | cat - test-report > temp && mv temp test-report
    fi
}


if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters. Provide test home and project home"
    exit 1
fi

TEST_HOME="$(realpath "$1")"
PROJECT_HOME="$(realpath "$2")"
#
# The oracle is a program, most likely your previous implementation of MasterMild if that had no bugs, which is used
# to generate the expecte.output and the input files necessary for checking the assertions
ORACLE_HOME="$(realpath "$3")"

# Move in program folder
cd ${PROJECT_HOME}

# Ensures that the secret.code file is where it is supposed to be
cp ${TEST_HOME}/secret.code ${PROJECT_HOME}

# Pipe the inputs into the program, collect both output and error
# We assume that the program can be started with a run.sh script which provides the right parameters, e.g., valid URL for plugin

# Since there are parameters passing we cannot have a default command here, we need to rely on students writing the run.sh
# Additionally, there's no input nor expected output at this point we need to find another way
if [ -e "${TEST_HOME}/default" ]; then
        java -cp $(echo lib/*.jar | tr ' ' ':') > ${TEST_HOME}/output 2> ${TEST_HOME}/error
elif [ -e ./run.sh ]; then
        ./run.sh > ${TEST_HOME}/output 2> ${TEST_HOME}/error
else
    # Here we have the situation that run.sh is not present so we could not run any test
    cd ${TEST_HOME}

    # Clean up stale report file.
    if [ -e test-report ]; then rm test-report; fi

    # Write in the test-report
    echo "    Test did not run, I cannot find run.sh" >> test-report

    add_test_header
    # Exit with error
    exit 1
fi

# Extract inputs from outputs
cat ${TEST_HOME}/output | grep -A 1 -i ">> Guess" | grep -v ">> Guess" | grep -v "\-\-" > ${TEST_HOME}/inputs

rm ${PROJECT_HOME}/secret.code

# Move in oracle folder
cd ${ORACLE_HOME}

# Ensures that the secret.code file is where it is supposed to be also for the oracle
cp ${TEST_HOME}/secret.code ${ORACLE_HOME}

# Run the oracle with the generated input to obtain the expected.output
cat ${TEST_HOME}/inputs | \
    java MasterMild > ${TEST_HOME}/expected.output 2> ${TEST_HOME}/oracle.error

# Was this a won match or a lost match? Compare the inputs with the value inside "secret" and the decide
# ALTERNATIVE: Check using the oracle's output (expected output). SAFE: do both
if [ $(grep -c $(cat ${TEST_HOME}/secret) ${TEST_HOME}/inputs) -eq 0 ]; then
    # The secret code never happeared in the input
    echo "lost" > ${TEST_HOME}/game.result
else
    # The secret code happeared at least once in the output
    echo "won" > ${TEST_HOME}/game.result
fi

# Clean up oracle folder
rm ${ORACLE_HOME}/secret.code

# Move in test folder
cd ${TEST_HOME}

# Clean up stale report file. This should never happen...
if [ -e test-report ]; then rm test-report; fi

# Check common assertions game-assertions
for A in $(find ${TEST_HOME}/game-assertions/ -type f); do
    # Assumption is that assertion produces error messages in case they fail
    $A 2> >(sed 's/^/    /') | cat >> test-report
done

# If the test leads to a WON game, check won game assertions
if [ "$(cat ${TEST_HOME}/game.result)" == "won" ]; then
    for A in $(find ${TEST_HOME}/won-game-assertions/ -type f); do
        # Assumption is that assertion produces error messages in case they fail
        $A 2> >(sed 's/^/    /') | cat >> test-report
    done
fi

# If the test leads to a LOST game, check lost game assertions
if [ "$(cat ${TEST_HOME}/game.result)" == "lost" ]; then
    for A in $(find ${TEST_HOME}/lost-game-assertions/ -type f); do
        # Assumption is that assertion produces error messages in case they fail
        $A 2> >(sed 's/^/    /') | cat >> test-report
    done
fi

add_test_header
