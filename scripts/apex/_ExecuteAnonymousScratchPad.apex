/**
 * This is a substitute for the Developer Console 'Execute Anonymous Apex' functionality
 * Paste your apex code here and then run the Command Palette (Ctrl + Shift + P) to use either:
 * 1. "SFDX: Execute Anonymous Apex with Editor" - for the whole file
 * 2. "SFDX: Execute Anonymous Apex with Currently Selected Text" - for what's higlighted
**/

Network network = NetworkController.getNetworkByName(TestSettings.KNOWN_GOOD_NETWORK_NAME);
WebStore webStore = WebStoreController.getWebStoreByNameAndNetwork(TestSettings.KNOWN_GOOD_NETWORK_NAME, network);
ProductCatalog productCatalog = ProductCatalogController.getCatalogByWebStore(webstore);
List<ProductCategory> productCategories = ProductCategoryEnhancedController.getProductCategoriesByCatalog(productCatalog);

for(ProductCategory productCategory : productCategories) {
    List<Map<String, Object>> productsWithInventoryCheck = ProductCategoryEnhancedController.getProductsByCategoryIdViaDatabase(productCategory.Id, true);

    // Filter out the categories without products
    if(productsWithInventoryCheck == null || productsWithInventoryCheck.isEmpty()) {
        continue;
    }

    for(Map<String, Object> productWithInventoryCheck : productsWithInventoryCheck) {
        System.Assert(productWithInventoryCheck.get('id') != null, 'id is null');
        System.Assert(productWithInventoryCheck.get('name') != null, 'name is null');
        System.Assert(productWithInventoryCheck.get('sku') != null, 'sku is null');
        System.Assert(productWithInventoryCheck.get('price') != null, 'price is null');
        System.Assert(productWithInventoryCheck.get('availableToOrder') != null, 'availableToOrder is null');
    }
}