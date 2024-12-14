/**
 * @description       : Unit tests for the LwrCca_TaxConfiguration class.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-13-2024
 * @last modified by  : Tom Zarr
**/
@IsTest
public class LwrCca_TaxConfiguration_Test
{
    @testSetup
    static void setup()
    {
        WebStore webStore = new WebStore(
            Name = 'R1Training',
            Tax_Document_Type__c ='INVOICE',
            Tax_Transaction_Type__c ='SALE'
        );
        insert webStore;
    }

    @isTest
    static void testgetMetaDataDTO()
    {
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name = 'R1Training' LIMIT 1];
        String name = 'R1Training';
        Tax_Provider__mdt taxMeta = getCustomMetadataRecord(name);
        Test.startTest();
        LwrCca_TaxMetaData result = LwrCca_TaxConfiguration.getMetaDataDTO(webStore.Id, null, null);
        System.assert(result != null);
        Test.stopTest();
    }

    @isTest
    static void testgetMetaDataObject()
    {
        Test.startTest();
        Tax_Provider__mdt metaProviderData = LwrCca_TaxConfiguration.getMetaDataObject();
        System.assert(metaProviderData == null);
        Test.stopTest();
    }

    public static Tax_Provider__mdt getCustomMetadataRecord(String myName)
    {
        Tax_Provider__mdt testTaxProvider = new Tax_Provider__mdt
        (
            Context_Name__c = myName,
            Context_Locale__c = 'en_GB',
            Taxation_Policy__c = 'Standard',
            Customer_Code__c = 'Cust123',
            Company_Code__c = 'Comp456',
            Shipping_Items_Taxable__c = true,
            Default_Shipping_Tax_Code__c = 'ShippingTax',
            Default_Product_Tax_Code__c = 'ProductTax',
            Consider_product_tax_codes__c = true,
            Product_Tax_Exemption__c = false,
            Customer_Tax_Exemption__c = true,
            Document_Type__c = 'INVOICE',
            Transaction_Type__c = 'SALE',
            Commit__c = true,
            Address_Line1__c = '123 Test St',
            Address_Line2__c = 'Suite 100',
            City__c = 'Test City',
            State__c = 'Test State',
            Zip_Code__c = '12345',
            Country_Code__c = 'USA',
            Impl_Class__c = 'LwrCca_VertexTaxProvider',
            Request_Template__c = '{"request": "template"}'
      	);

        return testTaxProvider;
    }
}