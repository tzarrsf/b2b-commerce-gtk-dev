/**
 * @description       : This script is a basic example of a scripted import current with the Spring '24 release. This script is part of the
 *                      Salesforce Partner Learning Camp course "B2B Commerce: Developer Essentials" activity "Scripted Import."
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/

// Constants for your script run
String SCRIPT_NAME = 'Coffee Truffle Basic Import';
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

// Display script settings
String variables = String.format(
    'Variable dump...\r\nSTORE_NAME: {0}\r\nCATEGORY_NAME: {1}\r\nPRODUCT_NAMES: {2}\r\n',
    new Object[]{
        STORE_NAME,
        CATEGORY_NAME,
        String.join(PRODUCT_NAMES,', ')
    }
);
System.debug(variables);

// Get the Product Catalog for our store
System.debug('Get the Product Catalog for the store');
String searchTerm = '%' + STORE_NAME + '%';
List<ProductCatalog> productCatalogs = [select Id, Name from ProductCatalog where Name like :searchTerm];
System.assertEquals(1, productCatalogs.size(), 'ProductCatalog issue');

// Check that the Category does not exist already by name
System.debug('Check that the Category does not exist already by name');
List<ProductCategory> productCategories = [select Id, Name from ProductCategory where Name = :CATEGORY_NAME];
System.assertEquals(0, productCategories.size(), 'ProductCategory issue');

// Create a new Product Category for Truffles
System.debug('Create a new Product Category for Truffles');
ProductCategory productCategory = new ProductCategory(Name = 'Coffee Truffles', CatalogId = productCatalogs[0].Id);
insert productCategory;

// Create Products records
System.debug('Create Product records');
List<Product2> products = new List<Product2>();

for (String truffleName : PRODUCT_NAMES) {
    products.Add(new Product2(Name = truffleName));
}

insert products;

// Populate the Product Category Product junction object (ProductCategoryProduct) with the products and their new category
System.debug('Populate the Product Category Product junction object (ProductCategoryProduct) with the products and their new category');
List<ProductCategoryProduct> pcps = new List<ProductCategoryProduct>();

for(Product2 product: products)
{
    pcps.add(new ProductCategoryProduct(ProductCategoryId = productCategory.Id, ProductId = product.Id));
}

insert pcps;
System.debug(SCRIPT_NAME + ' script complete.');