#!/bin/bash

# Export OrderSummary records with additional details such as who created it, the role, the profile, the sales store and so forth.

# Define input parameters
sfusername='tzarr@b2b-standalone-spring24.org'
insoql='../soql/MultiEntityQuery.soql'
outdir="$HOME/b2b-commerce-gtk-dev-output"

# Local variable to hold the query from the file read in raw once we scrub it
clean=()
while IFS= read -r line; do
    # Remove non-single whitespace chars
    line=$(echo "$line" | sed 's/\s\{2,\}//g')

    # Remove comment and blank lines
    if [[ $line != *'//'* && $line != *'/*'* && $line != *'*/'* && ! -z $line ]]; then
        # Add the clean lines to tracking array
        clean+=("$line")
    fi
done < "$insoql"

# Assemble into a clean one-liner
query=$(IFS=' '; echo "${clean[*]}")

# Tell user what we're doing
echo "Executing query: '$query' (from file) against username: '$sfusername' with output directory: '$outdir' and opening in default text file editor..."

# Run our Salesforce tree export command
sf data export tree --query "$query" --target-org "$sfusername" --output-dir "$outdir"

# Open the file with default text file editor
open "$outdir/OrderSummary.json"  # Assuming xdg-open is available to open the file

# Tell user it's done
echo "Execution complete for query: '$query' against username: '$sfusername' with output directory: '$outdir' and opened in default text file editor."