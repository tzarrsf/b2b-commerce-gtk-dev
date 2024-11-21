/**
 * @description       : Unit tests for the LwrCca_TaxAvalaraRequest class.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-25-2024
 * @last modified by  : Tom Zarr
**/

@isTest
public class LwrCca_TaxAvalaraRequestTest
{
    public LwrCca_TaxAvalaraRequestTest() {}

    @isTest
    static void testParseValidJson()
    {
        String validJson = jsonString();
        Test.startTest();
        LwrCca_TaxAvalaraRequest request = LwrCca_TaxAvalaraRequest.parse(validJson);
        Test.stopTest();

    }

    @isTest
    static void testDefaultMethod()
    {
        LwrCca_TaxAvalaraRequest.Addresses address = new LwrCca_TaxAvalaraRequest.Addresses();
        Test.startTest();
        LwrCca_TaxAvalaraRequest avalara = new LwrCca_TaxAvalaraRequest();
        LwrCca_TaxAvalaraRequest.Parameters parameters = new LwrCca_TaxAvalaraRequest.Parameters();
        Test.stopTest();
    }

    @isTest
    static void testDefaultMethodTaxAmountByTaxTypes()
    {
        Test.startTest();
        LwrCca_TaxAvalaraRequest.TaxAmountByTaxTypes taxAmount = new LwrCca_TaxAvalaraRequest.TaxAmountByTaxTypes();
        LwrCca_TaxAvalaraRequest.TaxOverride taxOverride = new LwrCca_TaxAvalaraRequest.TaxOverride();
        Test.stopTest();
    }

    @isTest
    static void testDefaultMethodNull()
    {
        Test.startTest();
        LwrCca_TaxAvalaraRequest.ShipFrom shipFrom = new LwrCca_TaxAvalaraRequest.ShipFrom();
        LwrCca_TaxAvalaraRequest.UserDefinedFields userDefinedFields = new LwrCca_TaxAvalaraRequest.UserDefinedFields();
        LwrCca_TaxAvalaraRequest.Lines lines = new LwrCca_TaxAvalaraRequest.Lines();
        Test.stopTest();
    }

    private static string jsonString()
    {
        String json = '{' +
            '"lines": [' +
                '{' +
                    '"number": "1",' +
                    '"quantity": 1.0,' +
                    '"taxCode": "abc",' +
                    '"customerUsageType": "customerUsage",' +
                    '"entityUseCode": "entityUse",' +
                    '"entityUse": "entity",' +
                    '"itemCode": "123C",' +
                    '"exemptionCode": "exemptionCode",' +
                    '"discounted": true,' +
                    '"taxIncluded": true,' +
                    '"revenueAccount": "revenue",' +
                    '"ref1": "123C",' +
                    '"ref2": "123C",' +
                    '"description": "description",' +
                    '"businessIdentificationNo": "123CbusinessIdentificationNo",' +
                    '"taxOverride": {' +
                    '"type": "SalesOrder",' +
                    '"reason": "SalesOrder reason",' +
                    '"taxDate":"2024-05-30T00:00:00.000Z",'+
                    '"taxes": "SalesOrder",' +
                    '"taxAmountByTaxTypes": [' +
                    '{' +
                        '"taxTypeId": "Param1",' +
                        '"taxType": "Param1",' +
                        '"taxAmount": 1.0' +
                    '}' +
                '],' +
                    '"taxAmount": 1.0' +
                '},' +
                '"parameters": [' +
                    '{' +
                        '"name": "Param",' +
                        '"name1": "Param1",' +
                        '"unit": "unit1",' +
                        '"value": "Value1"' +
                    '}' +
                '],' +
                '"userDefinedFields": [' +
                    '{' +
                        '"name": "UDF1",' +
                        '"name1": "UDF1",' +
                        '"value": "Value2"' +
                    '}' +
                '],' +
                    '"hsCode": "123C",' +
                    '"merchantSellerIdentifier": "123C",' +
                    '"marketplaceLiabilityType": "123CmarketplaceLiabilityType",' +
                    '"originationDocumentId": "123C",' +
                    '"summary": "123C",' +
                    '"originationSite": "123C",' +
                    '"category": "product",' +
                    '"merchantSellerId": 10.0,' +
                    '"addresses": {},' +

                    '"amount": 10.0' +
                '}' +
            '],' +
            '"addresses": {' + 
                '"ship": "ship",' +               
                '"shipFrom": {' +
                    '"id": "1",' +
                    '"transactionId": 1,' +
                    '"boundaryLevel": "Address",' +
                    '"line1": "123 Main St",' +
                    '"city": "Anytown",' +
                    '"region": "CA",' +
                    '"postalCode": "12345",' +
                    '"taxRegionId": 1,' +
                    '"taxRegion": "Address",' +
                    '"country": "US"' +
                '},' +
                '"shipTo": {' +
                    '"id": "2",' +
                    '"transactionId": 2,' +
                    '"boundaryLevel": "Address",' +
                    '"line1": "456 Elm St",' +
                    '"city": "Othertown",' +
                    '"region": "NY",' +
                    '"postalCode": "67890",' +
                    '"country": "US"' +
                '}' +
            '},' +
            '"code": "123",' +
            '"type": "SalesOrder",' +
            '"companyCode": "ABC",' +
            '"date": "2022-01-01",' +
            '"salespersonCode": "123",' +
            '"customerCode": "456",' +
            '"customerUsageType": "G",' +
            '"entityUseCode": "P",' +
            '"discount": 0,' +
            '"exemptionNo": "789",' +
            '"reportingLocationCode": "012",' +
            '"purchaseOrderNo": "321",' +
            '"currencyCode": "USD",' +
            '"description": "Test Order",' +
            '"referenceCode": "T123",' +
            '"commit": true,' +
            '"batchCode": "B123",' +
            '"serviceMode": "Remote",' +
            '"exchangeRate": 1.0,' +
            '"exchangeRateEffectiveDate": "2022-01-01",' +
            '"exchangeRateCurrencyCode": "USD",' +
            '"posLaneCode": "POS1",' +
            '"businessIdentificationNo": "987",' +
            '"isSellerImporterOfRecord": true,' +
            '"email": "test@example.com",' +
            '"debugLevel": "Normal",' +
            '"customerSupplierName": "Test Supplier",' +
            '"dataSourceId": 1,' +
            '"deliveryTerms": "FOB",' +
            '"deliveryTerm": "FOB",' +
            '"taxOverride": {' +
                '"type": "SalesOrder",' +
                '"reason": "SalesOrder reason",' +
                '"taxDate":"2024-05-30T00:00:00.000Z",'+
                '"taxes": "SalesOrder",' +
                '"taxAmountByTaxTypes": [' +
                '{' +
                    '"taxTypeId": "Param1",' +
                    '"taxType": "Param1",' +
                    '"taxAmount": 1.0' +
                '}' +
            '],' +
                '"taxAmount": 1.0' +
            '},' +
            '"parameters": [' +
                '{' +
                    '"name": "Param",' +
                    '"name1": "Param1",' +
                    '"unit": "unit1",' +
                    '"value": "Value1"' +
                '}' +
            '],' +
            '"userDefinedFields": [' +
                '{' +
                    '"name": "UDF1",' +
                    '"name1": "UDF1",' +
                    '"value": "Value2"' +
                '}' +
            ']' +
        '}';

        return json;
    }
}