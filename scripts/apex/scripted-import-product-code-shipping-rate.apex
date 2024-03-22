/**
 * @description       : This script is a basic example of a scripted import for shipping costs associated to individual product codes.
 *                      It's current with the Spring '24 release. This is part of the Salesforce Partner Learning Camp course
 *                      "B2B Commerce: Developer Essentials" activity "Configure a Cart Orchestrator."
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/

String SCRIPT_NAME = 'Product Code Shipping Rate Import';

System.debug(SCRIPT_NAME + ' script started...');

List <ProductCodeShippingRate__c> productCodeShippingRates = [
    SELECT
        ProductCode__c,
        Rate__c
    FROM ProductCodeShippingRate__c
];

String shippingProductCode = 'Shipping Product Placeholder';
Decimal incrementValue  = 1.50;
Integer recordLimit = 20;

if(productCodeShippingRates.size() < recordLimit)
{
    // Isolate the ProductCodes we have on file in the ProductCodeShippingRate__c table already
    System.debug('Get the ProductCodes we have on file in the ProductCodeShippingRate__c table already');
    List<String> productCodesOnFileForRates = new List<String>();
    Convert.toListOf(CollectionHelper.projectPropertyToObjectList(productCodeShippingRates, 'ProductCode__c'), Type.forName('String'), productCodesOnFileForRates);


    // Get the first x products which are not already on file in the ProductCodeShippingRate__c table and are not the shipping product
    System.debug('Get the first 20 products (or whatever recordLimit is set to) which are not shipping products');
    List<Product2> nonShippingProducts = [
        SELECT Id, Name, ProductCode
        FROM Product2
        WHERE ProductCode Not in :productCodesOnFileForRates
        AND ProductCode <> :shippingProductCode
    ];

    // Isolate the ProductCode from the last result (nonShippingProducts which are not on file and not the shipping product)
    System.debug('Isolate the ProductCode from the last result (nonShippingProducts which are not on file and not the shipping product)');
    List<String> productCodesNotOnFile = new List<String>();
    Convert.toListOf(CollectionHelper.projectPropertyToObjectList(nonShippingProducts, 'ProductCode'), Type.forName('String'), productCodesNotOnFile);

    // Make a queue for the inserts
    System.debug('Make a queue for the inserts');
    List<ProductCodeShippingRate__c> productCodeShippingRateInsertions = new List<ProductCodeShippingRate__c>();
    Integer humanRow = 1;

    for(String productCode : productCodesNotOnFile)
    {
        productCodeShippingRateInsertions.Add(
            new ProductCodeShippingRate__c(
                ProductCode__c = productCode,
                Rate__c = humanRow * incrementValue
            )
        );

        humanRow++;
    }

    // Insert the new ProductCodeShippingRate__c records
    System.debug('Insert the new ProductCodeShippingRate__c records');
    insert productCodeShippingRateInsertions;
}
else
{
    System.debug('Record limit of ' + recordLimit + ' already exceeded in ProductCodeShippingRate__c. Nothing will be inserted.');
}

System.debug(SCRIPT_NAME + ' script complete.');