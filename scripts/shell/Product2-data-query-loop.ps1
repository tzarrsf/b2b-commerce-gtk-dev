<#
    Query the Products (entity Product2) individually in a loop based on product name
#>
param (
    # the salesforce org username in email format like tzarr@b2b-standalone-spring24.org
    $sfusername='tzarr@b2b-standalone-spring24.org',
    # the comma delimited list of Product Names set to a default
    $productnames="Black Cherry Syrup,Peach Syrup,Salted Caramel Syrup,Super Vanilla Syrup"
)

$names = $productnames -split ","
$nameslength = $names.length

Write-Output "Looping the $nameslength product names supplied..."

foreach($name in $names) {

    # Local variable to hold the query
    $query = "SELECT Id, Name FROM Product2 where Name = '$name'"

    # Tell user what we're doing
    Write-Output "Executing data query for supplied name '$name' and query: '$query' against username: '$sfusername'..."

    # Run our Salesforce query command
    sf data query --query $query

    # Tell user it's done
    Write-Output "Data query execution complete for supplied name: '$name' and query: '$query' against username: '$sfusername'."
}

Write-Output "Looping the $nameslength product names complete."