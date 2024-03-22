/**
 * @description       : This code is a teaching example current with the Spring '24 release meant to provide a unique flat shipping rate
 *                      for each product code. This class is current with the Spring '24 release and a part of the Salesforce Partner
 *                      Learning Camp Curriculum "B2B Commerce: Developer Essentials" and specific to these activities:
 *                          1. Implement a Shipping Provider
 *                          2. Configure a Cart Orchestrator
 *                      This class requires that you create a default cache partition. Consult the documentation for details:
 *                      https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_cache_partition_setup.htm
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-21-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingFlatRatePerProductCode extends CartExtension.ShippingCartCalculator {

    /**
    * The  moniker for the shipping Shipping Product Placeholder represented in ProductCode. In a real implementation you'd typically have
    * one product, but multiple order delivery groups that are different. Then the price is whatever is calculated in checkout (price from
    * the product isn't a factor).
    */
    public static final String SHIPPING_PRODUCT_MONIKER = 'Shipping Product Placeholder';

    /** The product for shipping represented in ProductCode. */
    public static final String SHIPPING_PRODUCT_CODE = SHIPPING_PRODUCT_MONIKER;

    /** The product for shipping represented in the SKU. */
    public static final String SHIPPING_PRODUCT_STOCK_KEEPING_UNIT = SHIPPING_PRODUCT_MONIKER;

    /** The product for shipping represented in the Name. */
    public static final String SHIPPING_PRODUCT_NAME = SHIPPING_PRODUCT_MONIKER;

    /** The fallback rate for shipping should the rate not be found in the ProductCodeShippingRate__c lookup. */
    public final static Decimal SHIPPING_COST_FALLBACK_RATE = 5.50;

    /** The methdology to use for shipping calculations */
    Enumerations.CalculationMethodology calculationMethodology = Enumerations.CalculationMethodology.ITEM;

    /** Underlying variable for the property initialized collection of SHIPPING_PRODUCTS */
    private static final List<Product2> SHIPPING_PRODUCTS;

    /** The key for storing the PRODUCT_CODE_SHIPPING_RATES in the Org-level Cache */
    private static final String PRODUCT_CODE_SHIPPING_RATES_ORG_CACHE_KEY = 'productCodeShippingRates';

    /**
     * Using a static initializer should allow us to do a single scan of our shipping product from initial deployment / first call,
     * then have it in memory to avoid pummeling the data tier. The class should die immediately if the expected shipping product
     * isn't located.
     */
    static
    {
        // Set up the Shipping Product Placeholder
        if(SHIPPING_PRODUCTS == null || SHIPPING_PRODUCTS.size() == 0)
        {
            SHIPPING_PRODUCTS = [
                SELECT
                    Id, Name, StockKeepingUnit, ProductCode
                FROM
                    Product2
                WHERE
                    ProductClass != 'VariationParent'
                    AND Name = :SHIPPING_PRODUCT_NAME
                    AND StockKeepingUnit = :SHIPPING_PRODUCT_STOCK_KEEPING_UNIT
                    AND ProductCode = :SHIPPING_PRODUCT_CODE LIMIT 1
            ];

            if(SHIPPING_PRODUCTS.size() == 0)
            {
                throw new NoShippingProductPlaceholderException();
            }
        }
    }

    /**
     * Since I used a static constructor in the other example for the shipping products and cache partition, I'll use a C#-style
     * property here for the cached product code rates. In theory, this should provide a 'singleton-ish' behavior so we're checking
     * for valid setup data while not pummeling the data tier for it. The class should die immediately if the expected object isn't
     * located. I'm not going to get all fancy doing cache invalidation, TTL, etc, but I'll check that the object is present,
     * that the map is intialized, then make an assignment if not. This approach maps well to a remote system call fetching a
     * 'skinny table.' Keep in mind this is a teaching example and a table with a massive amount of rows could lead to exceptions
     * or limits. In such a case, you could possibly batch load things into org-level cache or use categories or additional partitions
     * as an additional layer of cache keying for locating child records, then hone in on particulars.
     */
    public Map<String, Decimal> cachedRateMap
    {
        get
        {
            System.debug('## Getting Cached Rate map (cachedRateMap)... class: LwrCca_ShippingFlatRatePerProductCode');

            Map<String, Decimal> rateMap;

            try
            {
                if (Cache.Org.contains(PRODUCT_CODE_SHIPPING_RATES_ORG_CACHE_KEY))
                {
                    System.debug('## ' + PRODUCT_CODE_SHIPPING_RATES_ORG_CACHE_KEY + ' found in cache...');
                    rateMap = (Map<String, Decimal>)Cache.Org.get(PRODUCT_CODE_SHIPPING_RATES_ORG_CACHE_KEY);
                    System.debug('## Returning ' + PRODUCT_CODE_SHIPPING_RATES_ORG_CACHE_KEY + ' with ' + rateMap.keySet().size() + ' keys');
                }
            }
            catch(Exception e)
            {
                System.debug('## EXCEPTION: ' + e.getMessage());
            }

            // If null or empty push the map into org-level cache
            if(rateMap == null || rateMap.keySet().size() == 0)
            {
                System.debug('## Cached Rate map (cachedRateMap) was null or had no keys - class: LwrCca_ShippingFlatRatePerProductCode');

                List<ProductCodeShippingRate__c> productCodeShippingRates;

                productCodeShippingRates = [
                    SELECT
                        ProductCode__c,
                        Rate__c
                    FROM
                        ProductCodeShippingRate__c
                ];

                // Assuming the ProductCodeShippingRate__c exists in the org and we made it this far, create a local map
                rateMap = new Map<String, Decimal>();

                System.debug('## Adding to rateMap...' );

                for(ProductCodeShippingRate__c element : productCodeShippingRates)
                {
                    System.debug('## Adding element with ProductCode__c: ' + element.ProductCode__c + ' , Rate__c: ' + element.Rate__c);
                    rateMap.put(element.ProductCode__c, element.Rate__c);
                }

                System.debug('## Adding to rateMap complete.' );

                // Push the rateMap into Org-level cache
                try
                {
                    System.debug('## Push the rateMap on to the Org-level cache');
                    Cache.Org.put(PRODUCT_CODE_SHIPPING_RATES_ORG_CACHE_KEY, rateMap);
                }
                catch(Exception ex)
                {
                    System.debug('## EXCEPTION during cache put operation');
                    throw new NoProductCodeShippingRateObjectException();
                }
            }

            // Return from Cache
            rateMap = (Map<String, Decimal>)Cache.Org.get(PRODUCT_CODE_SHIPPING_RATES_ORG_CACHE_KEY);
            return rateMap;
        }
    }

     /**
     * Given a number of items in the cart, find their assigned shipping rate using a custom object
     * and apply the result as a consolidated shipping charge.
     */
    public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request)
    {
        System.debug('## INVOCATION: LwrCca_ShippingFlatRatePerProductCode.calculate called.');
        CartExtension.Cart cart = request.getCart();

        /***
         * Clean up CartValidationOutputList based on SHIPPING. When new shipping calculator request comes, we need to clean up
         * previous CVOs as they have been previously handled by the Cart Calculate API.
         */
        CartExtension.CartValidationOutputList cartValidationOutputCollection = cart.getCartValidationOutputs();
        Iterator<CartExtension.CartValidationOutput> cartValidationOutputCollectionIterator = cartValidationOutputCollection.iterator();

        while (cartValidationOutputCollectionIterator.hasNext())
        {
            CartExtension.CartValidationOutput cvo = cartValidationOutputCollectionIterator.next();

            if (cvo.getType() == CartExtension.CartValidationOutputTypeEnum.SHIPPING) {
                cartValidationOutputCollection.remove(cvo);
            }
        }

        // To create the Cart delivery group methods, we need to get the ID of the cart delivery group.
        CartExtension.CartDeliveryGroupList cartDeliveryGroups = cart.getCartDeliveryGroups();

        if (cartDeliveryGroups.size() == 0)
        {
            System.debug('## EMPTY CART: LwrCca_ShippingFlatRatePerProductCode.calculate');
            CartExtension.CartValidationOutput cvo = new CartExtension.CartValidationOutput(
                CartExtension.CartValidationOutputTypeEnum.SHIPPING,
                CartExtension.CartValidationOutputLevelEnum.ERROR);
            cvo.setMessage('No Cart Delivery Groups have been defined');
            cartValidationOutputCollection.add(cvo);
        }
        else
        {
            System.debug('## POPULATED CART: LwrCca_ShippingFlatRatePerProductCode.calculate');
            CartExtension.CartItemList cartItems = cart.getCartItems();
            CartExtension.CartDeliveryGroup cartDeliveryGroup = cartDeliveryGroups.get(0);

            //CartExtension.CartDeliveryGroupMethodList cartDeliveryGroupMethods = cartDeliveryGroup.getCartDeliveryGroupMethods();
            CartExtension.CartDeliveryGroupMethodList cartDeliveryGroupMethodCollection = cartDeliveryGroup.getCartDeliveryGroupMethods();
            Iterator<CartExtension.CartDeliveryGroupMethod> cartDeliveryGroupMethodCollectionIterator = cartDeliveryGroupMethodCollection.iterator();

            while (cartDeliveryGroupMethodCollectionIterator.hasNext())
            {
                CartExtension.CartDeliveryGroupMethod method = cartDeliveryGroupMethodCollectionIterator.next();
                cartDeliveryGroupMethodCollection.remove(method);
            }

            // To clear selected Cart Delivery Group Method
            cartDeliveryGroup.setSelectedCartDeliveryGroupMethod(null);

            // Get the shipping product - in this case we use SKU to find the right shipping product
            String shippingProduct = Id.valueOf(SHIPPING_PRODUCTS[0].Id);

            /**
             * Multiply the number of items (not products) in the cart by the SHIPPING_COST_PER_ITEM. There's a nuance to this.
             * To wit, cartItems.size() is the number of products so it does not take into account the quantity. While you can
             * certainly do this...
             *      Decimal shippingTotal = cartItems.size() * shippingCostByProductCode;
             * ...that's going to come out to something low when the buyer has 2 or event 20 or 200 of the same product in the
             * cart. There are other productized approaches for handling such deep discounts in the product. For demonstration
             * purposes we introduce the calculationMethodology Enumeration so you can see the difference.
             */

            Decimal runningShippingTotal = 0.00;
            Decimal shippingCostByProductCode = SHIPPING_COST_FALLBACK_RATE;
            Iterator<CartExtension.CartItem> cartItemsCollectionIterator = cartItems.iterator();

            // Get the rates from the in-memory map (org-level cache)
            System.debug('## Get the rates from the in-memory map (org-level cache) - class: LwrCca_ShippingFlatRatePerProductCode');

            switch on calculationMethodology
            {
                when PRODUCT
                {
                    while (cartItemsCollectionIterator.hasNext())
                    {
                        CartExtension.CartItem cartItem = cartItemsCollectionIterator.next();

                        try
                        {
                            // TODO: Ask product and engineering how to get the product code while iterating the cart items
                            // The getSku() call is a hack to make the deployment work for now
                            shippingCostByProductCode = cachedRateMap.get(cartItem.getSku());
                        }
                        catch(Exception ex)
                        {
                            System.debug('## Exception caught in map lookup for ProductCode: ' + cartItem.getSku() + ' in LwrCca_ShippingFlatRatePerProductCode - falling back to rate of: ' + SHIPPING_COST_FALLBACK_RATE + ' Message: ' + ex.getMessage());
                        }

                        runningShippingTotal = cartItems.size() * shippingCostByProductCode;
                    }
                }
                when ITEM
                {
                    while (cartItemsCollectionIterator.hasNext())
                    {
                        CartExtension.CartItem cartItem = cartItemsCollectionIterator.next();

                        try
                        {
                            shippingCostByProductCode = cachedRateMap.get(cartItem.getSku());
                        }
                        catch(Exception ex)
                        {
                            System.debug('## Exception caught in map lookup for ProductCode: ' + cartItem.getSku() + ' in LwrCca_ShippingFlatRatePerProductCode - falling back to rate of: ' + SHIPPING_COST_FALLBACK_RATE + ' Message: ' + ex.getMessage());
                        }

                        Decimal perLineItemWithQtyShipping = cartItem.getQuantity() * shippingCostByProductCode;
                        runningShippingTotal += perLineItemWithQtyShipping;
                    }
                }
                when else
                {
                    System.debug('## Fell into else block of switch statement in LwrCca_ShippingFlatRatePerProductCode - Nothing implemented yet for this.');
                    throw new NotImplementedException();
                }
            }

            CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod01 = new CartExtension.CartDeliveryGroupMethod('Per Product Code Shipping', runningShippingTotal, shippingProduct);
            cartDeliveryGroupMethod01.setCarrier('USPS');
            cartDeliveryGroupMethod01.setClassOfService('Per Product Code Shipping');
            cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod01);

            // Set the delivery method ID that will be used for the order summary
            cartDeliveryGroup.setDeliveryMethodId(cartDeliveryGroupMethod01.getId());
        }

        System.debug('## SUCCESS: LwrCca_ShippingDigital.calculate');
    }
}