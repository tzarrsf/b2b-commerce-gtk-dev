@RestResource(urlMapping='/Fulfillment/ImportASNs')
global with sharing class SubmitBatchImportASNs{
    @HttpPost
    global static void doPost(List<AdvanceShippingNotice> asn)
    {
        List<AdvanceShippingNotice> newASN = asn;  
        
        System.Debug('Number Of Records ' + newASN);
        
        BatchImportASNs importASN = new BatchImportASNs(newASN);
        ID batchprocessid = Database.executeBatch(importASN, 200);

    }
    // Sample Payload:
    //{"asn":[{"FulfillmentOrderNumber":"010789", "FulfillmentOrderItemNumber":"1", "QuantityFulfilled":15, "QuantityCancelled":0}
    //,{"FulfillmentOrderNumber":"217895", "FulfillmentOrderItemNumber":"2", "QuantityFulfilled":20, "QuantityCancelled":1}]}

}