#!/bin/bash

# Export the Products (entity Product2) without filtering them

# the salesforce org username in email format like tzarr@b2b-standalone-spring24.org
sfusername='tzarr@b2b-standalone-spring24.org'
# the output directory
outdir="$HOME/b2b-commerce-gtk-dev-output"

# Local variable to hold the query (could also be passed in)
query="SELECT Id, Name, ProductCode, Family, StockKeepingUnit, Description FROM Product2"

# Tell user what we're doing
echo "Executing query: '$query' against username: '$sfusername' with output directory: '$outdir' and opening in preferred JSON editor..."

# Run our Salesforce tree export command
sf data export tree --query "$query" --target-org "$sfusername" --output-dir "$outdir"

# open the file with preferred app
open "$outdir/Product2.json"

# Tell user it's done
echo "Execution complete for query: '$query' against username: '$sfusername' with output directory: '$outdir' and file opened in preferred JSON editor."