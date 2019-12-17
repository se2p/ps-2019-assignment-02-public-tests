#!/bin/bash
# Test the javascript implementation which works by getting inputs and generating outputs.
# Tests are composed of inputs, expected outputs, assertions (on the output), secret code. Digits is always 4

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters. Provide test home, project home and test count"
    exit 1
fi

TEST_BASE="$(realpath "$1")"
PROJECT_HOME="$(realpath "$2")"
TEST_COUNT=$(find ${TEST_BASE}/../common_tests/* -maxdepth 0 -type d | wc -l)

# Clean up stale report file.
if [ -e ${TEST_BASE}/test-report ]; then rm ${TEST_BASE}/test-report; fi

for i in $(seq 1 ${TEST_COUNT});
do
    TEST_HOME=${TEST_BASE}/../common_tests/test-$i

    # Ensures that the secret.code file is where it is supposed to be
    cp ${TEST_HOME}/secret.code ${PROJECT_HOME}

    # Move in program folder
    cd ${PROJECT_HOME}

    # Pipe the inputs into the program, collect both output and error
    cat ${TEST_HOME}/input | \
        node master-mild.js --enable-aspects > ${TEST_HOME}/output 2> ${TEST_HOME}/error

    # Clean up the project folder
    rm ${PROJECT_HOME}/secret.code

    # Move in test folder
    cd ${TEST_HOME}

    # Clean up stale report file. This should never happen...
    if [ -e test-report ]; then rm test-report; fi

    # Check common assertions game-assertions
    for A in $(find ${TEST_BASE}/game-assertions/ -type f); do
        # Assumption is that assertion produces error messages in case they fail
        $A 2> >(sed 's/^/    /') | cat >> test-report
    done

    # If the test leads to a WON game, check won game assertions
    if [ "$(cat ${TEST_HOME}/game.result)" == "won" ]; then
        for A in $(find ${TEST_BASE}/won-game-assertions/ -type f); do
            # Assumption is that assertion produces error messages in case they fail
            $A 2> >(sed 's/^/    /') | cat >> test-report
        done
    fi

    # If the test leads to a LOST game, check lost game assertions
    if [ "$(cat ${TEST_HOME}/game.result)" == "lost" ]; then
        for A in $(find ${TEST_BASE}/lost-game-assertions/ -type f); do
            # Assumption is that assertion produces error messages in case they fail
            $A 2> >(sed 's/^/    /') | cat >> test-report
        done
    fi


    TEST_NAME=$(cat ${TEST_HOME}/name)
    TEST_TYPE="Public"
    if [ -e ${TEST_HOME}/private ]; then
        TEST_TYPE="Private"
    fi

    if [[ -s ${TEST_HOME}/test-report ]]; then
        echo "  ${TEST_NAME} FAILED (${TEST_TYPE})" | cat - ${TEST_HOME}/test-report >> ${TEST_BASE}/temp
    else
        echo "  ${TEST_NAME} PASSED (${TEST_TYPE})" | cat - ${TEST_HOME}/test-report >> ${TEST_BASE}/temp
    fi
done

mv ${TEST_BASE}/temp ${TEST_BASE}/test-report
