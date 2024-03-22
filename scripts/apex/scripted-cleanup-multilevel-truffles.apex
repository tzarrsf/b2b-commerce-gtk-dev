/**
 * @description    : This script is a clean up script for scripted imports of various levels current with the Spring '24 release. This script is part of the
 *           Salesforce Partner Learning Camp course "B2B Commerce: Developer Essentials" and activity "Scripted Import."
 * @author      : Tom Zarr
 * @group       : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on : 03-22-2024
 * @last modified by : Tom Zarr
**/

// Constants for your script run
String SCRIPT_NAME = 'Coffee Truffle cleanup multilevel script';
String STORE_NAME = 'Capricorn B2B LWR Store';
String CATEGORY_NAME = 'Coffee Truffles';

// Names of your new products
String[] PRODUCT_NAMES = new String[]
{
  'Salted Caramel Coffee Truffle',
  'Raspberry Coffee Truffle',
  'Orange Coffee Truffle',
  'Hazelnut Coffee Truffle'
};

System.debug(SCRIPT_NAME + ' script started...');

/***
Some entities are here for documentation and a didactic representation of the object graph, but won't be modified:
 - WebStore
 - Pricebook
 - ProductCatalog
 */

// Get the WebStore by Name (Not to be deleted)
System.debug('Get WebStore by Name... (Not to be deleted)');
List<WebStore> webStores = [select Id, Name from WebStore where Name = :STORE_NAME];
System.assert(webStores.size() > 0, 'Could not locate webStore. Check STORE_NAME value.');
System.debug('Get WebStore by Name complete.');

// Get the WebStore-Pricebook junction (WebStorePriceBook) (Not to be deleted)
System.debug('Get the WebStore-Pricebook junction (WebStorePriceBook)... (Not to be deleted)');
List<WebStorePricebook> webStorePriceBooks = [SELECT Id, Name, Pricebook2Id, WebStoreId FROM WebStorePricebook WHERE WebStoreId = :webStores[0].Id];
System.assert(webStorePriceBooks.size() > 0, 'Could not locate Pricebook. Check STORE_NAME value.');
System.debug('Get the WebStore-Pricebook junction (WebStorePriceBook) complete.');

// Get the Products (Product2) by name (These WILL be deleted)
System.debug('Get the Products (Product2) by Name... (These WILL be deleted)');
List<Product2> products = [select Id, Name from Product2 where Name in :PRODUCT_NAMES];

// Get the product categories by name (These WILL be deleted)
System.debug('Get the Product Categories by Name... (These WILL be deleted)');
List<ProductCategory> productCategories = [select Id, Name from ProductCategory where Name = :CATEGORY_NAME];
System.assert(productCategories.size() > 0, 'Could not locate ProductCategory. Check CATEGORY_NAME values.');

// Get the Product Category - Product junction (ProductCategoryProduct) by ProductCategoryId and CategoryId (These WILL be deleted)
System.debug('Get the Product Category - Product junction (ProductCategoryProduct) by ProductCategoryId and CategoryId (These WILL be deleted)');
List<ProductCategoryProduct> productCategoryProducts = [
  select Id, ProductId, ProductCategoryId
  FROM ProductCategoryProduct
  WHERE ProductCategoryId in :productCategories and ProductId in :products
];

// Get the Standard Pricebook
System.debug('Get the Standard Pricebook (Pricebook2)');
List<Pricebook2> standardPricebooks = [select Id, Name from Pricebook2 where isStandard = true];
System.assert(standardPricebooks.size() == 1, 'standardPriceBooks issue');
Pricebook2 standardPricebook = standardPricebooks[0];

// Get the Custom Pricebooks (Pricebook2) from the WebStore-Pricebook junction (WebStorePriceBook)... (Not to be deleted)
System.debug('Get the Pricebooks (Pricebook2) from the WebStore-Pricebook junction (WebStorePriceBook)... (Not to be deleted)');
List<Pricebook2> pricebooks = [select Id, Name from Pricebook2 where Id = :webStorePriceBooks[0].Pricebook2Id];
System.assert(pricebooks.size() > 0, 'Could not locate Pricebook2');

// Get the Standard PricebookEntries (These WILL be deleted)
System.debug('Get the Standard PricebookEntries (These WILL be deleted)');
List<PricebookEntry> standardPricebookEntries = [select Id, Name from PricebookEntry where Product2Id in :products and Pricebook2Id = :standardPricebook.Id];
System.debug('Get the Standard PricebookEntries complete.');

// Get the Custom PricebookEntries... (These WILL be deleted)
System.debug('Get the Custom PricebookEntries... (These WILL be deleted)');
List<PricebookEntry> customPricebookEntries = [select Id, Name from PricebookEntry where Product2Id in :products and Pricebook2Id in :pricebooks];
System.debug('Get the Custom PricebookEntries complete.');

/***
For deletions we need to prune leaves, then branches, then trunks speaking metaphorically
1. Full Pricing path order: PriceBookEntry, Pricebook, Product
    - Actual: PriceBookEntry
2. Full Product path order: ProductCategoryProduct, Product, ProductCategory,
    - Actual: ProductCategoryProduct, ProductCategory, Product
***/
List<List<sObject>> orderedDeletion = new List<List<sObject>>();
orderedDeletion.add(customPricebookEntries);
orderedDeletion.add(standardPricebookEntries);
orderedDeletion.add(productCategoryProducts);
orderedDeletion.add(productCategories);
orderedDeletion.add(products);

System.debug('Delete operations started...');
// Loop the outer collection by sObject type
for(List<sObject> sObjListByType : orderedDeletion) {

    // Build a queue for deletion of that type
    List<sObject> deletionBatch = new List<sObject>();

    // Loop the child objects belonging to the outer sObject type
    for(sObject childEntry : sObjListByType) {
        System.debug(String.format('Deleting Object: {0} with Id: {1}',
            new Object[]
            {
                childEntry.getSObjectType(),
                childEntry.Id
            }
        ));

        deletionBatch.add(childEntry);
    }

    // Delete from the collection for efficiency
    try {
        delete deletionBatch;
        System.debug('Batch successfully deleted.');
    }
    catch(DmlException dmlException) {
        System.debug('Batch deletion error: ' + dmlException.getMessage());
    }
}

System.debug('Delete operations complete.');
System.debug(SCRIPT_NAME + ' script complete.');