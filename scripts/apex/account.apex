
// Get the known good Account by Name via SOQL
List<Account> accounts = [
    SELECT
        Id, Name, OwnerId
    FROM
        Account
    WHERE
        Name = :TestSettings.KNOWN_GOOD_ACCOUNT_NAME
];

Assert.isNotNull(accounts, 'accounts is null. Create a known good Account and check the TestSettings class.');
Assert.isFalse(accounts.isEmpty(),  'accounts is empty. Create a known good Account and check the TestSettings class.');
Assert.isTrue(accounts.size() == 1, 'accounts does not have a single record.');
System.Debug('Account Result => ' +  accounts[0].Name + ' with size ' + accounts.size());

// Get the known good Contact by First and Last Name tied to the Account via SOQL
List<Contact> contacts = [
    SELECT
        Id, Name, AccountId, FirstName, LastName, OwnerId
    FROM
        Contact
    WHERE
        AccountId = :accounts[0].Id
        and FirstName = :TestSettings.KNOWN_GOOD_BUYER_CONTACT_FIRST_NAME
        and LastName = :TestSettings.KNOWN_GOOD_BUYER_CONTACT_LAST_NAME
];

Assert.isNotNull(contacts, 'contacts is null. Create a Contact under your known good Account and check the TestSettings class.');
Assert.isFalse(contacts.isEmpty(),  'contacts is empty. Create a Contact under your known good Account and check the TestSettings class.');
Assert.isTrue(contacts.size() == 1, 'contacts does not have a single record.');
System.Debug('Contact Result => ' +  contacts[0].Name + ' with size ' + contacts.size());

// Get the known good User tied to the Contact and Account via SOQL
List<User> userEntities = [
    SELECT
        Id,
        Name
    FROM
        User
    WHERE
        AccountId = :contacts[0].Accountid
        and FirstName = :contacts[0].FirstName
        and LastName = :contacts[0].LastName
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(userEntities, 'userEntities is null. Make sure your Contact under your known good Account has a User associated to it.');
Assert.isFalse(userEntities.isEmpty(),  'userEntities is empty. Make sure your Contact under your known good Account has a User associated to it.');
Assert.isTrue(userEntities.size() == 1, 'userEntities does not have a single record');
System.Debug('User Result => ' +  userEntities[0].Name + ' with size ' + userEntities.size());

//TODO: Check that the User has the Buyer Perm at minimum
