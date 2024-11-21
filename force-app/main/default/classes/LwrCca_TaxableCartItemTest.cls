/**
 * @description       : Unit tests for the LwrCca_TaxableCartItem class.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 11-20-2024
 * @last modified by  : Tom Zarr
**/
@isTest
public with sharing class LwrCca_TaxableCartItemTest
{
    public LwrCca_TaxableCartItemTest() {}

    @isTest
    static void testTaxableCartItemCreation()
    {
        Test.startTest();
        LwrCca_TaxableCartItem taxableCartItem = new LwrCca_TaxableCartItem();
        taxableCartItem.id = '123';
        taxableCartItem.amount = 100.00;
        taxableCartItem.quantity = 1;
        taxableCartItem.sku = 'ABC';
        taxableCartItem.lineItemType = 'Product';
        taxableCartItem.taxClassId = 'Taxable';
        taxableCartItem.productExemptionCode = 'None';
        taxableCartItem.entityUseCode = 'None';
        taxableCartItem.street = '123 Main St';
        taxableCartItem.city = 'Anytown';
        taxableCartItem.state = 'CA';
        taxableCartItem.postalCode = '12345';
        taxableCartItem.country = 'US';
        Test.stopTest();

        System.assertNotEquals(null, taxableCartItem, 'LwrCca_TaxableCartItem should not be null');
        System.assertEquals('123', taxableCartItem.id, 'Incorrect ID');
        System.assertEquals(100.00, taxableCartItem.amount, 'Incorrect amount');
        System.assertEquals(1, taxableCartItem.quantity, 'Incorrect quantity');
        System.assertEquals('ABC', taxableCartItem.sku, 'Incorrect SKU');
        System.assertEquals('Product', taxableCartItem.lineItemType, 'Incorrect line item type');
        System.assertEquals('Taxable', taxableCartItem.taxClassId, 'Incorrect tax class ID');
        System.assertEquals('None', taxableCartItem.productExemptionCode, 'Incorrect product exemption code');
        System.assertEquals('None', taxableCartItem.entityUseCode, 'Incorrect entity use code');
        System.assertEquals('123 Main St', taxableCartItem.street, 'Incorrect street');
        System.assertEquals('Anytown', taxableCartItem.city, 'Incorrect city');
        System.assertEquals('CA', taxableCartItem.state, 'Incorrect state');
        System.assertEquals('12345', taxableCartItem.postalCode, 'Incorrect postal code');
        System.assertEquals('US', taxableCartItem.country, 'Incorrect country');
    }
}