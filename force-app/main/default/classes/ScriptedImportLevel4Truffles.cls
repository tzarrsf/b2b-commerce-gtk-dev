/**
 * @description       : This script is a level 4 example of a scripted import current with the Spring '24 release. This script is part of the
 *                      Salesforce Partner Learning Camp course "B2B Commerce: Developer Essentials" activity "Scripted Import." This
 *                      approach assumes known product image urls for the product list and first detail image and is dependent on the class
 *                      ScriptedImportLevel4Element as a DTO.
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class ScriptedImportLevel4Truffles {

    // Constants for your script run
    public static final String SCRIPT_NAME = 'Coffee Truffle Level 4 Import';
    public static final String STORE_NAME = 'Capricorn B2B LWR Store';
    public static final String CATEGORY_NAME = 'Coffee Truffles';

    // Use a better collection structure than our Level 2 script
    public static final ScriptedImportLevel4Element[] importElements = new ScriptedImportLevel4Element[]
    {
        new ScriptedImportLevel4Element
        (
            'Salted Caramel Coffee Truffle',
            'Indulge in the divine blend of rich coffee, velvety caramel, and a tantalizing hint of salt with our Salted Caramel Coffee Truffle. Crafted with premium coffee beans and luscious caramel, each truffle is a harmonious symphony of flavors, perfectly balanced to delight your senses. Whether as a luxurious treat for yourself or a delightful gift for someone special, our Salted Caramel Coffee Truffle promises to elevate every coffee break to a moment of pure bliss.',
            'TRF-SCCT',
            'TRF-SCCT-SKU',
            18.99,
            17.5,
            'ListImage',
            'DetailImage'
        ),
        new ScriptedImportLevel4Element
        (
            'Raspberry Coffee Truffle',
            'Savor the perfect marriage of tart raspberries and robust coffee in our Raspberry Coffee Truffle. Handcrafted with the finest coffee beans and infused with the essence of ripe raspberries, each truffle is a delectable burst of flavor. Balanced with a hint of sweetness and a touch of sophistication, this indulgent treat promises to awaken your taste buds and elevate your coffee experience to new heights. Treat yourself or someone special to the exquisite pleasure of our Raspberry Coffee Truffle.',
            'TRF-RCT',
            'TRF-RCT-SKU',
            20.99,
            19.5,
            'ListImage',
            'DetailImage'
        ),
        new ScriptedImportLevel4Element
        (
            'Orange Coffee Truffle',
            'Experience a symphony of citrus and coffee with our Orange Coffee Truffle. Expertly crafted using premium coffee beans infused with the essence of tangy oranges, each bite delivers a harmonious blend of flavors. The zesty orange notes perfectly complement the rich, robust coffee, creating a luxurious treat that tantalizes the taste buds. Indulge in the decadence of our Orange Coffee Truffle and elevate your coffee break to a moment of pure indulgence.',
            'TRF-OCT',
            'TRF-OCT-SKU',
            19.99,
            18.5,
            'ListImage',
            'DetailImage'
        ),
        new ScriptedImportLevel4Element
        (
            'Hazelnut Coffee Truffle',
            'Discover the irresistible fusion of smooth hazelnut and bold coffee in our Hazelnut Coffee Truffle. Made with the finest coffee beans and infused with the creamy essence of hazelnuts, each truffle offers a decadent flavor experience. Indulge in the luxurious combination of nutty richness and aromatic coffee, perfectly balanced to satisfy your cravings. Elevate your coffee ritual with our Hazelnut Coffee Truffle and treat yourself to a moment of pure bliss.',
            'TRF-HCT',
            'TRF-HCT-SKU',
            21.20,
            20.99,
            'ListImage',
            'DetailImage'
        )
    };

    // Channeling Martin Fowler here where the comments become methods
    private static void displayScriptSettings()
    {
        // Display script settings
        String variables = String.format(
            'Variable dump...\r\nSTORE_NAME: {0}\r\nCATEGORY_NAME: {1}\r\nNumber of import records: {2}',
            new Object[] {
                STORE_NAME,
                CATEGORY_NAME,
                importElements.size()
            }
        );
        System.debug(variables);
    }

    private static WebStore getWebStoreByName(String name)
    {
        // Get the Store (WebStore) by Name
        System.debug('Get the Store (WebStore) by Name');
        List<WebStore> webStores = [SELECT Id, Name, Description FROM WebStore WHERE Name = :name];
        System.assertEquals(1, webStores.size(), 'WebStore issue');
        return webStores[0];
    }

    private static WebStoreCatalog getWebStoreCatalogJunctionByWebStore(Webstore webStore)
    {
        // Get the junction object (WebStoreCatalog) between the Store (WebStore) and the Product Catalog
        System.debug('Get the junction object (WebStoreCatalog) between the Store (WebStore) and the Product Catalog');
        List<WebStoreCatalog> webStoreCatalogs = [SELECT Id, Name, ProductCatalogId, SalesStoreId FROM WebStoreCatalog WHERE SalesStoreId = :webStore.Id];
        System.assertEquals(1, webStoreCatalogs.size(), 'WebStoreCatalog issue');
        return webStoreCatalogs[0];
    }

    // This could be simplified in the next version
    private static ProductCatalog getProductCatalogByWebStoreCatalogJunction(WebStoreCatalog webStoreCatalog)
    {
        // Get the Product Catalog for our store
        System.debug('Get the Product Catalog for the WebStore from the WebStoreCatalog junction');
        List<ProductCatalog> productCatalogs = [select Id, Name from ProductCatalog where Id = :webStoreCatalog.ProductCatalogId];
        System.assertEquals(1, productCatalogs.size(), 'ProductCatalog issue');
        return productCatalogs[0];
    }

    // Check that the Category does not exist already by name then create it
    private static ProductCategory createProductCategory(String categoryName, ProductCatalog productCatalog)
    {
        // Check that the Category does not exist already by name
        System.debug('Check that the ProductCategory does not exist already by name');
        List<ProductCategory> productCategories = [select Id, Name from ProductCategory where Name = :categoryName and CatalogId = :productCatalog.Id];
        System.assertEquals(0, productCategories.size(), 'ProductCategory issue');

        // Create a new Product Category for Truffles
        System.debug('Create a new Product Category for Truffles');
        ProductCategory productCategory = new ProductCategory(Name = 'Coffee Truffles', CatalogId = productCatalog.Id);
        insert productCategory;
        return productCategory;
    }

    // Create Product records
    private static List<Product2> createProducts()
    {
         System.debug('Create Product records');
         List<Product2> products = new List<Product2>();

         // Use our much-improved data structure to create products
         for(ScriptedImportLevel4Element element : importElements) {
             products.Add(
                 new Product2
                 (
                     Name = element.Name,
                     Description = element.Description,
                     ProductCode = element.ProductCode,
                     StockKeepingUnit = element.StockKeepingUnit
                 )
             );
         }

         insert products;
         return products;
    }

    private static List<ProductCategoryProduct> createProductCategoryProductJunction(ProductCategory productCategory, List<Product2> products)
    {
        // Populate the Product Category Product junction object (ProductCategoryProduct) with the products and the new category
        System.debug('Populate the Product Category Product junction object (ProductCategoryProduct) with the products and their new category');
        List<ProductCategoryProduct> pcps = new List<ProductCategoryProduct>();

        for(Product2 product: products) {
            pcps.add(new ProductCategoryProduct(ProductCategoryId = productCategory.Id, ProductId = product.Id));
        }

        insert pcps;
        return pcps;
    }

    private static List<WebStorePricebook> getWebStorePricebookByWebStore(WebStore webStore)
    {
        // Get the junctions (WebStorePriceBooks) between our WebStore and PriceBook
        System.debug('Get the junctions (WebStorePriceBooks) between our WebStore and PriceBook');
        List<WebStorePricebook> webStorePriceBooks = [SELECT Id, Name, Pricebook2Id, WebStoreId FROM WebStorePricebook WHERE WebStoreId = :webStore.Id];
        System.assert(webStorePriceBooks.size() > 0, 'WebStorePricebook issue');
        return webStorePriceBooks;
    }

    private static List<Pricebook2> getStandardPriceBooks()
    {
        // Get the Standard Pricebook
        System.debug('Get the Standard Pricebook (Pricebook2)');
        List<Pricebook2> standardPricebooks = [select Id, Name from Pricebook2 where isStandard = true];
        System.assert(standardPricebooks.size() == 1, 'standardPriceBooks issue');
        return standardPricebooks;
    }

    private static List<Pricebook2> getCustomPricebooksByWebStorePricebooks(List<WebStorePricebook> webStorePricebooks)
    {
        // TODO: Use projection
        List<Id> pricebook2Ids = new List<Id>();
        for(WebStorePriceBook webStorePriceBook : webStorePriceBooks) {
            pricebook2Ids.add(webStorePriceBook.Pricebook2Id);
        }

        // Get the custom Pricebooks (Pricebook2) linked to the WebStore and single out the Ids for them
        System.debug('Get the custom Pricebooks (Pricebook2) linked to the WebStore and single out the Ids for them');
        List<Pricebook2> priceBooks = [SELECT Id, Name, ValidFrom, ValidTo FROM Pricebook2 WHERE Id in :pricebook2Ids];
        System.assert(priceBooks.size() > 0, 'priceBooks issue');
        System.assert(priceBooks.size() >= 1, 'priceBooks issue - should be at least a list pricebook');
        return pricebooks;
    }

    public static List<PriceBookEntry> createPricebookEntries(List<Pricebook2> pricebooks, List<Product2> products)
    {
        List<String> productCodes = new List<String>();
        Convert.toListOf(CollectionHelper.projectPropertyToObjectList(products, 'ProductCode'), Type.forName('String'), productCodes);

        List<Id> priceBookIds = new List<Id>();
        Convert.toListOf(CollectionHelper.projectPropertyToObjectList(pricebooks, 'Id'), Type.forName('Id'), priceBookIds);

        // Check that the Custom Pricebook Entries do not exist already by Pricebook2Id, Product2Id and ProductCode
        System.debug('Check that the Pricebook Entries do not exist already by Pricebook2Id, Product2Id and ProductCode');
        List<PricebookEntry> pricebookEntries = [SELECT Id, CurrencyIsoCode, Pricebook2Id, Product2Id, ProductCode, ProductSellingModelId, UnitPrice, UseStandardPrice
        FROM PricebookEntry WHERE Pricebook2Id in :pricebookIds and Product2Id in :products and ProductCode in :productCodes];
        System.assert(pricebookEntries.size() == 0, 'PricebookEntry found when there should not be any');

        // Create the PriceBookEntries using the much-improved data structure
        System.debug('Create the PriceBookEntries using the much-improved data structure');
        pricebookEntries = new List<PricebookEntry>();

        /***
        * Insert the Pricebook entries using the improved data structure. Lambda expressions would be great here, but
        * we're in the Apex world of nerfed or 'bumper bowling' Java/C# without such tools, so we'll make do with a nested loop.
        */
        for(ScriptedImportLevel4Element element : importElements)
        {
            // Match the products
            for(Product2 product: products)
            {
                if(element.ProductCode == product.ProductCode) {
                    /***
                     * We're in the match now - Winner, winner, chicken dinner!
                     * This pricebook loop is a bit dirty and there's likely a cleaner way to do this which we can address in
                     * level 5 seeing as we'll need the Standard Pricebook inserted and there's only one of those, then a Store
                     * will typically have a Strikethrough/Original Pricebook and a Sale Pricebook.
                     */
                    for(Pricebook2 pricebook : pricebooks)
                    {
                        pricebookEntries.add(
                            new PricebookEntry(
                                Product2Id = product.Id,
                                Pricebook2Id = pricebook.Id,
                                UnitPrice = element.StandardPrice
                            )
                        );
                    }
                }
            }
        }

        insert pricebookEntries;
        return pricebookEntries;
    }

    public static void startImport()
    {
        System.debug(SCRIPT_NAME + ' script started...');

        displayScriptSettings();
        WebStore webStore = getWebStoreByName(STORE_NAME);
        WebStoreCatalog webStoreCatalog = getWebStoreCatalogJunctionByWebStore(webStore);
        ProductCatalog productCatalog = getProductCatalogByWebStoreCatalogJunction(webStoreCatalog);
        ProductCategory productCategory = createProductCategory(CATEGORY_NAME, productCatalog);
        List<Product2> products = createProducts();
        List<ProductCategoryProduct> pcps = createProductCategoryProductJunction(productCategory, products);
        List<WebStorePricebook> webStorePricebooks = getWebStorePricebookByWebStore(webStore);
        List<Pricebook2> standardPricebooks = getStandardPriceBooks();
        List<Pricebook2> customPricebooks = getCustomPricebooksByWebStorePricebooks(webStorePricebooks);
        List<PricebookEntry> standardPricebookEntries = createPricebookEntries(standardPricebooks, products);
        List<PricebookEntry> customPricebookEntries = createPricebookEntries(customPricebooks, products);

        System.debug(SCRIPT_NAME + ' script complete.');
    }
}