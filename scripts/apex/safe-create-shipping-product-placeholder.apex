/**
 * @description       : This class is a current script example as of the Spring '24 release for checking that a Shipping Product Placeholder
 *                      of type Product2 exists. If it doesn't then a product will be created. This is part of the This script is part of
 *                      the Salesforce Partner Learning Camp course "B2B Commerce: Developer Essentials" activity "Configure a Cart
 *                      Orchestrator."
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/

String SHIPPING_PRODUCT_MONIKER = 'Shipping Product Placeholder';

System.debug(SHIPPING_PRODUCT_MONIKER + ' creation script started...');

// Get what's there
List<Product2> shippingProducts = [
    SELECT
    Id, Name, StockKeepingUnit, ProductCode, Description
    FROM
        Product2
    WHERE
        ProductClass != 'VariationParent'
        AND Name = :SHIPPING_PRODUCT_MONIKER
        AND StockKeepingUnit = :SHIPPING_PRODUCT_MONIKER
        AND ProductCode = :SHIPPING_PRODUCT_MONIKER
];

// Nothing found so create the product
if(shippingProducts.size() == 0)
{
    System.debug('Nothing found so create the product');
    List<Product2> shippingProductInserts = new List<Product2>();

    shippingProductInserts.add(
        new Product2(
            Name = SHIPPING_PRODUCT_MONIKER,
            StockKeepingUnit = SHIPPING_PRODUCT_MONIKER,
            ProductCode = SHIPPING_PRODUCT_MONIKER,
            Description = SHIPPING_PRODUCT_MONIKER
        )
    );

    insert shippingProductInserts;
    System.debug('Product created. The Id for the record is: ' + shippingProductInserts[0].Id);
}
else
{
    System.debug('Product on file. Nothing will be created');
}

System.debug(SHIPPING_PRODUCT_MONIKER + ' creation script complete.');