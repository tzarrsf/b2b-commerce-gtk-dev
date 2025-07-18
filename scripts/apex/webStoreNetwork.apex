// Get the known good Network (Experience Site) via SOQL
List<Network> networks = [
    SELECT
        Id
        ,Name
        ,Description
        ,AllowedExtensions
        ,CaseCommentEmailTemplateId
        ,ChangePasswordEmailTemplateId
        ,ChgEmailVerNewEmailTemplateId
        ,ChgEmailVerOldEmailTemplateId
        ,CreatedById
        ,CreatedDate
        ,DeviceActEmailTemplateId
        ,EmailFooterLogoId
        ,EmailFooterText
        ,EmailSenderAddress
        ,EmailSenderName
        ,FirstActivationDate
        ,ForgotPasswordEmailTemplateId
        ,HeadlessForgotPasswordTemplateId
        ,LastModifiedById
        ,LastModifiedDate
        ,LockoutEmailTemplateId
        ,MaxFileSizeKb
        ,NewSenderAddress
        ,SelfRegMicroBatchSubErrorEmailTemplateId
        ,SelfRegProfileId
        ,Status
        ,SystemModstamp
        ,UrlPathPrefix
        ,VerificationEmailTemplateId
        ,WelcomeEmailTemplateId
    FROM
        Network
    WHERE
        Name = :TestSettings.KNOWN_GOOD_NETWORK_NAME
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(networks, 'networks is null. Create a known good Network (Experience Site) in the org and check the TestSettings class.');
Assert.isFalse(networks.isEmpty(),  'networks is empty. Create a known good Network (Experience Site) in the org and check the TestSettings class.');
Assert.isTrue(networks.size() == 1, 'networks does not have a single record');
System.Debug('Network Result => ' +  networks[0].Name + ' with size ' + networks.size());

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

Assert.isNotNull(webStores, 'webStores is null. Create a known good Webstore by creating your Commerce Store and Experience Site in the org and check the TestSettings class.');
Assert.isFalse(webStores.isEmpty(),  'webStores is empty. Create a known good Webstore by creating your Commerce Store and Experience Site in the org and check the TestSettings class.');
Assert.isTrue(webStores.size() == 1, 'webStores does not have a single record');
System.Debug('WebStore Result => ' +  webStores[0].Name + ' with size ' + webStores.size());

//Get the WebStore Network junction via SOQL
List<WebStoreNetwork> webStoreNetworks = [
    SELECT
        Id
        ,Name
        ,CreatedById
        ,CreatedDate
        ,IsDeleted
        ,LastModifiedById
        ,LastModifiedDate
        ,NetworkId
        ,SystemModstamp
        ,WebStoreId
    FROM
        WebStoreNetwork
    WHERE
        NetworkId = :networks[0].Id
        AND WebStoreId = :webStores[0].Id
    WITH
        SECURITY_ENFORCED
];

Assert.isNotNull(webStoreNetworks, 'webStoreNetworks is null. Create a known good Network and WebStore in the org and check the TestSettings class.');
Assert.isFalse(webStoreNetworks.isEmpty(),  'webStoreNetworks is empty. Create a known good Network and WebStore in the org and check the TestSettings class.');
Assert.isTrue(webStoreNetworks.size() == 1, 'webStoreNetworks does not have a single record');
System.Debug('WebStoreNetwork Result => ' +  webStoreNetworks[0].Name + ' with size ' + webStoreNetworks.size());