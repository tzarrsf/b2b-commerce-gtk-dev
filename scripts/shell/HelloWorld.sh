#!/bin/bash

# Say hello injecting the user's input as a name

name=${1:-"You didn't supply a name"}
echo "Hello, $name"