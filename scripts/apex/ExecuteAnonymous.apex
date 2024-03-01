/*
Mimics the Developer Console Execute Anonymous functionality
Option A: Selection
1. Paste your code in and highlight it
2. Ctrl + Shift + P to activate Command Palette
3. Choose "Execute Anonymous Apex with Currently Selected Text"
Option B: All contents
1. Ctrl + Shift + P to activate Command Palette
2. Choose "Execute Anonymous Apex with Editor Contents"
*/

// Simple example
List<Account> accountsTest = [select Id, Name from Account limit 100];
System.debug(accountsTest.size() + ' accounts found.');