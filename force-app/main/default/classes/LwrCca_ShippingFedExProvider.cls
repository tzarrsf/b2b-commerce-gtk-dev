/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-15-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingFedExProvider extends LwrCca_AbstractShippingProvider {
  public LwrCca_ShippingFedExProvider() {
  }
  public override void prepareRequestBody(LwrCca_ShippingProviderRequest shippingRequest,Map<String, String> callOutRequest) {
    LwrCca_ShippingFedExRateRequest requestObject = LwrCca_ShippingFedExRateRequest.parse(
      shippingRequest.shippingMetaData.requestJSON
    );
    if (requestObject != null) {
      requestObject.requestedShipment.recipient.address = setShipToAddress(
        shippingRequest
      );
      LwrCca_ShippingFedExRateRequest.RequestedPackageLineItems packageLItem = requestObject.requestedShipment.requestedPackageLineItems.get(
        0
      );
      LwrCca_ShippingFedExRateRequest.Weight weight = new LwrCca_ShippingFedExRateRequest.Weight();
      packageLItem.weight.value = shippingRequest.packageWeight;

      String strRatingRequestBody = JSON.serialize(requestObject, true);
      callOutRequest.put(Constants.SERVICE_REQUEST_BODY, strRatingRequestBody);
    }
  }

  public virtual LwrCca_ShippingFedExRateRequest.Address setShipToAddress(
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    LwrCca_ShippingFedExRateRequest.Address address = new LwrCca_ShippingFedExRateRequest.Address();
    address.postalCode = shippingRequest.postalCode;
    address.countryCode = shippingRequest.country;
    return address;
  }

  public override Map<String, LwrCca_ShippingProviderResponse> getShippingOptionsFromResponse(
    List<String> responseList,
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    Map<String, Object> shippingMethods = new Map<String, Object>();
    Map<String, LwrCca_ShippingProviderResponse> shippingMethodsWithRate = parseFedExShippingResponse(
      responseList,
      shippingRequest
    );
    return shippingMethodsWithRate;
  }

  public virtual Map<String, LwrCca_ShippingProviderResponse> parseFedExShippingResponse(
    List<String> lstFedExResponseBody,
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    Map<String, LwrCca_ShippingProviderResponse> shippingMethodsWithRate = new Map<String, LwrCca_ShippingProviderResponse>();
    LwrCca_ShippingProviderResponse shippingResponse;
    if (lstFedExResponseBody != null && lstFedExResponseBody.size() > 0) {
      for (String strFedExResponseBody : lstFedExResponseBody) {
        LwrCca_ShippingFedExRateResponse fedexShippingRateResponseObj = LwrCca_ShippingFedExRateResponse.parse(
          strFedExResponseBody
        );
        LwrCca_ShippingFedExRateResponse.Output LwrCca_ShippingFedExRateResponse = fedexShippingRateResponseObj.output;
        for (
          LwrCca_ShippingFedExRateResponse.RateReplyDetails shipmentObj : LwrCca_ShippingFedExRateResponse.rateReplyDetails
        ) {
          Decimal shippingAmount = shipmentObj.ratedShipmentDetails[0]
              .totalNetCharge != null
            ? Decimal.valueOf(
                shipmentObj.ratedShipmentDetails[0].totalNetCharge
              )
            : 0;
          if (
            shippingMethodsWithRate.containsKey(
              shipmentObj.operationalDetail.serviceCode
            )
          ) {
            shippingResponse = shippingMethodsWithRate.get(
              shipmentObj.operationalDetail.serviceCode
            );
            shippingResponse.cost = shippingResponse.cost + shippingAmount;
          } else {
            shippingResponse = new LwrCca_ShippingProviderResponse();
            shippingResponse.serviceCode = shipmentObj.operationalDetail.serviceCode;
            shippingResponse.cost = shippingAmount;
            shippingResponse.carrier = shippingRequest.shippingMetaData.carrier;
            shippingResponse.displayOrder = shippingRequest.shippingMetaData.displayOrder;
            shippingMethodsWithRate.put(
              shipmentObj.operationalDetail.serviceCode,
              shippingResponse
            );
          }
        }
      }
    }
    return shippingMethodsWithRate;
  }
}