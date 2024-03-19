/**
 * @description       : This code is a teaching example current with the Spring '24 release meant to provide a unique flat shipping rate
 *                      for each product code. This script is part of the Salesforce Partner Learning Camp Curriculum "B2B Commerce:
 *                      Developer Essentials" activity "Configure a Cart Orchestrator."
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-18-2024
 * @last modified by  : Tom Zarr
**/
public class LwrCca_ShippingFlatRatePerProductCode extends CartExtension.ShippingCartCalculator {

    public final static Decimal SHIPPING_COST_PER_ITEM = 2.00;
    private RestUtilityForQuery restUtilityForQuery;

    public LwrCca_ShippingFlatRatePerProductCode()
    {
        restUtilityForQuery = new RestUtilityForQuery();
    }

    public virtual override void calculate(CartExtension.CartCalculateCalculatorRequest request)
    {
        throw new NotImplementedException();
        //String soqlQuery = 'select Id, Name from Something';
        //restUtilityForQuery.executeQueryToMap(soqlQuery);
    }
}