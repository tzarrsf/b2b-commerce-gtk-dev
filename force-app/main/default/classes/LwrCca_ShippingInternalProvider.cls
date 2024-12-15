/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-15-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingInternalProvider extends LwrCca_AbstractShippingProvider {
  public LwrCca_ShippingInternalProvider() {
  }
  public override Map<String, LwrCca_ShippingProviderResponse> retrieveShippingRates(
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    List<String> responseList = new List<String>();
    Map<String, LwrCca_ShippingProviderResponse> shippingMethodsWithRate = new Map<String, LwrCca_ShippingProviderResponse>();
    Decimal totalCartWeight = 0;
    try {
      List<Decimal> lstShippingWeight = calculateCartWeight(shippingRequest);
      for (Decimal weight : lstShippingWeight) {
        totalCartWeight += weight;
      }
      shippingRequest.packageWeight = totalCartWeight;
      shippingMethodsWithRate = getShippingOptionsFromResponse(
        responseList,
        shippingRequest
      );
    } catch (Exception expObj) {
      System.debug(
        'Exception due to error ====' +
          expObj.getMessage() +
          'at Line Number ====' +
          expObj.getLineNumber()
      );
      // WK_Exception.log(expObj, applicationName, moduleName, className,
      // methodName, supportData);
    }
    return shippingMethodsWithRate;
  }

  public override Map<String, LwrCca_ShippingProviderResponse> getShippingOptionsFromResponse(
    List<String> responseList,
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    Map<String, LwrCca_ShippingProviderResponse> shippingMethodsWithRate = new Map<String, LwrCca_ShippingProviderResponse>();
    List<Internal_Shipping_Rate__mdt> shippingRates = [
      SELECT
        Id,
        Name__c,
        Rate__c,
        Cart_Max_Price__c,
        Cart_Max_Weight__c,
        Cart_Min_Price__c,
        Cart_Min_Weight__c,
        Shipping_Provider__c
      FROM Internal_Shipping_Rate__mdt
      WHERE Shipping_Provider__c = :shippingRequest.shippingMetaData.id AND Is_Active__c = true 
    ];
    LwrCca_ShippingProviderResponse shippingResponse;
    if (shippingRates != null && shippingRates.size() > 0) {
      for (Internal_Shipping_Rate__mdt rate : shippingRates) {
        shippingResponse = new LwrCca_ShippingProviderResponse();
        shippingResponse.serviceCode = rate.Name__c;
        shippingResponse.cost = rate.Rate__c;
        shippingResponse.carrier = shippingRequest.shippingMetaData.carrier;
        shippingResponse.displayOrder = shippingRequest.shippingMetaData.displayOrder;
        shippingMethodsWithRate.put(
          shippingResponse.serviceCode,
          shippingResponse
        );
      }
    }
    return shippingMethodsWithRate;
  }
  public override void prepareRequestBody(
    LwrCca_ShippingProviderRequest shippingRequest,
    Map<String, String> callOutRequest
  ) {
  }
}