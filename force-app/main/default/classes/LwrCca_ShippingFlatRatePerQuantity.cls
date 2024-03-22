/**
 * @description       : This code is a teaching example current with the Spring '24 release meant to provide a flat shipping rate which is multiplied
 *                      against the number of items in the cart. This class is current with the Spring '24 release and a part of the
 *                      Salesforce Partner Learning Camp course "B2B Commerce: Developer Essentials" and specific to these activities:
 *                          1. Implement a Shipping Provider
 *                          2. Configure a Cart Orchestrator
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingFlatRatePerQuantity extends CartExtension.ShippingCartCalculator
{
    /** The per item cart cost which will be multiplied by the number of items in the cart */
    public final static Decimal SHIPPING_COST_PER_ITEM = 7.00;

    /**
     * The  moniker for the shipping Shipping Product Placeholder represented in ProductCode. In a real implementation you'd typically have
     * one product, but multiple order delivery groups that are different. Then the price is whatever is calculated in checkout (price from
     * the product isn't a factor).
     */
    public static final String SHIPPING_PRODUCT_MONIKER = 'Shipping Product Placeholder';

    /**
     * The product for shipping represented in ProductCode.
     */
    public static final String SHIPPING_PRODUCT_CODE = SHIPPING_PRODUCT_MONIKER;

    /**
     * The product for shipping represented in the SKU.
     */
    public static final String SHIPPING_PRODUCT_STOCK_KEEPING_UNIT = SHIPPING_PRODUCT_MONIKER;

    /**
     * The product for shipping represented in the Name.
     */
    public static final String SHIPPING_PRODUCT_NAME = SHIPPING_PRODUCT_MONIKER;

    /** Statically initialized colection of  SHIPPING_PRODUCTS */
    public static final List<Product2> SHIPPING_PRODUCTS;

    private RestUtilityForQuery restUtilityForQuery;

    /**
     * In theory this should provide a singleton-ish approxmiation so we're checking for valid data while not
     * pummeling the data tier repeatedly. The class should die immediately if the expected shipping
     * product isn't located.
     */
    static
    {
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

            if(SHIPPING_PRODUCTS.size() == 0) {
                throw new NoShippingProductPlaceholderException();
            }
        }
    }

    public LwrCca_ShippingFlatRatePerQuantity()
    {
        restUtilityForQuery = new RestUtilityForQuery();
    }

    /**
     * Given a number of items in the cart, multiply them against a flat rate such as SHIPPING_COST_PER_ITEM per item
     * and apply the result as a consolidated shipping charge.
     */
    public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request)
    {
        System.debug('## INVOCATION: LwrCca_ShippingFlatRatePerQuantity.calculate called.');
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
            System.debug('## EMPTY CART: LwrCca_ShippingFlatRatePerQuantity.calculate');
            CartExtension.CartValidationOutput cvo = new CartExtension.CartValidationOutput(
                CartExtension.CartValidationOutputTypeEnum.SHIPPING,
                CartExtension.CartValidationOutputLevelEnum.ERROR);
            cvo.setMessage('No Cart Delivery Groups have been defined');
            cartValidationOutputCollection.add(cvo);
        }
        else
        {
            System.debug('## POPULATED CART: LwrCca_ShippingFlatRatePerQuantity.calculate');
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
             *      Decimal shippingTotal = cartItems.size() * SHIPPING_COST_PER_ITEM;
             * ...that's going to come out to 7.00 when they have 2 or event 10 or 100 of the same line item and you should look at
             * other options within the product for doing deep discounts over waiving such a large shipping fee. For demonstration
             * purposes we introduce the Boolean giveAwayTheFarm so you can see the difference.
             */

            Decimal runningShippingTotal = 0.00;
            Boolean giveAwayTheFarm = false;

            if(giveAwayTheFarm)
            {
                runningShippingTotal = cartItems.size() * SHIPPING_COST_PER_ITEM;
            }
            else
            {
                Iterator<CartExtension.CartItem> cartItemsCollectionIterator = cartItems.iterator();

                while (cartItemsCollectionIterator.hasNext())
                {
                    CartExtension.CartItem cartItem = cartItemsCollectionIterator.next();
                    Decimal perLineItemWithQtyShipping = cartItem.getQuantity() * SHIPPING_COST_PER_ITEM;
                    runningShippingTotal += perLineItemWithQtyShipping;
                }
            }

            CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod01 = new CartExtension.CartDeliveryGroupMethod('Per Item Shipping', runningShippingTotal, shippingProduct);
            cartDeliveryGroupMethod01.setCarrier('USPS');
            cartDeliveryGroupMethod01.setClassOfService('Per Item Shipping');
            cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod01);

            // Set the delivery method ID that will be used for the order summary
            cartDeliveryGroup.setDeliveryMethodId(cartDeliveryGroupMethod01.getId());
        }

        System.debug('## SUCCESS: LwrCca_ShippingDigital.calculate');
    }
}