System.debug('Coffee Truffle script started...');
//Get the catalog for our store
ProductCatalog cat = [select Id, Name from ProductCatalog where Name like '%Capricorn B2B%'];

//Create a new category for Truffles!
System.debug('Create a new category for Truffles!');
ProductCategory pc = new ProductCategory(Name = 'Coffee Truffles', CatalogId = cat.Id);
insert pc;

//Make some new products
System.debug('Make some new products');
List<Product2> prods = new List<Product2>
{
    new Product2(Name = 'Salted Caramel Coffee Truffle'),
    new Product2(Name = 'Black Cherry Coffee Truffle'),
    new Product2(Name = 'Raspberry Coffee Truffle'),
    new Product2(Name = 'Orange Coffee Truffle'),
    new Product2(Name = 'Hazelnut Coffee Truffle')
};
insert prods;

//Populate the junction object (ProductCategoryProduct) with the products and their new category
System.debug('Populate the junction object (ProductCategoryProduct) with the products and their new category');
List<ProductCategoryProduct> pcps = new List<ProductCategoryProduct>();
for(Product2 prod: prods)
{
    pcps.add(new ProductCategoryProduct(ProductCategoryId = pc.Id, ProductId = prod.Id));
}
insert pcps;
System.debug('Truffle script complete');