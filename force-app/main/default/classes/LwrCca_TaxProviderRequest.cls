/**
 * @description       : Data transport / Anemic object representing the required message for Rax Provider requests. Supports the
 *                      LwrCca_TaxAbstractProvider and concrete implementation descendants.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 11-20-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class LwrCca_TaxProviderRequest
{
    // TODO: Remove if possible - might be needed for serialization or something else
    public LwrCca_TaxProviderRequest() { }

    public String cartId { get; set; }
    public String orderNo { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String postalCode { get; set; }
    public String country { get; set; }
    public Boolean hasMultipleShipments { get; set; }
    public String taxTransacionType { get; set; }
    public String customerTaxId { get; set; }
    public LwrCca_TaxMetaData taxMetaData { get; set; }
    public String webStoreId { get; set; }
    public String taxTransactionId { get; set; }
    public String customerExemptionCode { get; set; }
    public String entityUseCode { get; set; }
    public String currencyCode { get; set; }
    public Map<String, LwrCca_TaxableCartItem> taxableCartItems { get; set; }

    private Map<String, Object> additionalData = new Map<String, Object>();

    public Object getData(String key) {
        return additionalData.get(key);
    }

    public void addData(String key, Object value) {
        additionalData.put(key, value);
    }
}