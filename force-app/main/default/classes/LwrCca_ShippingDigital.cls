/**
 * @description       : This sample is for the situations where Digital Shipping is required, meaning there is no shipping cost.
 *                      This class must extend the CartExtension.ShippingCartCalculator class to be processed.
 *
 *                      Main documentation source: https://developer.salesforce.com/docs/commerce/salesforce-commerce/guide/ShippingCartCalculator.html
 *
 * @author            : Tom Zarr and Shane Smyth
 * @group             : Salesforce Commerce Partner Delivery Success (2024) and Saltbox Management
 * @last modified on  : 03-19-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingDigital extends CartExtension.ShippingCartCalculator
{

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

    public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request)
    {
        System.debug('## INVOCATION: LwrCca_ShippingDigital.calculate called.');
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
            List<Product2> shippingProducts = [
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
            String shippingProduct = Id.valueOf(shippingProducts[0].Id);

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