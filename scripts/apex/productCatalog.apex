// Get the known good Product Catalog via SOQL
List<ProductCatalog> productCatalogs = [
        SELECT
            Id
            ,Name
            ,CreatedById
            ,CreatedDate
            ,CurrencyIsoCode
            ,IsDeleted
            ,LastModifiedById
            ,LastModifiedDate
            ,LastReferencedDate
            ,LastViewedDate
            ,NumberOfCategories
            ,OwnerId
            ,SystemModstamp
        FROM
            ProductCatalog
        WHERE
            Name = :TestSettings.KNOWN_GOOD_PRODUCT_CATALOG_NAME
        WITH
            SECURITY_ENFORCED
];

Assert.isNotNull(productCatalogs, 'productCatalogs is null. Create a known good ProductCatalog and check the TestSettings class.');
Assert.isFalse(productCatalogs.isEmpty(),  'productCatalogs is empty. Create a known good ProductCatalog and check the TestSettings class.');
Assert.isTrue(productCatalogs.size() == 1, 'productCatalogs does not have a single record');
System.Debug('ProductCatalog Result => ' +  productCatalogs[0].Name + ' with size ' + productCatalogs.size());