/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-15-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingUpsProvider extends LwrCca_AbstractShippingProvider {
  public LwrCca_ShippingUpsProvider() {
  }
  public virtual override void prepareRequestBody(
    LwrCca_ShippingProviderRequest shippingRequest,
    Map<String, String> callOutRequest
  ) {
    LwrCca_ShippingUpsRateRequest requestObject = LwrCca_ShippingUpsRateRequest.parse(
      shippingRequest.shippingMetaData.requestJSON
    );
    if (requestObject != null) {
      requestObject.RateRequest.Shipment.Shipper.ShipperNumber = shippingRequest.shippingMetaData.accountNumber;
      requestObject.RateRequest.Shipment.ShipTo = setShipToAddress(
        shippingRequest
      );
      requestObject.RateRequest.Shipment.Package_Z[0]
        .PackageWeight.Weight = String.valueOf(shippingRequest.packageWeight);
      String strRatingRequestBody = JSON.serialize(requestObject, true);
      strRatingRequestBody = strRatingRequestBody.replaceAll(
          'Package_Z',
          'Package'
        )
        .replaceAll('Date_Z', 'Date')
        .replaceAll('Time_Z', 'Time');

      callOutRequest.put(Constants.SERVICE_REQUEST_BODY, strRatingRequestBody);
    }
  }

  public virtual LwrCca_ShippingUpsRateRequest.ShipTo setShipToAddress(
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    LwrCca_ShippingUpsRateRequest.Address address = new LwrCca_ShippingUpsRateRequest.Address();
    address.AddressLine = new List<String>();
    address.AddressLine.add(shippingRequest.street);
    address.City = shippingRequest.city;
    address.StateProvinceCode = shippingRequest.state;
    address.PostalCode = shippingRequest.postalCode;
    address.CountryCode = shippingRequest.country;
    LwrCca_ShippingUpsRateRequest.ShipTo shipTo = new LwrCca_ShippingUpsRateRequest.ShipTo();
    shipTo.Address = address;
    return shipTo;
  }

  public virtual override Map<String, LwrCca_ShippingProviderResponse> getShippingOptionsFromResponse(
    List<String> responseList,
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    Map<String, Object> shippingMethods = new Map<String, Object>();
    Map<String, LwrCca_ShippingProviderResponse> shippingMethodsWithRate = parseUPSShippingResponse(
      responseList,
      shippingRequest
    );
    return shippingMethodsWithRate;
  }

  public virtual Map<String, LwrCca_ShippingProviderResponse> parseUPSShippingResponse(
    List<String> lstUPSResponseBody,
    LwrCca_ShippingProviderRequest shippingRequest
  ) {
    Map<String, LwrCca_ShippingProviderResponse> shippingMethodsWithRate = new Map<String, LwrCca_ShippingProviderResponse>();
    LwrCca_ShippingProviderResponse shippingResponse;
    if (lstUPSResponseBody != null && lstUPSResponseBody.size() > 0) {
      for (String strUPSResponseBody : lstUPSResponseBody) {
        LwrCca_ShippingUpsShippingRateResponse upsShippingRateResponseObj = LwrCca_ShippingUpsShippingRateResponse.parse(
          strUPSResponseBody
        );
        LwrCca_ShippingUpsShippingRateResponse.RateResponse upsShippingRateResponse = upsShippingRateResponseObj.RateResponse;
        for (
          LwrCca_ShippingUpsShippingRateResponse.RatedShipment shipmentObj : upsShippingRateResponse.RatedShipment
        ) {
          Decimal shippingAmount = shipmentObj.TotalCharges.MonetaryValue !=
            null
            ? Decimal.valueOf(shipmentObj.TotalCharges.MonetaryValue)
            : 0;
          if (shippingMethodsWithRate.containsKey(shipmentObj.Service.Code)) {
            shippingResponse = shippingMethodsWithRate.get(
              shipmentObj.Service.Code
            );
            shippingResponse.cost = shippingResponse.cost + shippingAmount;
          } else {
            shippingResponse = new LwrCca_ShippingProviderResponse();
            shippingResponse.serviceCode = shipmentObj.Service.Code;
            shippingResponse.cost = shippingAmount;
            shippingResponse.carrier = shippingRequest.shippingMetaData.carrier;
            shippingResponse.displayOrder = shippingRequest.shippingMetaData.displayOrder;
            shippingMethodsWithRate.put(
              shipmentObj.Service.Code,
              shippingResponse
            );
          }
        }
      }
    }
    return shippingMethodsWithRate;
  }
}