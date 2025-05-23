/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-14-2024
 * @last modified by  : Tom Zarr
**/
@isTest
public class LwrCca_ShippingDetailsTest {
    
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
    public static void getMetaDataDTOTest(){
        WebStore store = [Select id, Name from WebStore where Name = 'Training' Limit 1];
        Shipping_Provider__mdt ship = getCustomMetadataRecord();
        List<LwrCca_ShippingMetaData> shipproviderList = new List<LwrCca_ShippingMetaData>();
        String currentLocale = UserInfo.getlocale();
        LwrCca_ShippingMetaData shipmeta = new LwrCca_ShippingMetaData();
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
        shipproviderList.add(shipmeta);
        Test.startTest();
        List<LwrCca_ShippingMetaData> result = LwrCca_ShippingDetails.getMetaDataDTO(store.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(result[0].maxPackageWeight,null);
        System.assertEquals(result[0].minPackageWeight,null);
        System.assertEquals(result[0].accountNumber, null);
        System.assertEquals(result[0].endPoint, null);
        System.assertEquals(result[0].httpMethod, 'POST');
        System.assertEquals(result[0].shippinggMethodNames, null);
        System.assertEquals(result[0].serviceTimeout, null);
        System.assertEquals(result[0].requestJSON, null);
        System.assertEquals(result[0].providerImplClass, 'LwrCca_ShippingInternalProvider');
        System.assertEquals(result[0].mockedResponse, null);
        System.assertEquals(result[0].serviceImplClass, null);
        System.assertEquals(result[0].namedCredentials,null);
    }

    public static Shipping_Provider__mdt getCustomMetadataRecord() {
        Shipping_Provider__mdt testShipProvider = new Shipping_Provider__mdt(
            Context_Name__c = 'Training',
            Context_Locale__c = 'en_US',
            Impl_Class__c = 'LwrCca_ShippingInternalProvider'
        ); 
        return testShipProvider;
    }

    @isTest
    public static void getMetaDataObjectTest(){
        Test.startTest();
        Object result = LwrCca_ShippingDetails.getMetaDataObject();
        Test.stopTest();
        System.assertEquals(result,null);
    }
}