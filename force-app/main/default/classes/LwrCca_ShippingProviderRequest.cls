/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 01-31-2025
 * @last modified by  : Tom Zarr
**/
public with sharing class LwrCca_ShippingProviderRequest {
  public LwrCca_ShippingProviderRequest() {
  }

  public String street { get; set; }
  public String city { get; set; }
  public String state { get; set; }
  public String postalCode { get; set; }
  public String country { get; set; }
  public String cartId { get; set; }
  public Decimal packageWeight { get; set; }
  public LwrCca_ShippingMetaData shippingMetaData { get; set; }

  private Map<String, Object> additionalData = new Map<String, Object>();

  public Object getData(String key) {
    return additionalData.get(key);
  }

  public void addData(String key, Object value) {
    additionalData.put(key, value);
  }
}