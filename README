# ps-powershell

[This wrapper script is used to call Powershell scripts from the Process Monitor](). PeopleSoft's batch scheduling system support various tools but it doesn't supporting running shell scripts. David Kurtz posted a solution on running *nix shell scripts and this project is entirely based on his work.

* http://www.go-faster.co.uk/docs/process_scheduler_shell_scripts.pdf
* http://blog.psftdba.com/2007/09/running-unix-commands-and-scripts-from.html
* http://blog.psftdba.com/2017/02/process-scheduler-shell-script.html

## Requirements

* This wrapper script was tested with Powershell 5 and uses the `#Requires -Version 5` command.
* The `$env:ORACLE_HOME` environment variable must be set and pointing to your Oracle Client home.

## Debugging

There is an optional debug mode that you can enable when using the wrapper script. To enable debug mode, set the environment variable $env:DEBUG="true" for the powershell session (if testing via the command line), or at the machine level to enable when running from the process scheduler.
