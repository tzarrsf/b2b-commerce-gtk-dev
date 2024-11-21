/**
 * @description       : This code... [Fill in the rest!]
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-26-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class LwrCca_TaxMetaData
{
    public LwrCca_TaxMetaData()
    {

    }

    public ID id { get; set; }
    public String requestJSON { get; set; }
    public String providerImplClass { get; set; }
    public String companyCode { get; set; }
    public String customerCode { get; set; }
    public String shipFromLine1 { get; set; }
    public String shipFromLine2 { get; set; }
    public String shipFromCity { get; set; }
    public String shipFromState { get; set; }
    public String shipFromCountry { get; set; }
    public String shipFromZipCode { get; set; }
    public String defaultShippingTaxCode { get; set; }
    public String defaultProductTaxCode { get; set; }
    public Boolean useProductTaxCodes { get; set; }
    public Boolean productTaxExemption { get; set; }
    public Boolean customerTaxExemption { get; set; }
    public Boolean isCommit { get; set; }
    public String taxationPolicy { get; set; }
    public String transactionType { get; set; }
    public String documentType { get; set; }
    public Boolean shippingItemsTaxable { get; set; }
    public String endPoint { get; set; }
    public String httpMethod { get; set; }
    public String mockedResponse { get; set; }
    public String serviceMode { get; set; }
    public String serviceTimeout { get; set; }
    public String serviceImplClass { get; set; }
    public String namedCredentials { get; set; }
    private Map<String, Object> additionalMetaData = new Map<String, Object>();

    public Object getMetaData(String key)
    {
        return additionalMetaData.get(key);
    }

    public void addMetaData(String key, Object value)
    {
        additionalMetaData.put(key, value);
    }
}