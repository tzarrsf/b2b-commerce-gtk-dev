// Get the known good WebStore via SQL
String runningAs = UserInfo.getUserName();
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

Assert.isNotNull(webStores, 'webStores is null. Create a known good Web Store (Commerce Store) in the org and check the TestSettings class.');
Assert.isFalse(webStores.isEmpty(),  'webStores is empty. Create a known good Web Store (Commerce Store) in the org and check the TestSettings class.');
Assert.isTrue(webStores.size() == 1, 'webStores does not have a single record');
System.Debug('WebStore Result => ' +  webStores[0].Name + ' with size ' + webStores.size());