<#
    Script description.
    Some notes.
#>
param (
    # the salesforce org username in email format like tzarr@b2b-standalone-spring24.org
    $sfusername='tzarr@b2b-standalone-spring24.org',
    # the input file for the query
    $insoql='..\soql\MultiEntityQuery.soql',
    # the output directory
    $outdir="$Env:HOMEPATH\b2b-commerce-gtk-dev-output"
)

# Local variable to hold the query from the file
#$query = Get-Content $insoql
$query="SELECT Id, OrderNumber, TotalAmount, CurrencyIsoCode, Status, PoNumber, Account.Id, Account.Name, CreatedBy.Id, CreatedBy.Username, CreatedBy.Name, CreatedBy.UserRole.Name, CreatedBy.Profile.Name, CreatedBy.Contact.Id, CreatedBy.Contact.Name,SalesStore.Id, SalesStore.Name FROM OrderSummary"

# Tell user what we're doing
Write-Output "Executing query: '$query' (from file) against username: '$sfusername' with output directory: '$outdir' and opening in Notepad..."

# Run our Salesforce tree export command
sf data export tree --query $query --target-org $sfusername --output-dir $outdir

# open the file with Notepad
notepad.exe "$outdir\OrderSummary.json"

# Tell user it's done
Write-Output "Execution complete for query: '$query' against username: '$sfusername' with output directory: '$outdir' and opening in Notepad..."