/**
 * @description       : This code is a teaching example current with the Spring '24 release meant to provide a flat shipping rate which is multiplied
 *                      against the number of items in the cart. This script is part of the Salesforce Partner Learning Camp Curriculum "B2B Commerce:
 *                      Developer Essentials" activity "Configure a Cart Orchestrator."
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-18-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingFlatRatePerQuantity extends CartExtension.ShippingCartCalculator
{
    public final static Decimal SHIPPING_COST_PER_ITEM = 2.00;
    private RestUtilityForQuery restUtilityForQuery;

    public LwrCca_ShippingFlatRatePerQuantity()
    {
        restUtilityForQuery = new RestUtilityForQuery();
    }

    /**
     * Given a number of items in the cart, multiply them against a flat rate such as 2.00 per item
     * and apply the result as a shipping charge.
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

        if (cartDeliveryGroups.size() == 0) {
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
            Integer numberOfUniqueItems = cartItems.size();
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

            // TODO: Verify a shipping rate product i present
            List<Product2> shippingProducts = [SELECT Id FROM Product2 WHERE ProductClass != 'VariationParent' AND StockKeepingUnit = 'Ship1' LIMIT 1];
            String shippingProduct = Id.valueOf(shippingProducts[0].Id);

            //TODO: Multiply this out
            CartExtension.CartDeliveryGroupMethod cartDeliveryGroupMethod01 = new CartExtension.CartDeliveryGroupMethod('No Shipping', 0.00, shippingProduct);
            cartDeliveryGroupMethod01.setCarrier('USPS');
            cartDeliveryGroupMethod01.setClassOfService('Digital Shipping');
            cartDeliveryGroupMethodCollection.add(cartDeliveryGroupMethod01);

            // Set the delivery method ID that will be used for the order summary
            cartDeliveryGroup.setDeliveryMethodId(cartDeliveryGroupMethod01.getId());
        }

        System.debug('## SUCCESS: LwrCca_ShippingDigital.calculate');
    }
}