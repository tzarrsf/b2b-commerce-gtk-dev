/**
 * @description       : This code holds the data for our level 4 import script. It's a DTO or 'anemic' object that
 *                      can be thought of as a spreadhsheet row. This approach assumes known product image urls for
                        the product list and first detail image. It could be expanded to include additional images
                        or the DetailImageUrl1 property could be converted to a collection.
 *                      images.
 * @author            : Tom Zarr
 * @group             : Salesforce Commerce Partner Delivery Success (2024)
 * @last modified on  : 03-08-2024
 * @last modified by  : Tom Zarr
**/
public with sharing class ScriptedImportLevel4Element {

    public ScriptedImportLevel4Element(String name, String description, String productCode, String stockKeepingUnit, Decimal standardPrice, Decimal customPrice)
    {
        this(name, description, productCode, stockKeepingUnit, standardPrice, customPrice, null, null);
    }

    public ScriptedImportLevel4Element(String name, String description, String productCode, String stockKeepingUnit, Decimal standardPrice, Decimal customPrice,
        String listImageUrl, String detailImageUrl1)
    {
        this.Name = name;
        this.Description = description;
        this.ProductCode = productCode;
        this.StockKeepingUnit = stockKeepingUnit;
        this.StandardPrice = standardPrice;
        this.CustomPrice = customPrice;
        this.ListImageUrl = listImageUrl;
        this.DetailImageUrl1 = detailImageUrl1;
    }

    public String Name { get; set; }

    public String Description { get; set; }

    public String ProductCode { get; set; }

    public String StockKeepingUnit { get; set; }

    public Decimal StandardPrice { get; set; }

    public Decimal CustomPrice { get; set; }

    public String ListImageUrl { get; set; }

    /**
     * See comments in header. Additional properties like DetailImageUrl2, DetailImageUrl3... could be added for a flat approach
     * or this could be supplanted with a collection that respects cardinality and priority. Here's one potential idea:
     * // Create a Set for uniqueness which contains maps with the priority and image as type Url
     * Set<Map<Integer, Url>> detailImages = new Set<Map<Integer, Url>>();
     * // Create a Set for uniqueness which contains maps with the priority and image as type String
     * Set<Map<Integer, String>> detailImages = new Set<Map<Integer, String>>();
     * There may be better approaches and ideas to try out here.
    **/
    public String DetailImageUrl1 { get; set; }
}