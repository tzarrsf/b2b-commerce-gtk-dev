<#
    Export OrderSummary records with additional details such as who created it, the role, the profile, the sales store and so forth.
#>
param (
    # the salesforce org username in email format like tzarr@b2b-standalone-spring24.org
    $sfusername = 'tzarr@b2b-standalone-spring24.org',
    # the input file for the query
    $insoql = '..\soql\MultiEntityQuery.soql',
    # the output directory
    $outdir = "$Env:HOMEPATH\b2b-commerce-gtk-dev-output"
)

# Local variable to hold the query from the file read in once we scrub it
$clean = @()
$lines = Get-Content $insoql

# Read in avoiding SOQL formatting errors so our .soql script stays pretty
foreach($line in $lines) {
    # Remove  non-single whitespace chars
    $line = $line -replace "\s{2,}",""

    # Remove comment and blank lines
    if($line.IndexOf('//') -eq -1 -and $line.IndexOf('/*') -eq -1 -and $line.IndexOf('*/') -eq -1 -and $line -ne '') {
        # Add the clean lines to tracking array
        $clean += $line
    }
}

# Assemble into a clean one-liner
$query = $clean -join " "

# Tell user what we're doing
Write-Output "Executing query: '$query' (from file) against username: '$sfusername' with output directory: '$outdir' and opening in Notepad..."

# Run our Salesforce tree export command
sf data export tree --query $query --target-org $sfusername --output-dir $outdir

# Open the file with Notepad
notepad.exe "$outdir\OrderSummary.json"

# Tell user it's done
Write-Output "Execution complete for query: '$query' against username: '$sfusername' with output directory: '$outdir' and opened in Notepad."