# Public tests for the Assignment 2 of PS 2019
Note: This is a "community" effort, so please contribute by proposing new tests for task 1 and task 2.

## Test Definition
Each test comes bundled into a folder. The files inside that folder define the various aspects of the tests. Tests that are meant for task 1 go into the `task-1` folder, tests that are meant for task 2 go into the `task-2` folder.

> Q: Why we have different tests for task-1 and task-2? </br>
> A: Because in one case the program requires user inputs, while in the other your code should play automatically both the "client" and the "server" sides.

The name of the files inside the test folders should be self-explanatory, and you have an example for each task. In case of doubts, open issues, post to the form, write Dr. Alessio Gambi an email.

In the given folder, you'll see a `test-task-1.sh` and `test-task-2.sh`. Those scripts are the ones the automated system will use to execute each and every test on your code when you push something to github (**Not in real time!!**)

> Q: How does this testing work? </br>
> A: The content of the `input` is fed to the program using using cat + pipe, and the resulting output is collected into a file named `output`. This file is compared to `expected.output` to generate a diff. If the diff is not empty, the test fails and the diff is reported to you. A bunch of assertions are then executed on the `output` of your program. Failing assertions generate a message which is included in the final test report that is automatically stored into YOUR repository. Assertions are encapsulated into independent (bash) scripts. The assertions that we listed in class are reported in the repo. Some applies to all games (`game-assertions`), other only to won or lost games, because they check properties that are visible only in one or the other case.

A final note: This system is something I come up with in less than a couple of days, so there are shortcomings (e.g., tons of code duplication for assertions, script, what's not) and possibly bugs. If you discover problems please open issues, submit patches, and pull requests !

## How do I import the public tests in my repo?
The solution suggested by a student in class, which I also suggest, is to use `git submodule` to import the public-test repo into your repo, while keeping the management of the two separated.

To do so you can do:

```
cd <YOUR_REPO>
git submodule add git@github.com:se2p/ps-2019-assignment-02-public-tests.git public-tests
```

This creates a folder called `public-tests` in the root of your project. To pull the changes that will be committed to `public-tests` run the following commands:

```
cd <YOUR_REPO>
git submodule update --remote
```

Since `public-tests` is an actual git repo, if you change any of tracked files there, git will complain that there are uncommitted changes. In that case you need to stash them or get rid of them.

## Test Execution
In order to run a test for your task 1 (assuming you have followed the instructions above) you can do:

```
cd <YOUR_REPO>
./public-tests/task-1/test-task-1.sh \
        ./public-tests/task-1/tests/test01 \
        .
```
This will execute `test01` on your task1 implementation. The script requires **two (2)** parameters: the first is the test to execute (`./public-tests/task-1/tests/test01`), the second is the root of your project (`.`)

> Q: Why do I need to specify `.`?</br>
> A: Because this very same script will be executed by the automatic testing system which has to consider not only your submission but also the one of all the other students.

The script outputs the result of the test on the console, however, you can always find the result of the tests inside their folder by looking at the `test-report` file. This file will contains the test outcome (PASSED/FAILED), and for the FAILED test the list of failed assertions.

For example, to see the result of your previous command you can do:
```
cd <YOUR_REPO>
cat ./public-tests/task-1/tests/test01/test-report
```

In order to run a test for your task 2 (assuming you have followed the instructions above) you can do:

```
cd <YOUR_REPO>
./public-tests/task-2/test-task-2.sh \
        ./public-tests/task-2/tests/test01 \
        . \
        ./oracle
```

This will execute `test01` on your task2 implementation. The script requires **three (3)** parameters: the first is the test to execute (`./public-tests/task-1/tests/test01`), the second is the root of your project (`.`), and the third is the home folder of the oracle.

As before the outcome of the test is printed on the console, and a `test-report` file is generated in the test folder.

> Q: What's the oracle and why I need it?</br>
> A: The test oracle is a Java program that implements MasterMild in whatever way you like and is needed to generate the `expected.output` to check whether your tests pass or fail. You can use as oracle one of the java implementations that you submitted for Assignment 1 **provided they implement the correct specifications !!!** We need a test oracle because in task 2 your program does not accept an user input from the console, instead, a dynamically loaded client will play the game. Look inside `./public-tests/task-2/test-task-2.sh` for a more detailed explanation.
