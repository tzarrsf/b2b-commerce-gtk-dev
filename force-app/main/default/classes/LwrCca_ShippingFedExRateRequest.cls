/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-14-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingFedExRateRequest {
  public AccountNumber accountNumber;
  public RequestedShipment requestedShipment;

  public class Address {
    public String postalCode;
    public String countryCode;
  }

  public class Shipper {
    public Address address;
  }

  public class RequestedPackageLineItems {
    public Weight weight;
  }

  public class RequestedShipment {
    public Shipper shipper;
    public Shipper recipient;
    public String pickupType;
    public List<String> rateRequestType;
    public List<RequestedPackageLineItems> requestedPackageLineItems;
  }

  public class Weight {
    public String units;
    public Decimal value;
  }

  public class AccountNumber {
    public String value;
  }

  public static LwrCca_ShippingFedExRateRequest parse(String json) {
    return (LwrCca_ShippingFedExRateRequest) System.JSON.deserialize(
      json,
      LwrCca_ShippingFedExRateRequest.class
    );
  }
}