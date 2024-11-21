/**
 * @description       : Data transport / Anemic object representing line item details for the LwrCca_TaxableCartItem class.
 * @author            : Code-It-Forward team members (main contributors) and Tom Zarr (content adaptation and editing for course)
 *                      To find out more about Code-It-Forward please consult these links:
 *                      https://sfdc.co/CodeItForwardCharter
 *                      https://sfdc.co/CodeItForwardRepository
 *                      https://sfdc.co/CodeItForwardRegistration
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 07-25-2024
 * @last modified by  : Tom Zarr
**/
public without sharing class LwrCca_LineItemTaxDetails
{
    public LwrCca_LineItemTaxDetails() {}

    public  Decimal rate  { get; set; }
    public  Decimal tax  { get; set; }
    public String taxName { get; set; }
    public String taxType { get; set; }
}