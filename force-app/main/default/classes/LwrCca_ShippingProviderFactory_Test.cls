/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-14-2024
 * @last modified by  : Tom Zarr
**/
@isTest
public class LwrCca_ShippingProviderFactory_Test {
    
    
    @isTest
    static void testgetShippingProvider(){
        LwrCca_ShippingMetaData metaData1 = createShippingMetaData('LwrCca_ShippingInternalProvider');
        Test.startTest();
        LwrCca_AbstractShippingProvider provide = LwrCca_ShippingProviderFactory.getShippingProvider(metaData1);
        Test.stopTest();
    }
    
    private static LwrCca_ShippingMetaData createShippingMetaData(String providerClass) {
        LwrCca_ShippingMetaData LwrCca_ShippingMetaData = new LwrCca_ShippingMetaData();
        LwrCca_ShippingMetaData.providerImplClass = providerClass;
        return LwrCca_ShippingMetaData;
    }
    
}