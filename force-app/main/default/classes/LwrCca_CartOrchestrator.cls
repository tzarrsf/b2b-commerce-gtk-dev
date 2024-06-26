/**
 * @description       : This is a sample orchestrator that calls the inventory, pricing, promotions, shipping and tax calculators. This class must
 *                      extend CartExtension.CartCalculate and must be linked to the orchestrator extension point
 *                      (Commerce_Domain_Cart_Calculate). Key functionality:
 *
 *                      1. Calculates pricing and promotions for operations: Add product to cart, remove product from cart, edit cart item quantity.
 *                      2. Calculates promotions for operations: add coupon to cart, remove coupon from cart.
 *                      3. Calculates pricing, promotions, inventory for start checkout operation (without shipping address available).
 *                      4. Calculates pricing, promotions, inventory, shipping, post shipping and taxes for start checkout operation (with shipping
 *                         address available).
 *                      5. Calculates shipping, post shipping and taxes for update shipping address operation.
 *                      6. Calculates taxes for select delivery method operation.
 *
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-27-2024
 * @last modified by  : Tom Zarr
**/
global class LwrCca_CartOrchestrator extends CartExtension.CartCalculate
{
    /**
     * @description All classes extending CartExtension.CartCalculate must have a default constructor defined
     */
    global LwrCca_CartOrchestrator() { }

    /**
     * @description Constructor used by unit tests only. See <<CartCalculateSampleUnitTest>>.
     * @param apexExecutor Executor which executes various calculators. Can be used to stub calculation results or delegate calculations to actual Calculator. See <<CartCalculateExecutorMock>>.
     */
    global LwrCca_CartOrchestrator(final CartExtension.CartCalculateExecutorMock apexExecutor)
    {
        // Must call super constructor in order for provided Executor to be used for calculations
        super(apexExecutor);
    }

    // Each orchestrator must override this calculate method.
    global virtual override void calculate(CartExtension.CartCalculateOrchestratorRequest request)
    {
        System.debug('## LwrCca_CartOrchestrator.calculate(CartExtension.CartCalculateOrchestratorRequest request)');
        CartExtension.Cart cart = request.getCart();

        // Use BuyerActions to decide which calculators to invoke
        CartExtension.BuyerActions buyerActions = request.getBuyerActions();
        boolean runPricing = buyerActions.isCheckoutStarted() || buyerActions.isCartItemChanged();
        boolean runPromotions = buyerActions.isCheckoutStarted() || buyerActions.isCouponChanged() || buyerActions.isCartItemChanged();
        boolean runInventory = buyerActions.isCheckoutStarted();
        boolean runShipping = buyerActions.isDeliveryGroupChanged();
        boolean runPostShipping = buyerActions.isDeliveryGroupChanged() || buyerActions.isDeliveryMethodSelected();
        boolean runTaxes = buyerActions.isCartItemChanged() || buyerActions.isCheckoutStarted() || buyerActions.isDeliveryGroupChanged() || buyerActions.isDeliveryMethodSelected();
        //boolean runTaxes = buyerActions.isDeliveryGroupChanged() || buyerActions.isDeliveryMethodSelected();

        // OptionalBuyerActionDetails can be used to optimize the various calculators that are invoked
        CartExtension.CartCalculateCalculatorRequest calculatorRequest = new CartExtension.CartCalculateCalculatorRequest(cart, request.getOptionalBuyerActionDetails());

        if (runPricing) {
            System.debug('## runPricing was true. Calling prices(calculatorRequest)...');
            prices(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(), CartExtension.CartValidationOutputTypeEnum.PRICING)) {
                return;
            }
        }

        /**
         * Work in Progress - not used at the moment
         */
        if (runPromotions) {
            /*
            System.debug('## runPromotions was true. Calling promotions(calculatorRequest)...');
            promotions(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(), CartExtension.CartValidationOutputTypeEnum.PROMOTIONS)) {
                return;
            }
            */
        }

        if (runInventory) {
            System.debug('## runInventory was true. Calling inventory(calculatorRequest)...');
            inventory(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(), CartExtension.CartValidationOutputTypeEnum.INVENTORY)) {
                return;
            }
        }

        /**
         * This code must run even if using the native shipping feature
         */
        if (runShipping) {
            System.debug('## runShipping was true. Calling shipping(calculatorRequest)...');
            shipping(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(), CartExtension.CartValidationOutputTypeEnum.SHIPPING)) {
                return;
            }
        }

        /**
         * This code must run even if using the native shipping feature
         */
        if (runPostShipping) {
            System.debug('## runPostShipping was true. Calling postShipping(calculatorRequest)...');
            postShipping(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(), CartExtension.CartValidationOutputTypeEnum.SYSTEM_ERROR)) {
                return;
            }
        }

        /**
         * Call taxes
         */
        if (runTaxes) {
            System.debug('## runTaxes was true. Calling taxes(calculatorRequest)...');
            taxes(calculatorRequest);
        }
    }

    // This function evaluates whether there are errors in the CVO of a specific calculator type.
    private Boolean hasErrorLevelCartValidationOutput(CartExtension.CartValidationOutputList cartValidationOutputs,
                                                      CartExtension.CartValidationOutputTypeEnum cartValidationOutputType) {
        Iterator<CartExtension.CartValidationOutput> iterator = cartValidationOutputs.iterator();

        while (iterator.hasNext()) {
            CartExtension.CartValidationOutput cvo = iterator.next();

            Boolean cvoContainsCalculatorError = cvo.getType() == cartValidationOutputType
                    && cvo.getLevel() == CartExtension.CartValidationOutputLevelEnum.ERROR;

            if (cvoContainsCalculatorError) {
                return true;
            }
        }

        return false;
    }
}