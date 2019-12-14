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