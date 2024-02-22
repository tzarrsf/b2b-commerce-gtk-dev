<#
    Say hello injecting the user's input as a name
#>

Param ($name='Error: You didn''t supply a name')
Write-Output "Hello, $name"