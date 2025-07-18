// Get the known good WebStore via SQL
List<WebStore> webStores = [
    SELECT
        Id
        ,Name
        ,Description
        ,CheckoutTimeToLive
        ,CheckoutValidAfterDate
        ,Country
        ,CreatedById
        ,CreatedDate
        ,CurrencyIsoCode
        ,DefaultLanguage
        ,DefaultTaxLocaleType
        ,DefaultTaxPolicyId
        ,ExternalReference
        ,GuestBuyerProfileId
        ,GuestCartTimeToLive
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,LocationId
        ,MaxValuesPerFacet
        ,OrderActivationStatus
        ,OrderLifeCycleType
        ,OwnerId
        ,PaginationSize
        ,PricingStrategy
        ,ProductGrouping
        ,SortByPricebookId
        ,StrikethroughPricebookId
        ,SupportedCurrencies
        ,SupportedLanguages
        ,SystemModstamp
        ,Type
    FROM
        WebStore
    WHERE
        Name = :TestSettings.KNOWN_GOOD_WEB_STORE_NAME
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(webStores, 'webStores is null. Create a known good Commerce Store in the org and check the TestSettings class.');
Assert.isFalse(webStores.isEmpty(),  'webStores is empty. Create a known good Commerce Store in the org and check the TestSettings class.');
Assert.isTrue(webStores.size() == 1, 'webStores does not have a single record');
System.Debug('WebStore Result => ' +  webStores[0].Name + ' with size ' + webStores.size());// Get the known good WebStore via SQL

// Get the WebStorePricebook via SOQL
List<WebStorePricebook> webStorePriceBooks = [
    SELECT
        Id
        ,Name
        ,CreatedById
        ,CreatedDate
        ,IsActive
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,Pricebook2Id
        ,SystemModstamp
        ,WebStoreId
    FROM
        WebStorePricebook
    WHERE
        WebStoreId = :webStores[0].Id
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(webStorePriceBooks, 'webStorePriceBooks is null. Create a known good Commerce Store in the org with pricing and check the TestSettings class.');
Assert.isFalse(webStorePriceBooks.isEmpty(),  'webStorePriceBooks is empty. Create a known good Commerce Store in the org with pricing and check the TestSettings class.');
Assert.isTrue(webStorePriceBooks.size() == 1, 'webStorePriceBooks does not have a single record');
System.Debug('WebStorePricebook Result => ' +  webStorePriceBooks[0].Name + ' with size ' + webStorePriceBooks.size());