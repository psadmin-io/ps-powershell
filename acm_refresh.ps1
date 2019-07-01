#Requires -Version 5

<#PSScriptInfo
    .VERSION 1.0
    .AUTHOR psadmin.io
    .SYNOPSIS
        Powershell script to call the DBNAME_REFERSH ACM template
    .DESCRIPTION
        This sample script will call the ACM template to begin refresh processing
        for a PeopleSoft database. The script assumes your ACM template is
        named "<DBNAME>_REFRESH".
    .PARAMETER DBNAME
        The database name
    .EXAMPLE
        acm_refresh.ps1 -DBNAME <dbname>
#>

#-----------------------------------------------------------[Parameters]----------------------------------------------------------

[CmdletBinding()]
Param(
  [Parameter(Mandatory)][String]$DBNAME
)

. c:\psft\scripts\${DBNAME}-env.ps1
. $env:PS_HOME\utility\psrunACM.bat psdevprcs ORACLE ${DBNAME} ACMBATCH "password" ${DBNAME}_REFRESH EXEC