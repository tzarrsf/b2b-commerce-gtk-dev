/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 12-14-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class LwrCca_ShippingProviderResponse {
  public LwrCca_ShippingProviderResponse() {
  }


  public String serviceCode { get; set; }
  public String carrier { get; set; }
  public String classOfService { get; set; }
  public Decimal cost { get; set; }
  public String shipDate { get; set; }
  public String shipTime { get; set; }
  public Integer days { get; set; }
  public Integer displayOrder { get; set; }
  private Map<String, Object> additionalData = new Map<String, Object>();

  public Object getData(String key) {
    return additionalData.get(key);
  }

  public void addData(String key, Object value) {
    additionalData.put(key, value);
  }

}