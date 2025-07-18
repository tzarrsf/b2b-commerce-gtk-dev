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

Assert.isNotNull(productCatalogs, 'productCatalogs is null. Create a known good ProductCatalog and check the value in the TestSettings class.');
Assert.isFalse(productCatalogs.isEmpty(),  'productCatalogs is empty. Create a known good ProductCatalog and check the value in the TestSettings class.');
Assert.isTrue(productCatalogs.size() == 1, 'productCatalogs does not have a single record');
System.Debug('ProductCatalog Result => ' +  productCatalogs[0].Name + ' with size ' + productCatalogs.size());

// Get the known good Product Category by Name and known good Product Catalog
List<ProductCategory> productCategories = [
        SELECT
            Id
            ,Name
            ,Description
            ,CatalogId
            ,ParentCategoryId
            ,CreatedById
            ,LastModifiedById
            ,CreatedDate
            ,CurrencyIsoCode
            ,IsDeleted
            ,IsNavigational
            ,LastModifiedDate
            ,LastReferencedDate
            ,LastViewedDate
            ,NumberOfProducts
            ,SortOrder
            ,SystemModstamp
        FROM
            ProductCategory
        WHERE
            Name = :TestSettings.KNOWN_GOOD_PRODUCT_CATEGORY_NAME
            AND CatalogId = :productCatalogs[0].Id
        WITH
            SECURITY_ENFORCED
];

Assert.isNotNull(productCategories, 'productCategories is null. Create a known good ProductCategory and check the TestSettings class.');
Assert.isFalse(productCategories.isEmpty(),  'productCategories is empty. Create a known good ProductCategory and check the TestSettings class.');
Assert.isTrue(productCategories.size() == 1, 'productCategories does not have a single record');
System.Debug('ProductCategory Result => ' +  productCategories[0].Name + ' with size ' + productCategories.size());