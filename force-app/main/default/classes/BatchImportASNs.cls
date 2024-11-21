global class BatchImportASNs implements Database.Batchable<sObject>, Database.Stateful{
    global Map<String, AsnFulfillmentOrder> asnRecords = new Map<String, AsnFulfillmentOrder>();
    private List<AdvanceShippingNotice> asnFile = null;
    
    public BatchImportASNs(List<AdvanceShippingNotice> asnFile){
        this.asnFile = asnFile;
    }
    
    // collect the batches of records or objects to be passed to execute
    global List<FulfillmentOrder> start(Database.BatchableContext bc) { 
        processAsnFile();    
        
        List<String> mapkeys = new List<String>();
        for (String key : asnRecords.keySet()) {
            mapkeys.add(key.remove ('\"'));      
        }
        
        List<FulfillmentOrder> fos =  [SELECT Id, FulfillmentOrderNumber, FulfilledToName, OrderSummaryId, Status, 
                      (SELECT Id, FulfillmentOrderLineItemNumber, Quantity, TypeCode, Quantity_Fulfilled__c FROM FulfillmentOrderLineItems) 
                FROM FulfillmentOrder 
                WHERE FulfillmentOrderNumber IN :mapkeys];
        
        return fos;
    }
    
    
    // process each batch of records
    global void execute(Database.BatchableContext bc, List<FulfillmentOrder> fulfillmentOrders){
        AsnFulfillmentOrder asnFulfillmentOrder = null;
        AsnFulfillmentOrderItem asnFulfillmentOrderItem = null;
        Shipment shipment = null;
        
        List<FulfillmentOrder> foToUpdateList = new List<FulfillmentOrder>();
        List<FulfillmentOrderLineItem> foItemToUpdateList = new List<FulfillmentOrderLineItem>();
        List<Shipment> shipmentList = new List<Shipment>();
        List<String> orderSummaryList = new List<String>();
        
        for(FulfillmentOrder fo: fulfillmentOrders)
        {
            boolean foCompleted = true;
            asnFulfillmentOrder = asnRecords.get(fo.FulfillmentOrderNumber);
            for(FulfillmentOrderLineItem foItem:fo.FulfillmentOrderLineItems)
            {
                if (asnFulfillmentOrder.getFoItems().containsKey(foItem.FulfillmentOrderLineItemNumber))
                {
                    asnFulfillmentOrderItem = asnFulfillmentOrder.getFoItems().get(foItem.FulfillmentOrderLineItemNumber);
                    
                    if (asnFulfillmentOrderItem.getQuantityCancelled() > 0)
                    {
                        if (asnFulfillmentOrderItem.getQuantityCancelled() > foItem.Quantity){
                            // Add your error handling here

                        } else {
                            // Reduce quantity
                            foItem.Quantity = foItem.Quantity - asnFulfillmentOrderItem.getQuantityCancelled();
                            
                                                  
                        }                                     
                    }
                    
                    if(asnFulfillmentOrderItem.getQuantityFulfilled() > 0)
                    {
                        if(foItem.Quantity_Fulfilled__c == null){
                            foItem.Quantity_Fulfilled__c = 0;
                        }
                        
                        if(asnFulfillmentOrderItem.getQuantityFulfilled() > foItem.Quantity)
                        {
                            // Add your error handling here
                            
                        } else if (asnFulfillmentOrderItem.getQuantityFulfilled() < 
                                   (foItem.Quantity - foItem.Quantity_Fulfilled__c))
                        {
                            foCompleted = false;
                        }
                        
                        // Update Fulfillment Order Item Quantity_Fulfilled
                        foItem.Quantity_Fulfilled__c = foItem.Quantity_Fulfilled__c + asnFulfillmentOrderItem.getQuantityFulfilled();
                        foItemToUpdateList.add(foItem);
                    }              
                    
                } else {
                    // Item not included in ASN
                    if (foItem.TypeCode != 'Charge' && 
                        (foItem.Quantity_Fulfilled__c == null || foItem.Quantity > foItem.Quantity_Fulfilled__c)){
                                            
                       foCompleted = false; 
                    }                    
                }                
            }
            
            if (foCompleted){
                fo.Status = 'Fulfilled';
                foToUpdateList.add(fo);
                           
                orderSummaryList.add(fo.OrderSummaryId);
            }
            
            // Create Shipment           
            shipment = new Shipment();           
            shipment.FulfillmentOrderId = fo.Id;
            shipment.ShipToName = fo.FulfilledToName;
            shipmentList.add(shipment);          
            
        }
        
        // Insert Shipments
        if(shipmentList.size() > 0){
            insert shipmentList;
        }
        
        // Update Fulfillment Order Items
        if(foItemToUpdateList.size() > 0){
            update foItemToUpdateList;
        }
        
        // Update Fulfillment Orders 
        if(foToUpdateList.size() > 0){
            update foToUpdateList;
        }
        
        if(orderSummaryList.size() > 0){
            updateOrderSummaryStatus(orderSummaryList);
        } 
    }
    
    
    // execute any post-processing operations
    global void finish(Database.BatchableContext bc){
        
    }

    private void processAsnFile(){       
        AsnFulfillmentOrder asnFulfillmentOrder;
        Map<String, AsnFulfillmentOrderItem> foItemMap;
        
        for (AdvanceShippingNotice asn : asnFile)
        {           
            AsnFulfillmentOrderItem item = new AsnFulfillmentOrderItem(asn.FulfillmentOrderItemNumber,
                                                                       asn.QuantityFulfilled, 
                                                                       asn.QuantityCancelled);    
            if(asnRecords.containsKey(asn.FulfillmentOrderNumber)){
                asnFulfillmentOrder = asnRecords.get(asn.FulfillmentOrderNumber);
                asnFulfillmentOrder.foItems.put(item.fulfillmentOrderItemNumber, item);
                
            } else {
                foItemMap = new Map<String, AsnFulfillmentOrderItem>();
                foItemMap.put(item.fulfillmentOrderItemNumber, item);
                asnFulfillmentOrder = new AsnFulfillmentOrder(asn.FulfillmentOrderNumber, foItemMap);
                asnRecords.put(asn.FulfillmentOrderNumber, asnFulfillmentOrder);
            }
        }      
    }
    
    private void updateOrderSummaryStatus(List<String> orderSummaryIdList){
        List<OrderSummary> orderSummaries = [SELECT Id, Status FROM OrderSummary WHERE id IN :orderSummaryIdList]; 
        for(OrderSummary orderSummary : orderSummaries)
        {
            orderSummary.Status = 'Fulfilled';      
        }
        update orderSummaries;
    }
    
    
    class AsnFulfillmentOrder {
        private String foNumber;
        private Map<String, AsnFulfillmentOrderItem> foItems;
        
        public AsnFulfillmentOrder(String foNumber, Map<String, AsnFulfillmentOrderItem> foItems) {
            this.foNumber = foNumber;
            this.foItems = foItems;
        }
        
        public String getFoNumber() {
            return foNumber;
        }

        public Map<String, AsnFulfillmentOrderItem> getFoItems() {
            return foItems;
        }
    }
    
 
    class AsnFulfillmentOrderItem {
        private String fulfillmentOrderItemNumber;
        private Decimal quantityFulfilled;
        private Decimal quantityCancelled;
        
        public AsnFulfillmentOrderItem(String fulfillmentOrderItemNumber, 
                                       Decimal quantityFulfilled, 
                                       Decimal quantityCancelled) {
            this.fulfillmentOrderItemNumber = fulfillmentOrderItemNumber;
            this.quantityFulfilled = quantityFulfilled;
            this.quantityCancelled = quantityCancelled;
        }
        
        public String getFulfillmentOrderItemNumber() {
            return fulfillmentOrderItemNumber;
        }
    
        public Decimal getQuantityFulfilled() {
            return quantityFulfilled;
        }
    
        public Decimal getQuantityCancelled() {
            return quantityCancelled;
        }     
        
    }
}