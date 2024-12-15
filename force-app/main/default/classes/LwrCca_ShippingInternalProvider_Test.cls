/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-15-2024
 * @last modified by  : Tom Zarr
**/
@isTest
public class LwrCca_ShippingInternalProvider_Test {
    @testSetup
    static void setup(){
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='Training', SupportedLanguages='en_US', DefaultLanguage='en_US');
        insert webStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
    }
   
    @isTest
    static void testretrieveShippingRates(){
        LwrCca_ShippingProviderRequest shippingRequest = shipProviderRequest();
        Test.startTest();
        LwrCca_ShippingInternalProvider internalShip = new LwrCca_ShippingInternalProvider();
         Map<String, LwrCca_ShippingProviderResponse> response =  internalShip.retrieveShippingRates(shippingRequest);
         System.assertNotEquals(null, response, 'Response should not be null');

        Test.stopTest();
        
    }
    @isTest
    static void testgetShippingOptionsFromResponse(){
        LwrCca_ShippingProviderRequest shippingRequest = shipProviderRequest();
        List<String> responseList = new List<String>();
        Test.startTest();
        LwrCca_ShippingInternalProvider internalShip = new LwrCca_ShippingInternalProvider();
          Map<String, LwrCca_ShippingProviderResponse> response = internalShip.getShippingOptionsFromResponse(responseList,shippingRequest);
                System.assertNotEquals(null, response, 'Response should not be null');

        Test.stopTest();
        
    }
    @isTest
    static void testprepareRequestBody(){
        LwrCca_ShippingProviderRequest shippingRequest = shipProviderRequest();
        Map<String, String> callOutRequest = new Map<String, String>();
        Test.startTest();
        LwrCca_ShippingInternalProvider internalShip = new LwrCca_ShippingInternalProvider();
        internalShip.prepareRequestBody(shippingRequest,callOutRequest);
        Test.stopTest();
        
    }
    private static LwrCca_ShippingProviderRequest  shipProviderRequest(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        LwrCca_ShippingProviderRequest shipProvider = new LwrCca_ShippingProviderRequest();
         LwrCca_ShippingMetaData shipmeta = new LwrCca_ShippingMetaData();
        shipProvider.street ='1600 Massachusetts Avenue';
        shipProvider.city = 'Washington';
        shipProvider.state = 'Washington DC';
        shipProvider.postalCode = '20011';
        shipProvider.country = 'United States';
        LwrCca_ShippingProviderResponse response = new LwrCca_ShippingProviderResponse();
        response.classOfService ='Test';
        response.getData('key');
        response.addData('key', 100);
        response.shipDate ='today';
        response.days =1;
        shipProvider.cartId = webCart.id;
        shipProvider.packageWeight = 32.00;
        shipProvider.shippingMetaData = shipmeta;
        shipProvider.getData('Test');
        shipProvider.addData('Test', webCart);
        Shipping_Provider__mdt testShipProvider =[Select id from Shipping_Provider__mdt where Impl_Class__c = 'LwrCca_ShippingInternalProvider' LIMIT 1];
        shipmeta.id = testShipProvider.Id;
        shipmeta.maxPackageWeight= 100.90;
        shipmeta.minPackageWeight = 10.89;
        shipmeta.accountNumber ='AB56';
        shipmeta.endPoint ='https://api.test.com/endpoint';
        shipmeta.httpMethod = 'POST';
        shipmeta.shippinggMethodNames ='Standard, Express';
        shipmeta.serviceTimeout ='30';
        shipmeta.requestJSON='{"key": "value"}';
        shipmeta.providerImplClass ='TestProviderClass';
        shipmeta.mockedResponse ='{"response": "mocked"}';
        shipmeta.serviceImplClass ='TestServiceClass';
        shipmeta.addMetaData('key2', 100);
        shipmeta.serviceMode ='Test';
        shipmeta.getMetaData('Test');
        shipmeta.namedCredentials= 'TestCredentials';
        return shipProvider;
    }
    public static Shipping_Provider__mdt getCustomMetadataRecord() {
        Shipping_Provider__mdt testShipProvider = new Shipping_Provider__mdt(
            Context_Name__c = 'Training',
            Context_Locale__c = 'en_US',
            Impl_Class__c = 'LwrCca_ShippingInternalProvider'
      		); 
        	return testShipProvider;
    }

}