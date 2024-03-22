/**
 * @description       : This script is a level 2 example of a scripted import current with the Spring '24 release. This script is part of the
 *                      Salesforce Partner Learning Camp course "B2B Commerce: Developer Essentials" activity "Scripted Import."
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/

// Constants for your script run
String SCRIPT_NAME = 'Coffee Truffle Level 2 Import';
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

// Descriptions of your new products
String[] PRODUCT_DESCRIPTIONS = new String[]
{
    'Indulge in the divine blend of rich coffee, velvety caramel, and a tantalizing hint of salt with our Salted Caramel Coffee Truffle. Crafted with premium coffee beans and luscious caramel, each truffle is a harmonious symphony of flavors, perfectly balanced to delight your senses. Whether as a luxurious treat for yourself or a delightful gift for someone special, our Salted Caramel Coffee Truffle promises to elevate every coffee break to a moment of pure bliss.',
    'Savor the perfect marriage of tart raspberries and robust coffee in our Raspberry Coffee Truffle. Handcrafted with the finest coffee beans and infused with the essence of ripe raspberries, each truffle is a delectable burst of flavor. Balanced with a hint of sweetness and a touch of sophistication, this indulgent treat promises to awaken your taste buds and elevate your coffee experience to new heights. Treat yourself or someone special to the exquisite pleasure of our Raspberry Coffee Truffle.',
    'Experience a symphony of citrus and coffee with our Orange Coffee Truffle. Expertly crafted using premium coffee beans infused with the essence of tangy oranges, each bite delivers a harmonious blend of flavors. The zesty orange notes perfectly complement the rich, robust coffee, creating a luxurious treat that tantalizes the taste buds. Indulge in the decadence of our Orange Coffee Truffle and elevate your coffee break to a moment of pure indulgence.',
    'Discover the irresistible fusion of smooth hazelnut and bold coffee in our Hazelnut Coffee Truffle. Made with the finest coffee beans and infused with the creamy essence of hazelnuts, each truffle offers a decadent flavor experience. Indulge in the luxurious combination of nutty richness and aromatic coffee, perfectly balanced to satisfy your cravings. Elevate your coffee ritual with our Hazelnut Coffee Truffle and treat yourself to a moment of pure bliss.'
};

// Product Codes of your new products
String[] PRODUCT_CODES = new String[]
{
    'TRF-SCCT',
    'TRF-RCT',
    'TRF-OCT',
    'TRF-HCT'
};

// Sale Prices of your new products
Decimal[] SALE_PRICES = new Decimal[]
{
    17.5,
    19.5,
    18.5,
    20.99
};

// Original (Strikethrough) Prices of your new products
Decimal[] LIST_PRICES = new Decimal[]
{
    18.99,
    20.99,
    19.99,
    21.20
};

System.debug(SCRIPT_NAME + ' script started...');

// Display script settings
String variables = String.format(
    'Variable dump...\r\nSTORE_NAME: {0}\r\nCATEGORY_NAME: {1}\r\nPRODUCT_NAMES: {2}\r\nPRODUCT_DESCRIPTIONS: {3}\r\nSALE_PRICES: {4}\r\nLIST_PRICES: {5}',
    new Object[] {
        STORE_NAME,
        CATEGORY_NAME,
        String.join(PRODUCT_NAMES,', '),
        String.join(PRODUCT_DESCRIPTIONS,', '),
        String.join(SALE_PRICES,', '),
        String.join(LIST_PRICES,', ')
    }
);
System.debug(variables);

// Get the Store (WebStore) by Name
System.debug('Get the Store (WebStore) by Name');
List<WebStore> webStores = [SELECT Id, Name, Description FROM WebStore WHERE Name = :STORE_NAME];
System.assertEquals(1, webStores.size(), 'WebStore issue');

// Get the junction object (WebStoreCatalog) between the Store (WebStore) and the Product Catalog
System.debug('Get the junction object (WebStoreCatalog) between the Store (WebStore) and the Product Catalog');
List<WebStoreCatalog> webStoreCatalogs = [SELECT Id, Name, ProductCatalogId, SalesStoreId FROM WebStoreCatalog WHERE SalesStoreId = :webStores[0].Id];
System.assertEquals(1, webStoreCatalogs.size(), 'WebStoreCatalog issue');

// Get the Product Catalog for our store
System.debug('Get the Product Catalog for the WebStore from the WebStoreCatalog junction');
List<ProductCatalog> productCatalogs = [select Id, Name from ProductCatalog where Id = :webStoreCatalogs[0].ProductCatalogId];
System.assertEquals(1, productCatalogs.size(), 'ProductCatalog issue');

// Check that the Category does not exist already by name
System.debug('Check that the ProductCategory does not exist already by name');
List<ProductCategory> productCategories = [select Id, Name from ProductCategory where Name = :CATEGORY_NAME and CatalogId = :productCatalogs[0].Id];
System.assertEquals(0, productCategories.size(), 'ProductCategory issue');

// Create a new Product Category for Truffles
System.debug('Create a new Product Category for Truffles');
ProductCategory productCategory = new ProductCategory(Name = 'Coffee Truffles', CatalogId = productCatalogs[0].Id);
insert productCategory;

// Create Product records
System.debug('Create Product records');
List<Product2> products = new List<Product2>();

// Use an intentionally bad data structure that assumes perfect sorting that we'll improve in the next version
Integer trackingIndex = 0;

for (String name : PRODUCT_NAMES) {
    products.Add(
        new Product2
        (
            Name = name,
            Description = PRODUCT_DESCRIPTIONS[trackingIndex],
            ProductCode = PRODUCT_CODES[trackingIndex]
        )
    );
    trackingIndex++;
}

insert products;

// Populate the Product Category Product junction object (ProductCategoryProduct) with the products and the new category
System.debug('Populate the Product Category Product junction object (ProductCategoryProduct) with the products and their new category');
List<ProductCategoryProduct> pcps = new List<ProductCategoryProduct>();

for(Product2 product: products) {
    pcps.add(new ProductCategoryProduct(ProductCategoryId = productCategory.Id, ProductId = product.Id));
}

insert pcps;

// Get the junctions (WebStorePriceBooks) between our WebStore and PriceBook
System.debug('Get the junctions (WebStorePriceBooks) between our WebStore and PriceBook');
List<WebStorePricebook> webStorePriceBooks = [SELECT Id, Name, Pricebook2Id, WebStoreId FROM WebStorePricebook WHERE WebStoreId = :webStores[0].Id];
System.assert(webStorePriceBooks.size() > 0, 'WebStorePricebook issue');

// Get the Standard Pricebook
System.debug('Get the Standard Pricebook (Pricebook2)');
List<Pricebook2> standardPricebooks = [select Id, Name from Pricebook2 where isStandard = true];
System.assert(standardPricebooks.size() == 1, 'standardPriceBooks issue');
Pricebook2 standardPricebook = standardPricebooks[0];

// Get the Pricebooks (Pricebook2) linked to the WebStore and single out the Ids for them
System.debug('Get the Pricebooks (Pricebook2) linked to the WebStore and single out the Ids for them');
List<Id> pricebook2Ids = new List<Id>();
for(WebStorePriceBook webStorePriceBook : webStorePriceBooks) {
    pricebook2Ids.Add(webStorePriceBook.Pricebook2Id);
}
List<Pricebook2> priceBooks = [SELECT Id, Name, ValidFrom, ValidTo FROM Pricebook2 WHERE Id in :pricebook2Ids];
System.assert(priceBooks.size() > 0, 'priceBooks issue');
System.assert(priceBooks.size() >= 1, 'priceBooks issue - should be at least a list pricebook');

// Check that the Custom Pricebook Entries do not exist already by Pricebook2Id, Product2Id and ProductCode
System.debug('Check that the Pricebook Entries do not exist already by Pricebook2Id, Product2Id and ProductCode');
List<PricebookEntry> pricebookEntries = [SELECT Id, CurrencyIsoCode, Pricebook2Id, Product2Id, ProductCode, ProductSellingModelId, UnitPrice, UseStandardPrice
FROM PricebookEntry WHERE Pricebook2Id in :pricebook2Ids and Product2Id in :products and ProductCode in :PRODUCT_CODES];
System.assert(pricebookEntries.size() == 0, 'PricebookEntry found when there should not be any');

// Create the PriceBookEntries using the dirty data structure
System.debug('Create the PriceBookEntries using the dirty data structure');
pricebookEntries = new List<PricebookEntry>();

// Insert the Standard Pricebook entries using an intentionally bad data structure that assumes perfect sorting. We'll improve it in the next version
trackingIndex = 0;

for(Product2 product: products) {
    pricebookEntries.add(
        new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = standardPricebook.Id,
            UnitPrice = LIST_PRICES[trackingIndex]
        )
    );
    trackingIndex++;
}

insert pricebookEntries;

// Insert the Custom Pricebook entries using an intentionally bad data structure that assumes perfect sorting. We'll improve it in the next version
pricebookEntries.clear();
trackingIndex = 0;

for(Product2 product: products) {
    pricebookEntries.add(
        new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = pricebooks[0].Id,
            UnitPrice = SALE_PRICES[trackingIndex]
        )
    );
    trackingIndex++;
}

insert pricebookEntries;

System.debug(SCRIPT_NAME + ' script complete.');