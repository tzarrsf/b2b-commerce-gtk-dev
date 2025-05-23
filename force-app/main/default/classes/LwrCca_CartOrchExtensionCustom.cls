/**
 * @description       : This code needs to be compared to the LwrCca_CartOrchestrator class and consolidated
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-26-2024
 * @last modified by  : Tom Zarr
**/
global class LwrCca_CartOrchExtensionCustom extends CartExtension.CartCalculate {
    /**
     * @description All classes extending CartExtension.CartCalculate must have a default constructor defined
     */
    // TODO: Compare this to the LwrCca_CartOrchestrator class and consolidate
    global LwrCca_CartOrchExtensionCustom() {}
  
    /**
     * @description Constructor used by unit tests only. See <<CartCalculationOrchestratorExtensionUnitTest>>.
     * @param apexExecutor Executor which executes various calculators. Can be used to stub calculation results or delegate calculations to actual Calculator. See <<CartCalculateExecutorMock>>.
     */
    global LwrCca_CartOrchExtensionCustom(final CartExtension.CartCalculateExecutorMock apexExecutor) {
      // Must call super constructor in order for provided Executor to be used for calculations
      super(apexExecutor);
    }
  
    // Each orchestrator must override this calculate method.
    global virtual override void calculate(CartExtension.CartCalculateOrchestratorRequest request) {
      CartExtension.Cart cart = request.getCart();
  
      // Use BuyerActions to decide which calculators to invoke
      CartExtension.BuyerActions buyerActions = request.getBuyerActions();
      boolean runPricing =buyerActions.isCheckoutStarted() || buyerActions.isCartItemChanged();
      boolean runPromotions = buyerActions.isCheckoutStarted() ||buyerActions.isCouponChanged() ||buyerActions.isCartItemChanged();
      boolean runInventory = buyerActions.isCheckoutStarted();
      boolean runShipping = buyerActions.isDeliveryGroupChanged();
      boolean runPostShipping =buyerActions.isDeliveryGroupChanged() ||buyerActions.isDeliveryMethodSelected();
      boolean runTaxes = buyerActions.isDeliveryGroupChanged() ||buyerActions.isDeliveryMethodSelected();
      System.debug('runPricing'+ runPricing);
      System.debug('runPromotions'+ runPromotions);
      System.debug('runInventory'+ runInventory);
      System.debug('runShipping'+ runShipping);
      System.debug('runTaxes'+ runTaxes);
  
      // OptionalBuyerActionDetails can be used to optimize the various calculators that are invoked
      CartExtension.CartCalculateCalculatorRequest calculatorRequest = new CartExtension.CartCalculateCalculatorRequest(cart,request.getOptionalBuyerActionDetails());
  
      if (runPricing) {
        prices(calculatorRequest);
        if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),CartExtension.CartValidationOutputTypeEnum.PRICING)) {
          return;
        }
      }
  
      if (runPromotions) {
       promotions(calculatorRequest);
        if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),  CartExtension.CartValidationOutputTypeEnum.PROMOTIONS) ) {
          return;
        }
      }
  
      if (runInventory) {
        inventory(calculatorRequest);
        if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),CartExtension.CartValidationOutputTypeEnum.INVENTORY)) {
          return;
        }
      }
  
      if (runShipping) {
        shipping(calculatorRequest);
        if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),CartExtension.CartValidationOutputTypeEnum.SHIPPING)) {
          return;
        }
      }
  
      if (runPostShipping) {
        postShipping(calculatorRequest);
        if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),CartExtension.CartValidationOutputTypeEnum.SYSTEM_ERROR
          )
        ) {
          return;
        }
      }
  
      if (runTaxes) {
        taxes(calculatorRequest);
      }
    }
  
    // This function evaluates whether there are errors in the CVO of a specific calculator type.
    private Boolean hasErrorLevelCartValidationOutput(CartExtension.CartValidationOutputList cartValidationOutputs,CartExtension.CartValidationOutputTypeEnum cartValidationOutputType) {
      Iterator<CartExtension.CartValidationOutput> iterator = cartValidationOutputs.iterator();
  
      while (iterator.hasNext()) {
        CartExtension.CartValidationOutput cvo = iterator.next();
  
        Boolean cvoContainsCalculatorError =
          cvo.getType() == cartValidationOutputType &&
          cvo.getLevel() == CartExtension.CartValidationOutputLevelEnum.ERROR;
  
        if (cvoContainsCalculatorError) {
          return true;
        }
      }
  
      return false;
    }
  }