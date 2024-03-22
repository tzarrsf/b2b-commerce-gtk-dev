/**
 * @description       : This code is a holder for enumerations used in the project. This class is current with the
 *                      Spring '24 release and a part of the Salesforce Partner Learning Camp course
 *                      "B2B Commerce: Developer Essentials" and specific to these activities:
 *                          1. Implement a Shipping Provider
 *                          2. Configure a Cart Orchestrator
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-22-2024
 * @last modified by  : Tom Zarr
**/
public class Enumerations
{
    /**
    * Calculation methodology enumeration. This could be expanded and switched on to do more elaborate things.
    * This is just for a simple example and starting off with clean coding practices.
    *   1. PRODUCT = Does not use the line item quantity (lower shipping total analgous to giving away the farm)
    *   2. ITEM = Respects the line item quantity and multiplies by it (higher shipping total)
    */
    public Enum CalculationMethodology
    {
        PRODUCT,
        ITEM,
        ANOTHERWAY1,
        ANOTHERWAY2
    }

    public Enum LocalPricingSource
    {
        CONNECTAPI,
        EXAMPLECODE
    }
}