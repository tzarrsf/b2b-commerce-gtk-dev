#!/bin/bash

# Delete the Products (entity Product2) individually in a loop based on product name

# the salesforce org username in email format like tzarr@b2b-standalone-spring24.org
sfusername='tzarr@b2b-standalone-spring24.org'
# the comma delimited list of Product Names set to a default
productnames="Black Cherry Syrup,Peach Syrup,Salted Caramel Syrup,Super Vanilla Syrup"

IFS=',' read -ra names <<< "$productnames"
nameslength=${#names[@]}

echo "Looping the $nameslength product names supplied..."

for name in "${names[@]}"
do
    # Local variable to hold the filter
    filter="Name='$name'"

    # Tell user what we're doing
    echo "Executing data delete record for supplied name: '$name' and filter: '$filter' against username: '$sfusername'..."

    # Run our Salesforce delete record command
    sf data delete record --sobject Product2 --where "$filter"

    # Tell user it's done
    echo "Data delete record execution complete for supplied name: '$name' and filter '$filter' against username: '$sfusername'."
done

echo "Looping the $nameslength product names complete."