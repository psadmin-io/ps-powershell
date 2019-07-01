[CmdletBinding()]
Param(
  [Parameter(Mandatory)][String]$DBNAME
  )

Write-Output ""
Write-Output "----------------------------------"
Write-Output "Database Name: ${DBNAME}"
Write-Output "----------------------------------"
Write-Output ""

sleep 20

Write-Output "Done"
Write-Output "----------------------------------"
Write-Output ""

Exit 0