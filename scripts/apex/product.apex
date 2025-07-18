// Get the known good machine product via SOQL
List<Product2> machineProductsByName = [
    SELECT
        Id
        ,Name
        ,Description
        ,CreatedById
        ,CreatedDate
        ,CurrencyIsoCode
        ,DisplayUrl
        ,ExternalDataSourceId
        ,ExternalId
        ,Family
        ,IsActive
        ,IsArchived
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,ProductClass
        ,ProductCode
        ,QuantityUnitOfMeasure
        ,StockKeepingUnit
        ,SystemModstamp
        ,TaxPolicyId
        ,Type
    FROM
        Product2
    WHERE
        Name = :TestSettings.KNOWN_GOOD_PRODUCT_NAME_MACHINE
    WITH
        SECURITY_ENFORCED
    LIMIT
        20
];

Assert.isNotNull(machineProductsByName, 'machineProductsByName is null. Create a known good Machine Product in the Commerce app and check the TestSettings class.');
Assert.isFalse(machineProductsByName.isEmpty(),  'machineProductsByName is empty. Create a known good Machine Product in the Commerce app and check the TestSettings class.');
Assert.isTrue(machineProductsByName.size() == 1, 'machineProductsByName does not have a single record.');
System.Debug('Machine Product By Name Result => ' +  machineProductsByName[0].Name + ' with size ' + machineProductsByName.size());

// Get the Bean product via SOQL
List<Product2> beanProductsByName = [
    SELECT
        Id
        ,Name
        ,Description
        ,CreatedById
        ,CreatedDate
        ,CurrencyIsoCode
        ,DisplayUrl
        ,ExternalDataSourceId
        ,ExternalId
        ,Family
        ,IsActive
        ,IsArchived
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,ProductClass
        ,ProductCode
        ,QuantityUnitOfMeasure
        ,StockKeepingUnit
        ,SystemModstamp
        ,TaxPolicyId
        ,Type
    FROM
        Product2
    WHERE
        Name = :TestSettings.KNOWN_GOOD_PRODUCT_NAME_BEAN
    WITH
        SECURITY_ENFORCED
    LIMIT
        20
];

Assert.isNotNull(beanProductsByName, 'beanProductsByName is null. Create a known good Bean Product in the Commerce app and check the TestSettings class.');
Assert.isFalse(beanProductsByName.isEmpty(),  'beanProductsByName is empty. Create a known good Bean Product in the Commerce app and check the TestSettings class.');
Assert.isTrue(beanProductsByName.size() == 1, 'beanProductsByName does not have a single record.');
System.Debug('Bean Product By Name Result => ' +  beanProductsByName[0].Name + ' with size ' + beanProductsByName.size());

// Get the known good Mug Products by Name
List<Product2> mugProductsByName = [
    SELECT
        Id
        ,Name
        ,Description
        ,CreatedById
        ,CreatedDate
        ,CurrencyIsoCode
        ,DisplayUrl
        ,ExternalDataSourceId
        ,ExternalId
        ,Family
        ,IsActive
        ,IsArchived
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,ProductClass
        ,ProductCode
        ,QuantityUnitOfMeasure
        ,StockKeepingUnit
        ,SystemModstamp
        ,TaxPolicyId
        ,Type
    FROM
        Product2
    WHERE
        Name = :TestSettings.KNOWN_GOOD_PRODUCT_NAME_MUG
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(mugProductsByName, 'mugProductsByName is null. Create a known good Mug Product in the Commerce app and check the TestSettings class.');
Assert.isFalse(mugProductsByName.isEmpty(),  'mugProductsByName is empty. Create a known good Mug Product in the Commerce app and check the TestSettings class.');
Assert.isTrue(mugProductsByName.size() == 1, 'mugProductsByName does not have a single record.');
System.Debug('Mug Product By Name Result => ' +  mugProductsByName[0].Name + ' with size ' + mugProductsByName.size());

// Get the known good sample products by ProductCode
List<Product2> sampleProductsByProductCode = [
    SELECT
        Id
        ,Name
        ,Description
        ,CreatedById
        ,CreatedDate
        ,CurrencyIsoCode
        ,DisplayUrl
        ,ExternalDataSourceId
        ,ExternalId
        ,Family
        ,IsActive
        ,IsArchived
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,ProductClass
        ,ProductCode
        ,QuantityUnitOfMeasure
        ,StockKeepingUnit
        ,SystemModstamp
        ,TaxPolicyId
        ,Type
    FROM
        Product2
    WHERE
        ProductCode in :TestSettings.KNOWN_GOOD_PRODUCT_CODES
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(sampleProductsByProductCode, 'sampleProductsByProductCode is null. Import the sample products or set up known good samples and check the TestSettings class.');
Assert.isFalse(sampleProductsByProductCode.isEmpty(),  'sampleProductsByProductCode is empty. Import the sample products or set up known good samples and check the TestSettings class.');
Assert.isTrue(sampleProductsByProductCode.size() == TestSettings.KNOWN_GOOD_PRODUCT_CODES.size(), 'sampleProductsByProductCode input and output sizes differ.');
System.Debug('Sample Product By Product Code Result => ' +  sampleProductsByProductCode[0].Name + ' with size ' + sampleProductsByProductCode.size());

// Get the known good Mug Products by ProductCode
List<Product2> mugExerciseProductsByProductCode = [
    SELECT
        Id
        ,Name
        ,Description
        ,CreatedById
        ,CreatedDate
        ,CurrencyIsoCode
        ,DisplayUrl
        ,ExternalDataSourceId
        ,ExternalId
        ,Family
        ,IsActive
        ,IsArchived
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,ProductClass
        ,ProductCode
        ,QuantityUnitOfMeasure
        ,StockKeepingUnit
        ,SystemModstamp
        ,TaxPolicyId
        ,Type
    FROM
        Product2
    WHERE
        ProductCode in :TestSettings.KNOWN_GOOD_EXERCISE_PRODUCT_CODES_FOR_MUGS
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(mugExerciseProductsByProductCode, 'mugExerciseProductsByProductCode is null. Create a known good Mug Product in the Commerce app and check the TestSettings class.');
Assert.isFalse(mugExerciseProductsByProductCode.isEmpty(),  'mugExerciseProductsByProductCode is empty. Create a known good Mug Product in the Commerce app and check the TestSettings class.');
Assert.isTrue(mugExerciseProductsByProductCode.size() == TestSettings.KNOWN_GOOD_EXERCISE_PRODUCT_CODES_FOR_MUGS.size(), 'mugExerciseProductsByProductCode input and output sizes differ.');
System.Debug('Mug Product By Product Code Result => ' +  mugExerciseProductsByProductCode[0].Name + ' with size ' + mugExerciseProductsByProductCode.size());

// Get the known good bean product via SOQL using ProductCode
List<Product2> beanExerciseProductsByProductCode = [
    SELECT
        Id
        ,Name
        ,Description
        ,CreatedById
        ,CreatedDate
        ,CurrencyIsoCode
        ,DisplayUrl
        ,ExternalDataSourceId
        ,ExternalId
        ,Family
        ,IsActive
        ,IsArchived
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,LastReferencedDate
        ,LastViewedDate
        ,ProductClass
        ,ProductCode
        ,QuantityUnitOfMeasure
        ,StockKeepingUnit
        ,SystemModstamp
        ,TaxPolicyId
        ,Type
    FROM
        Product2
    WHERE
        ProductCode in :TestSettings.KNOWN_GOOD_EXERCISE_PRODUCT_CODES_FOR_BEANS
    WITH
        SECURITY_ENFORCED
    LIMIT
        20
];

Assert.isNotNull(beanExerciseProductsByProductCode, 'beanExerciseProductsByProductCode is null. Create a known good Bean Product in the Commerce app and check the TestSettings class.');
Assert.isFalse(beanExerciseProductsByProductCode.isEmpty(),  'beanExerciseProductsByProductCode is empty. Create a known good Bean Product in the Commerce app and check the TestSettings class.');
Assert.isTrue(beanExerciseProductsByProductCode.size() == TestSettings.KNOWN_GOOD_EXERCISE_PRODUCT_CODES_FOR_BEANS.size(), 'beanExerciseProductsByProductCode input and output sizes differ.');
System.Debug('Bean Product Result => ' +  beanExerciseProductsByProductCode[0].Name + ' with size ' + beanExerciseProductsByProductCode.size());

// Make a REST Call to the Connect API for /commerce/webstores/webstoreId/products

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

// Check WebStore assumptions
Assert.isNotNull(webStores, 'webStores is null. Create a known good Commerce Store in the org and check the TestSettings class.');
Assert.isFalse(webStores.isEmpty(),  'webStores is empty. Create a known good Commerce Store in the org and check the TestSettings class.');
Assert.isTrue(webStores.size() == 1, 'webStores does not have a single record');
System.Debug('WebStore Result => ' +  webStores[0].Name + ' with size ' + webStores.size());

// Get the Effective Account
List<Account> accounts = [
    SELECT
        Id, Name, OwnerId
    FROM
        Account
    WHERE
        Name = :TestSettings.KNOWN_GOOD_ACCOUNT_NAME
    WITH
        SECURITY_ENFORCED
];

// Check assumptions for Effective Account
Assert.isNotNull(accounts, 'accounts is null. Create a known good Account and check the TestSettings class.');
Assert.isFalse(accounts.isEmpty(),  'accounts is empty. Create a known good Account and check the TestSettings class.');
Assert.isTrue(accounts.size() == 1, 'accounts does not have a single record.');
System.Debug('Account Result => ' +  accounts[0].Name + ' with size ' + accounts.size());

// Make the REST call with our WebStore and Effective Account
List<String> productIds = new List<String>();
for(Product2 product : sampleProductsByProductCode) {
    productIds.add(product.Id);
}

String apiVersion = '58.0';
HttpRequest req = new HttpRequest();
String baseUri = URL.getOrgDomainUrl().toExternalForm();
String uri = baseUri + '/services/data/v' + apiVersion + '/commerce/webstores/' +
webStores[0].Id +
'/products?ids=' + String.join(productIds, ',') +
'&effectiveAccountId=' + accounts[0].Id +
'&excludeMedia=true' +
'&excludePrices=true';
System.debug(uri);
req.setEndpoint(uri);
req.setMethod('GET');
req.setHeader('Content-Type', 'application/json');
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
Http http = new Http();
HttpResponse res = http.send(req);

Assert.areEqual(200, res.getStatusCode());
String json = res.getBody();
System.debug('json: \r\n' + json + '\r\n');

ProductsConnectApiRestResponse restResponse = ProductsConnectApiRestResponse.parse(json);
Assert.isNotNull(restResponse, 'null restResponse!');
Assert.isNotNull(restResponse.products, 'null products!');
Assert.isTrue(restResponse.products.size() > 0, 'No products!');