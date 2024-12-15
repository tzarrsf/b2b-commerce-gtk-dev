/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-15-2024
 * @last modified by  : Tom Zarr
**/
global with sharing class LwrCca_ShippingUpsShippingRateResponse {
  global class Response {
    global ResponseStatus ResponseStatus;
    //global List<ResponseStatus> Alert;
    global TransactionReference TransactionReference;
  }

  global class TransactionReference {
    global String CustomerContext;
  }

  global RateResponse RateResponse;

  global class ResponseStatus {
    global String Code;
    global String Description;
  }

  global class BillingWeight {
    global ResponseStatus UnitOfMeasurement;
    global String Weight;
  }

  global class GuaranteedDelivery {
    global String BusinessDaysInTransit;
  }

  global class RateResponse {
    global Response Response;
    global List<RatedShipment> RatedShipment;
  }

  global class TransportationCharges {
    global String CurrencyCode;
    global String MonetaryValue;
  }

  global class RatedPackage {
    global TransportationCharges TransportationCharges;
    global TransportationCharges ServiceOptionsCharges;
    global TransportationCharges TotalCharges;
    global String Weight;
    global BillingWeight BillingWeight;
  }

  global class GuaranteedDelivery_Z {
    global String BusinessDaysInTransit;
    global String DeliveryByTime;
  }

  global class RatedShipment {
    global ResponseStatus Service;
    //global List<ResponseStatus> RatedShipmentAlert;
    global BillingWeight BillingWeight;
    global TransportationCharges TransportationCharges;
    global TransportationCharges ServiceOptionsCharges;
    global TransportationCharges TotalCharges;
    global RatedPackage RatedPackage;
    global GuaranteedDelivery GuaranteedDelivery;
  }

  global static LwrCca_ShippingUpsShippingRateResponse parse(String json) {
    return (LwrCca_ShippingUpsShippingRateResponse) System.JSON.deserialize(
      json,
      LwrCca_ShippingUpsShippingRateResponse.class
    );
  }
}