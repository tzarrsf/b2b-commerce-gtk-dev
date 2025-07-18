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
System.Debug('Accounts Result => ' +  accounts[0].Name + ' with size ' + accounts.size());

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
System.Debug('Contacts Result => ' +  contacts[0].Name + ' with size ' + contacts.size());

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
System.Debug('UserEntities Result => ' +  userEntities[0].Name + ' with size ' + userEntities.size());

List<WebCart> webCarts = [
    SELECT
        Id,
        Name,
        AccountId,
        IsSecondary,
        CreatedById,
        CreatedDate,
        CurrencyIsoCode
    FROM WebCart
    WHERE
        AccountId = :accounts[0].Id
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(webCarts, 'webCarts is null. Create a known good Cart (WebCart) in the org and check the TestSettings class.');
Assert.isFalse(webCarts.isEmpty(),  'webCarts is empty. Create a known good Cart (WebCart) in the org and check the TestSettings class.');
Assert.isTrue(webCarts.size() > 0, 'webCarts does not have any records');
System.Debug('WebCarts Result => ' +  webCarts[0].Name + ' with size ' + webCarts.size());

List<WebCart> webCartsByUser = [
    SELECT
        Id,
        Name,
        AccountId,
        IsSecondary,
        CreatedById,
        CreatedDate,
        CurrencyIsoCode
    FROM WebCart
    WHERE CreatedById = :userEntities[0].Id
];

Assert.isNotNull(webCartsByUser, 'webCartsByUser is null. Create a known good Cart (WebCart) in the org and check the TestSettings class.');
Assert.isFalse(webCartsByUser.isEmpty(),  'webCartsByUser is empty. Create a known good Cart (WebCart) in the org and check the TestSettings class.');
Assert.isTrue(webCarts.size() > 0, 'webCartsByUser does not have any records');
System.Debug('WebCarts By Buyer Result => ' +  webCartsByUser[0].Name + ' with size ' + webCartsByUser.size());