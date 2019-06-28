#Requires -Version 5

<#PSScriptInfo
    .VERSION 1.0
    .AUTHOR psadmin.io
    .SYNOPSIS
        Powershell wrapper for Process Monitor
    .DESCRIPTION
        This wrapper script is used to call Powershell scripts from the Process Monitor. 
        https://github.com/psadmin-io/ps-powershell
        To enable DEBUG mode, set the environment variable $env:DEBUG="true"
        The $env:ORACLE_HOME environment variable must be set and pointing to your Oracle Client home.

        This script is heavily based on David Kurtz's psft.sh script. 
        http://www.go-faster.co.uk/docs/process_scheduler_shell_scripts.pdf
    .PARAMETER DBNAME
        The database name
    .PARAMETER ACCESSID
        Access ID for the database
    .PARAMETER ACCESSPSWD
        Access Password for the database
    .PARAMETER PRCSINSTANCE
        The process instance for the process request
    .PARAMETER COMMAND
        The command to run from the wrapper script
    .EXAMPLE
        psft.ps1 -DBNAME <dbname> -ACCESSID <accessid> -ACCESSPSWD <accesspswd> -PRCSINSTANCE <prcsinstance> -COMMAND "<command>"
#>

#-----------------------------------------------------------[Parameters]----------------------------------------------------------

[CmdletBinding()]
Param(
  [Parameter(Mandatory)][String]$DBNAME,
  [Parameter(Mandatory)][String]$ACCESSID,
  [Parameter(Mandatory)][String]$ACCESSPSWD,
  [Parameter(Mandatory)][String]$PRCSINSTANCE,
  [Parameter(Mandatory)][String]$COMMAND
)

#---------------------------------------------------------[Variables]--------------------------------------------------------

$PRCSRTNCD    = "0"
$ORACLE_HOME  = $env:ORACLE_HOME
$CONNECT      = "${ACCESSID}/${ACCESSPSWD}@${DBNAME}"
$DEBUG        = $env:DEBUG

#---------------------------------------------------------[Initialization]--------------------------------------------------------

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

#------------------------------------------------------------[Functions]----------------------------------------------------------

function write-debug([String]$message) {
  Write-Host "DEBUG: ${message}" -ForegroundColor Green
}

function write-info([String]$message) {
  Write-Host "INFO: ${message}" -ForegroundColor White
}

function write-error([String]$message) {
  Write-Host "ERROR: ${message}" -ForegroundColor Red
}

function prcsapi([String]$prcsstatus) {
  
  switch ($prcsstatus) {
    "processing"  { $statusnum = "7"; $timestampcol = "begindttm" }
    "success"     { $statusnum = "9"; $timestampcol = "enddttm" }
    "failed"      { $statusnum = "3"; $timestampcol = "enddttm" }
    Default       { $statusnum = "0" }
  }

  $PRCSSQL = @"
set termout off echo off feedback off verify off
connect ${CONNECT}
UPDATE psprcsque
SET    runstatus = ${statusnum}
,      sessionidnum = $pid 
,      lastupddttm = SYSTIMESTAMP
WHERE  prcsinstance = ${PRCSINSTANCE}
;
UPDATE psprcsrqst 
SET    runstatus = ${statusnum}
,      prcsrtncd = ${PRCSRTNCD}
,      continuejob = DECODE(${statusnum},2,1,7,1,9,1,0) 
,      ${timestampcol} = SYSTIMESTAMP
,      lastupddttm = SYSTIMESTAMP
WHERE  prcsinstance = ${PRCSINSTANCE}
;
COMMIT;
exit
"@

  if ($DEBUG -eq "true") {
    write-debug "Params: ${DBNAME} ${ACCESSID} ***** ${PRCSINSTANCE} ${prcsstatus}"  
    write-debug "Status Number: ${statusnum}"
    write-debug "SQL to Run: ${PRCSSQL}"
  }

  $PRCSSQL | . $ORACLE_HOME\bin\sqlplus -S /nolog

}

function execute_command() {
  invoke-expression $COMMAND
  $PRCSRTNCD = $LASTEXITCODE

  if (!($PRCSRTNCD -eq 0)) {
    write-error "Script exited with error code: ${PRCSRTNCD}"
  }
}

#------------------------------------------------------------[Execution]----------------------------------------------------------

. prcsapi "processing"
. execute_command

switch ($PRCSRTNCD) {
  "0" { 
    . prcsapi "success"
    Exit 0 
    }
  "1" { 
    . prcsapi "failed"
    Exit 1
    }
  Default { 
    write-error "Unknown error occured with script"
    . prcsapi "failed"
    Exit 1
    }
}
