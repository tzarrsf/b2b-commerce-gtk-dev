/**
 * @description       : This script is a totally linear approach used to interrogate the Enhanced CMS objects at both the SOQL and API levels in order to
 *                      build the ScriptedImportLevel4 and ScriptedImportLevel5 classes current with the Spring '24 release. This script is part of the
 *                      Salesforce Partner Learning Camp course "B2B Commerce: Developer Essentials" activity "Scripted Import." You can run this in an
 *                      Execute Anonymous context after setting the CONSTANTS.
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/

/**
 * Begin the CONSTANTS for the script run...
 * TODO: Add static final to all of these once put into class
 */

/**
 * STORE_NAME matches on these fields for reference: Site.MasterLabel, Network.Name, WebStore.Name, SalesStore.Name
 * but it's always best to verify anything like that through a relationship.
 */
String STORE_NAME = 'Capricorn B2B LWR Store';

/**
 * On occasion we may need to match on a field containing the name of the Store. This has inherent risks which we'll
 * try to eliminate as the script is built out an matures
 */
String STORE_NAME_WILDCARD = String.format('%{0}%',new Object[]{STORE_NAME});

/**
 * We'll be using English for the United States in this example. Most signatured will document this parameter as:
 * Language locale for the managed content, for example, en_US. If the requested translation isn’t available, the
 * language defaults to the channel or site’s default language. If the channel or site’s default language isn’t
 * available, the language defaults to the primary language of the content space. But you know that you should test
 * that statement.
 */
String LANGUAGE_CODE = 'en_US';

/** Ocassionally we may need to URL Encode things which requires this. Calling an API endpoint where there isn't a
 * ConnectAPI available (or I couldn't find one) comes to mind.
 */
String ENCODING_SCHEME = 'UTF-8';

/**
 * This example is only working with images so this is the content type for that
 */
String MANAGED_CONTENT_TYPE_IMAGE = 'cms_image';

/**
 * Be careful with this setting. Using 1 instead of 0 with some calls may result in exceptions you'r enot anticipating
 */
Integer PAGE_PARAM_ZERO = 0;

/**
 * Typicall for paginated calls, 250 will be the max.
 */
Integer PAGE_SIZE_MAX = 250;

/**
 * Sanity check CONSTANTS
 * TODO: Add static final to these
 * The object graph behind the ConnectApi.ManagedContent and ConnectApi.ManagedContentDelivery classes is a bit complex.
 * Setting these to hard-coded values to match your expectations will help ensure that what happens in the runtime
 * adds up and doesn't do something totally off course. The naming convention is to prefix them with with ORIGINAL_ and
 * have a corresponding one for every value that's looked up.
 */

/**
 * SELECT Id, Name FROM WebStore WHERE Name = 'Capricorn B2B LWR Store'
 */
String ORIGINAL_WEB_STORE_ID = '0ZEHs000000tO06OAE';

/**
 * SELECT NetworkId, Name, WebStore.Name FROM WebStoreNetwork WHERE WebStore.Name = 'Capricorn B2B LWR Store'
 */
String ORIGINAL_NETWORK_ID = '0DBHs000000sfXnOAI';

//TODO: How can this be looked up?
String ORIGINAL_SITE_ID = '0DMHs000000wqUR';
//TODO: How can this be looked up?
String ORIGINAL_CHANNEL_ID = '0apHs000000pkpeIAA';
//TODO: How can this be looked up?
String ORIGINAL_MANAGED_CONTENT_SPACE_ID = '0ZuHs000000pmY7KAI'; // 0ZuHs000000pmY7KAI

/**
 * Lookups and comparisons - when working with many Ids, this article may be helpful:
 * https://help.salesforce.com/s/articleView?id=000385203&type=1
 */
String WEB_STORE_ID = '';
String NETWORK_ID = '';
String CHANNEL_ID = '';
String MANAGED_CONTENT_SPACE_ID = '';
String SITE_ID = '';
String USER = UserInfo.getUserName();


// -------- WebStore - We look this up by STORE_NAME -------- //
// SOQL Version
System.debug('-- WebStore (SOQL) - We look this up by STORE_NAME');
System.debug('---- WebStore (SOQL)');
List<WebStore> webStoresSoql = [SELECT CheckoutTimeToLive,CheckoutValidAfterDate,Country,CreatedById,CreatedDate,CurrencyIsoCode,DefaultLanguage,DefaultTaxLocaleType,DefaultTaxPolicyId,Description,ExternalReference,GuestBuyerProfileId,GuestCartTimeToLive,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LocationId,MaxValuesPerFacet,Name,OptionsAutoFacetingEnabled,OptionsCartAsyncProcessingEnabled,OptionsCartCalculateEnabled,OptionsCartToOrderAutoCustomFieldMapping,OptionsCommerceEinsteinActivitiesTracked,OptionsCommerceEinsteinDeployed,OptionsDuplicateCartItemsEnabled,OptionsGuestBrowsingEnabled,OptionsGuestCartEnabled,OptionsGuestCheckoutEnabled,OptionsPreserveGuestCartEnabled,OptionsSkipAdditionalEntitlementCheckForSearch,OptionsSkuDetectionEnabled,OptionsSplitShipmentEnabled,OrderActivationStatus,OrderLifeCycleType,OwnerId,PaginationSize,PricingStrategy,ProductGrouping,SortByPricebookId,StrikethroughPricebookId,SupportedCurrencies,SupportedLanguages,SystemModstamp,Type
FROM WebStore
WHERE Name = :STORE_NAME];
System.assert(webStoresSoql!= null, 'WebStore issue');
System.assert(webStoresSoql.size() == 1, 'WebStore issue');
System.debug('webStoresSoql records: ' + webStoresSoql.size());
WEB_STORE_ID = webStoresSoql[0].Id;
System.assertEquals(ORIGINAL_WEB_STORE_ID, WEB_STORE_ID);

// API Version
System.debug('---- WebStore (API)');
//String soqlQuery = 'SELECT Id, Name FROM WebStore WHERE Name =\'' + STORE_NAME + '\'';
String soqlQuery = 'SELECT Id, Name FROM WebStore'; //WHERE Name =\'' + STORE_NAME + '\'';
RestUtilityForQuery restUtilityForQuery = new RestUtilityForQuery();
String jsonString = restUtilityForQuery.executeQueryToJson(soqlQuery);
System.debug('------ JSON raw: ' + jsonString);
List<Object> webStoresApi = (List<Object>) restUtilityForQuery.executeQueryToMap(soqlQuery).get('records');
for(Object obj : webStoresApi)
{
    System.debug('-------- JSON Element: ' + obj);
    //System.debug('------ JSON Property: ' + obj.get('Id'));
}
System.assert(webStoresApi!= null, 'WebStore issue');
System.assert(webStoresApi.size() == 1, 'WebStore issue');
System.debug('webStoresApi records: ' + webStoresApi.size());
System.debug(webStoresApi);

//WEB_STORE_ID = webStoresApi[0].id;
System.assertEquals(ORIGINAL_WEB_STORE_ID, WEB_STORE_ID);


// -------- WebStoreNetwork - Using obtained WebStore, locate the junction between WebStore and Network -------- //
// SOQL Version
System.debug('-- WebStoreNetwork (SOQL) - Using obtained WebStore, locate the junction between WebStore and Network');
System.debug('---- WebStoreNetwork (SOQL)');
List<WebStoreNetwork> webStoreNetworksSoql = [SELECT CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,NetworkId,SiteId,
    SystemModstamp,WebStoreId
    FROM WebStoreNetwork
    WHERE WebStoreId = :webStoresSoql[0].Id];
System.assert(webStoreNetworksSoql!= null, 'WebStoreNetwork issue');
System.assert(webStoreNetworksSoql.size() == 1, 'WebStoreNetwork issue');
System.debug('webStoreNetworksSoql records: ' + webStoreNetworksSoql.size());
NETWORK_ID = webStoreNetworksSoql[0].NetworkId;
System.assertEquals(ORIGINAL_NETWORK_ID, NETWORK_ID);

// API Version
System.debug('---- WebStoreNetwork (API)');
soqlQuery = 'SELECT CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,LastModifiedDate,Name,NetworkId,SiteId,SystemModstamp,WebStoreId';
soqlQuery += ' FROM WebStoreNetwork';
// TODO: Fix this
//soqlQuery += ' WHERE WebStoreId = \'' + webStoresApi[0].Id + '\'';
//RestUtilityForQuery restUtilityForQuery = new RestUtilityForQuery();
List<Object> webStoreNetworksApi = (List<Object>) restUtilityForQuery.executeQueryToMap(soqlQuery).get('records');
System.assert(webStoreNetworksApi!= null, 'WebStoreNetwork issue');
System.assert(webStoreNetworksApi.size() == 1, 'WebStoreNetwork issue');
System.debug('webStoreNetworksApi records: ' + webStoreNetworksApi.size());

// -------- Network - Using obtained WebstoreNetwork junction obtain the Network -------- //
// SOQL Version
System.debug('-- Network - Using obtained WebstoreNetwork junction obtain the Network');
System.debug('---- Network (SOQL)');
List<Network> networksSoql = [SELECT AllowedExtensions,CaseCommentEmailTemplateId,ChangePasswordEmailTemplateId,ChgEmailVerNewEmailTemplateId,
    ChgEmailVerOldEmailTemplateId,CreatedById,CreatedDate,Description,DeviceActEmailTemplateId,EmailFooterLogoId,EmailFooterText,
    EmailSenderAddress,EmailSenderName,FirstActivationDate,ForgotPasswordEmailTemplateId,HeadlessForgotPasswordTemplateId,
    HeadlessRegistrationTemplateId,Id,LastModifiedById,LastModifiedDate,LockoutEmailTemplateId,MaxFileSizeKb,Name,NewSenderAddress,
    OptionsActionOverrideEnabled,OptionsAllowInternalUserLogin,OptionsAllowMembersToFlag,OptionsApexCDNCachingEnabled,OptionsCWBannerState,
    OptionsDirectMessagesEnabled,OptionsDisableWorkspaceInfo,OptionsEinsteinAnswersEnabled,OptionsEinsteinAnswersKAEnabled,
    OptionsEinsteinAnswersQAEnabled,OptionsEinsteinAnswersSnippetEnabled,OptionsEnableTalkingAboutStats,OptionsEnableTopicAssignmentRules,
    OptionsExperienceBundleBasedSnaOverrideEnabled,OptionsExpFriendlyUrlsAsDefault,OptionsGatherCustomerSentimentData,OptionsGuestChatterEnabled,
    OptionsGuestFileAccessEnabled,OptionsGuestMemberVisibility,OptionsHeadlessFrgtPswEnabled,OptionsImageOptimizationCDNEnabled,
    OptionsInvitationsEnabled,OptionsKnowledgeableEnabled,OptionsLWRExperienceConnectedAppEnabled,OptionsLWRExperienceOnManagedRuntime,
    OptionsLWRSearchGenerativeAnswersEnabled,OptionsMemberVisibility,OptionsMobileImageOptimizationEnabled,OptionsNetworkSentimentAnalysis,
    OptionsNicknameDisplayEnabled,OptionsPrivateMessagesEnabled,OptionsProfileBasedLayoutsForKnowledgeSearchEnabled,OptionsRecognitionBadgingEnabled,
    OptionsReputationEnabled,OptionsReputationRecordConversationsDisabled,OptionsSelfRegistrationEnabled,OptionsSendWelcomeEmail,
    OptionsShowAllNetworkSettings,OptionsSiteAsContainerEnabled,OptionsThreadedDiscussionsEnabled,OptionsTopicFilteringForKnowledgeSearchEnabled,
    OptionsTopicSuggestionsEnabled,OptionsUpDownVoteEnabled,SelfRegMicroBatchSubErrorEmailTemplateId,SelfRegProfileId,Status,SystemModstamp,
    UrlPathPrefix,VerificationEmailTemplateId,WelcomeEmailTemplateId
    FROM Network
    WHERE Id = :webStoreNetworksSoql[0].NetworkId];
System.assert(networksSoql!= null, 'Network issue');
System.assert(networksSoql.size() > 0, 'Network issue');
System.debug('networksSoql records: ' + networksSoql.size());
NETWORK_ID = networksSoql[0].Id;
System.assertEquals(ORIGINAL_NETWORK_ID, NETWORK_ID);

// API Version
System.debug('---- Network (API)');
System.debug('TBD');


// -------- Channels (ManagedContentChannel) -------- //
// SOQL Version via ManagedContentChannel
System.debug('---- Channels via ManagedContentChannel (SOQL) - Get all records');
List<ManagedContentChannel> managedContentChannelsSoql = [SELECT CacheControlMaxAge,CreatedById,CreatedDate,Domain,DomainHostName,Id,IsDeleted,LastModifiedById,LastModifiedDate,MediaCacheControlMaxAge,Name,OptionsIsCacheControlPublic,OptionsIsDomainLocked,OptionsIsSearchable,SystemModstamp,Type FROM ManagedContentChannel];
System.assert(managedContentChannelsSoql.size() > 0);
System.debug('managedContentChannelsSoql records: ' + managedContentChannelsSoql.size());
for(ManagedContentChannel channel : managedContentChannelsSoql)
{
    System.debug('------ channel.Id: ' + channel.Id);
    System.debug('------ channel.Name: ' + channel.Name);
    System.debug('------ channel.Type: ' + channel.Type);
    System.debug('------ channel.Domain: ' + channel.Domain);

    if(channel.Name == STORE_NAME) {
        CHANNEL_ID = channel.Id;
        break;
    }
}
System.assertEquals(ORIGINAL_CHANNEL_ID, CHANNEL_ID);

// API Version via ManagedContentChannelCollection - Get managed content delivery channels for the context user
System.debug('---- Channels via ManagedContentChannelCollection (API) - Get all accessible Channel records');
ConnectApi.ManagedContentChannelCollection channelCollection = ConnectApi.ManagedContent.getAllDeliveryChannels(PAGE_PARAM_ZERO, PAGE_SIZE_MAX);
System.debug('channelCollection.channels: ' + channelCollection.channels.size());
System.debug('channelCollection.totalChannels: ' + channelCollection.totalChannels);
List<ConnectApi.ManagedContentChannel> channelList = channelCollection.channels;
System.debug('channelList records: ' + channelList.size());
System.assert(channelList.size() > 0);
for(ConnectApi.ManagedContentChannel channel : channelList)
{
    System.debug('------ channelId: ' + channel.channelId);
    System.debug('------ channelName: ' + channel.channelName);
    System.debug('------ channelType: ' + channel.channelType);
    System.debug('------ domain: ' + channel.domain);

    if(channel.channelName == STORE_NAME) {
        CHANNEL_ID = channel.channelId;
        break;
    }
}
System.assertEquals(ORIGINAL_CHANNEL_ID, CHANNEL_ID);


// -------- Managed Content Space - Get the object representing the CMS Workspace linked to the Store -------- //
System.debug('---- ManagedContentSpace (SOQL) - Get the object representing the CMS Workspace for the Store');
// SOQL Version
List<ManagedContentSpace> spacesSoql = [SELECT CreatedById,CreatedDate,DefaultLanguage,Description,Id,IsDeleted,LastModifiedById,
LastModifiedDate,LastReferencedDate,LastViewedDate,Name,SystemModstamp
FROM ManagedContentSpace
WHERE Name like :STORE_NAME_WILDCARD];
System.assert(spacesSoql!= null, 'ManagedContentSpace issue');
System.assert(spacesSoql.size() > 0, 'ManagedContentSpace issue');
System.debug('spacesSoql records: ' + spacesSoql.size());
MANAGED_CONTENT_SPACE_ID = spacesSoql[0].Id;
System.assertEquals(ORIGINAL_MANAGED_CONTENT_SPACE_ID, MANAGED_CONTENT_SPACE_ID);

// API version
System.debug('-- ManagedContentSpace - Get the object representing the CMS Workspace for the Store');
System.debug('---- ManagedContentSpace (API)');
ConnectApi.ManagedContentSpace spacesApi = ConnectApi.ManagedContent.getManagedContentSpace(ORIGINAL_MANAGED_CONTENT_SPACE_ID);
System.assert(spacesApi!= null, 'ManagedContentSpace issue');
System.debug('spacesApi records: 1');
MANAGED_CONTENT_SPACE_ID = spacesApi.Id;
System.assertEquals(ORIGINAL_MANAGED_CONTENT_SPACE_ID, MANAGED_CONTENT_SPACE_ID);

if(false){
    // ManagedContentVersionCollection
    // API
    // Get all managed content versions for an Experience Cloud site with absolute URLs
    try
    {
        ConnectApi.ManagedContentVersionCollection versionCollection = ConnectApi.ManagedContent.getAllManagedContent(NETWORK_ID,
            PAGE_PARAM_ZERO, PAGE_SIZE_MAX, LANGUAGE_CODE, MANAGED_CONTENT_TYPE_IMAGE, true);
        System.assert(versionCollection != null, 'ConnectApi.ManagedContentVersionCollection issue');
        System.debug('versionCollection: ' + versionCollection);

        List<ConnectApi.ManagedContentVersion> versions = versionCollection.items;
        System.assert(versions.size() > 0);

        for(ConnectApi.ManagedContentVersion version : versions)
        {
                System.debug('contentKey: ' + version.contentKey);
                System.debug('associations: ' + version.associations);
                System.debug('contentUrlName: ' + version.contentUrlName);
                System.debug('language: ' + version.language);
                System.debug('managedContentId: ' + version.managedContentId);
                System.debug('publishedDate: ' + version.publishedDate);
                System.debug('title: ' + version.title);
                System.debug('type: ' + version.type);
                System.debug('typeLabel: ' + version.typeLabel);
                System.debug('unauthenticatedUrl: ' + version.unauthenticatedUrl);
        }
    }
    catch(Exception ex)
    {
        System.debug('WARNING: Exception trapped for continuance: ' + ex.getMessage());
    }
}


// TODO: Figure this out...
/*
List<ConnectApi.ContentImageFile> contentImageFilesApi = ConnectApi
List<ManagedContentVariant> managedContentVariants = [Select Id, Name from ManagedContentVariant];
System.assert(managedContentVariants.size() > 0, 'ManagedContentVariant issue');
System.debug('managedContentVariants: ' + managedContentVariants.size());

List<ElectronicMediaUse> electronicMediaUses = [SELECT Id FROM ElectronicMediaUse];
System.assert(electronicMediaUses.size() > 0, 'ElectronicMediaUse issue');
System.debug('electronicMediaUses: ' + electronicMediaUses.size());

List<NetworkDataCategory> networkDataCategories = [SELECT Id FROM NetworkDataCategory];
//System.assert(networkDataCategories.size() > 0, 'NetworkDataCategory issue');
System.debug('networkDataCategories: ' + networkDataCategories.size());

List<ProductCategoryMedia> productCategoryMedias = [SELECT Id FROM ProductCategoryMedia];
//System.assert(productCategoryMedias.size() > 0, 'ProductCategoryMedia issue');
System.debug('productCategoryMedias: ' + productCategoryMedias.size());

List<ProductMedia> productMedias = [SELECT Id FROM ProductMedia];
System.assert(productMedias.size() > 0, 'THE_TYPE issue');
System.debug('productMedias: ' + productMedias.size());
*/

/**
 * TEMPLATE
    Documented calls for SOQL + API versions
        // -------- Type - Get the child of Parent...[fill in the rest] -------- //
        System.debug('-- Type  Get the child of Parent');
        // SOQL Version
        System.debug('---- Type (SOQL)');
        List<Type> typesSoql = [SELECT Id, Name FROM Type];
        System.assert(typesSoql!= null, 'Type issue');
        System.assert(typesSoql.size() > 0, 'Type issue');
        System.debug('typesSoql: ' + typesSoql.size());
        SOME_ID = spacesSoql[0].Id;
        System.assertEquals(ORIGINAL_SOME_ID, SOME_ID);
        // API version
        System.debug('---- Type (API)');
        ConnectApi.ManagedContent typesApi = ConnectApi.ManagedContent.get...
        System.assert(typesApi!= null, 'Type issue');
        System.assert(typesApi.size() > 0, 'Type issue');
        System.debug('typesApi: ' + typesApi.size());
        SOME_ID = spacesSoql[0].Id;
        System.assertEquals(ORIGINAL_SOME_ID, SOME_ID);
 */