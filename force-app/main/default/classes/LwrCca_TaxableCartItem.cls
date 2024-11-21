/**
 * @description       : Data transport / Anemic object representing a line item in the Cart which is taxable.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-25-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class LwrCca_TaxableCartItem
{
    public LwrCca_TaxableCartItem() {

    }

    public String id { get; set; }
    public Decimal amount { get; set; }
    public Decimal quantity { get; set; }
    public String sku { get; set; }
    public String lineItemType { get; set; }
    public String taxClassId { get; set; }
    public String productExemptionCode { get; set; }
    public String entityUseCode { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String postalCode { get; set; }
    public String country { get; set;}
    public List<LwrCca_LineItemTaxDetails> lineItemTexas = new List<LwrCca_LineItemTaxDetails>();
}