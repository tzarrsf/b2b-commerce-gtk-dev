/**
 * @description       : This code holds the data for our level 3 import script. It's a DTO or 'anemic' object that
 *                      can be thought of as a spreadhsheet row.
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-08-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class ScriptedImportLevel3Element {

    public ScriptedImportLevel3Element(String name, String description, String productCode, Decimal standardPrice, Decimal customPrice)
    {
        this.Name = name;
        this.Description = description;
        this.ProductCode = productCode;
        this.StandardPrice = standardPrice;
        this.CustomPrice = customPrice;
    }

    public String Name { get; set; }

    public String Description { get; set; }

    public String ProductCode { get; set; }

    public Decimal StandardPrice { get; set; }

    public Decimal CustomPrice { get; set; }
}