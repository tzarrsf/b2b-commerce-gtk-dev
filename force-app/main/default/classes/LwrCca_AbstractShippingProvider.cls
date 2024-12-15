/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-15-2024
 * @last modified by  : Tom Zarr
**/
public abstract class LwrCca_AbstractShippingProvider {
  // Calculate Product Weight here -
  // The maximum per package weight for the selected service from the selected
  // country or territory is 150.00 pounds.
  public virtual List<Decimal> calculateCartWeight(LwrCca_ShippingProviderRequest shippingRequest) {
    Decimal shippingMaxWeight = 150; // weight in lbs
    Decimal shippingMinWeight = 5; // weight in lbs
    Decimal productWeight = 0;
    String cartId = shippingRequest.cartId;
    if (shippingRequest.shippingMetaData.maxPackageWeight != null) {
      shippingMaxWeight = shippingRequest.shippingMetaData.maxPackageWeight;
    }
    if (shippingRequest.shippingMetaData.minPackageWeight != null) {
      shippingMinWeight = shippingRequest.shippingMetaData.minPackageWeight;
    }

    List<CartItem> lstCartItems = [
      SELECT
        Product2Id,
        Product2.Weight__c,
        Name,
        Id,
        CartId,
        Type,
        Sku,
        Quantity,
        ListPrice,
        SalesPrice,
        TotalListPrice
      FROM CartItem
      WHERE CartId = :cartId AND Type = 'Product'
    ];

    for (CartItem cartItem : lstCartItems) {
      productWeight +=
        cartItem.Quantity * Decimal.ValueOf(cartItem.Product2.Weight__c);
    }
    List<Decimal> lstShippingWeight = new List<Decimal>();
    while (productWeight > shippingMaxWeight) {
      productWeight = productWeight - shippingMaxWeight;
      lstShippingWeight.add(shippingMaxWeight);
    }
    if (productWeight < shippingMinWeight) {
      productWeight = 5;
    }
    lstShippingWeight.add(productWeight);
    return lstShippingWeight;
  }

  public virtual Map<String, String> prepareNamedCredentials(LwrCca_ShippingProviderRequest shippingRequest) {
    Map<String, String> callOutRequest = new Map<String, String>();
    String endPoint =
      Constants.CALLOUT +
      shippingRequest.shippingMetaData.namedCredentials +
      shippingRequest.shippingMetaData.endPoint;
    callOutRequest.put(Constants.END_POINT, endPoint);
    // callOutRequest.put(Constants.USERNAME , Constants.CREDENNTIALS_USERNAME);
    // callOutRequest.put(Constants.PASSWORD , Constants.CREDENNTIALS_PASSWORD);
    return callOutRequest;
  }

  public virtual Map<String, String> setServiceDetails(
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    Map<String, String> serviceDetails = new Map<String, String>();
    serviceDetails.put(
      Constants.HTTP_METHOD,
      shippingRequest.shippingMetaData.httpMethod
    );
    serviceDetails.put(
      Constants.SERVICE_TIMEOUT,
      shippingRequest.shippingMetaData.serviceTimeout
    );
    serviceDetails.put(
      Constants.SERVICE_MODE,
      shippingRequest.shippingMetaData.serviceMode
    );
    serviceDetails.put(
      Constants.MOCKED_RESPONSE,
      shippingRequest.shippingMetaData.mockedResponse
    );
    return serviceDetails;
  }

  public virtual Map<String, String> setRequestHeaders(LwrCca_ShippingProviderRequest shippingRequest) {
    Map<String, String> htttpRequestDetails = new Map<String, String>();
    return htttpRequestDetails;
  }
  public virtual Map<String, String> prepareCallOutRequest(
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    Map<String, String> callOutRequest = new Map<String, String>();
    callOutRequest.putAll(prepareNamedCredentials(shippingRequest));
    callOutRequest.putAll(setServiceDetails(shippingRequest));
    prepareRequestBody(shippingRequest, callOutRequest);
    return callOutRequest;
  }

  public virtual Map<String, LwrCca_ShippingProviderResponse> retrieveShippingRates(
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    List<String> responseList = new List<String>();
    Map<String, LwrCca_ShippingProviderResponse> shippingMethodsWithRate = new Map<String, LwrCca_ShippingProviderResponse>();
    Map<String, String> responseMap;
    Boolean calloutSuccess = true;
    try {
      List<Decimal> lstShippingWeight = calculateCartWeight(shippingRequest);
      for (Integer i = (lstShippingWeight.size() - 1); i >= 0; i--) {
        shippingRequest.packageWeight = lstShippingWeight.get(i);

        Map<String, String> callOutRequest = prepareCallOutRequest(
          shippingRequest
        );
        responseMap = ServiceFactory.getService(
            shippingRequest.shippingMetaData.serviceImplClass
          )
          .makeExternalCallout(
            callOutRequest,
            setRequestHeaders(shippingRequest)
          );
        if (
          !'200'.equals(responseMap.get(Constants.RESPONSE_REASON_CODE)) ||
          responseMap.isEmpty()
        ) {
          calloutSuccess = false;
          break;
        }
        responseList.add(responseMap.get(Constants.SERVICE_RESPONSE_BODY));
      }
      if (calloutSuccess) {
        shippingMethodsWithRate = getShippingOptionsFromResponse(
          responseList,
          shippingRequest
        );
      }
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
  public abstract Map<String, LwrCca_ShippingProviderResponse> getShippingOptionsFromResponse( List<String> responseList,LwrCca_ShippingProviderRequest shippingRequest);
  public abstract void prepareRequestBody(
    LwrCca_ShippingProviderRequest shippingRequest,
    Map<String, String> callOutRequest
  );
}