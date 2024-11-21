global class BatchCreateFulfillmentOrders implements Database.Batchable<OrderSummary>, Database.Stateful{
    static final String WAREHOUSE_TYPE = 'Warehouse'; // WAREHOUSE_LOCATION_TYPE and WAREHOUSE_FULFILLMENT_TYPE are the same
    static final String ORDERSUMMARY_WAITING = 'Waiting to Fulfill';
    static final String ORDERSUMMARY_APPROVED = 'Approved';
    private Schema.Location location;
    
    /* If the start method returns a QueryLocator, the optional scope parameter of System.scheduleBatch can have a maximum value of 2,000. If set to a higher value, Salesforce chunks the records returned by the QueryLocator into smaller batches of up to 2,000 records. 
    If the start method returns an iterable, the scope parameter value has no upper limit. However, if you use a high number, you can run into other limits.*/
    global Iterable<OrderSummary> start(Database.BatchableContext BC){
        List<OrderSummary> orderSummaries = [SELECT Id, (SELECT Id From OrderDeliveryGroupSummaries), 
                                                        (SELECT Id, Quantity, OrderDeliveryGroupSummaryId FROM OrderItemSummaries) 
                                             FROM OrderSummary WHERE Status =: ORDERSUMMARY_APPROVED]; //find the OS that is Approved
        location = [SELECT Id FROM Location WHERE LocationType =: WAREHOUSE_TYPE LIMIT 1];
        System.debug('start - Order Summaries: ' + orderSummaries);
        return orderSummaries;
    }
    
    global void execute(Database.BatchableContext BC, List<OrderSummary> scope){
        List<OrderSummary> orderSummaryListSuccess = new List<OrderSummary>();
        for(OrderSummary os : scope){ 
            List<String> foIds = createFulfillmentOrder(os);
            if (foIds.size() > 0) { //If fulfillment order is created successfully.
                os.Status = ORDERSUMMARY_WAITING;
                orderSummaryListSuccess.add(os);
            }
        } 
        update orderSummaryListSuccess;
    }
    
    global void finish(Database.BatchableContext BC){ 
    } 
    
    private List<String> createFulfillmentOrder(OrderSummary orderSummary) {
        List<String> fulfillmentOrderIdList = new List<String>();
        
        for(OrderDeliveryGroupSummary orderDeliveryGroupSummary : orderSummary.OrderDeliveryGroupSummaries){
            List<ConnectApi.OrderItemSummaryInputRepresentation> orderItems = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
            for(OrderItemSummary orderItemSummary : orderSummary.OrderItemSummaries){
               if(orderItemSummary.OrderDeliveryGroupSummaryId == orderDeliveryGroupSummary.Id){
                    ConnectApi.OrderItemSummaryInputRepresentation orderItemSummaryInputRepresentation = new ConnectApi.OrderItemSummaryInputRepresentation();
                    orderItemSummaryInputRepresentation.orderItemSummaryId = orderItemSummary.Id;
                    orderItemSummaryInputRepresentation.quantity = orderItemSummary.Quantity;
    
                    orderItems.add(orderItemSummaryInputRepresentation);
               }
            }
            if (orderItems.size() > 0){
                ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                fulfillmentGroup.fulfilledFromLocationId = location.Id;
                fulfillmentGroup.fulfillmentType = WAREHOUSE_TYPE;
                fulfillmentGroup.orderItemSummaries = orderItems;
                
                ConnectApi.FulfillmentOrderInputRepresentation inputRepresentation = new ConnectApi.FulfillmentOrderInputRepresentation();
                inputRepresentation.orderSummaryId = orderSummary.Id;
                inputRepresentation.orderDeliveryGroupSummaryId = orderDeliveryGroupSummary.Id;
                inputRepresentation.fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
                inputRepresentation.fulfillmentGroups.add(fulfillmentGroup);
                
                ConnectApi.FulfillmentOrderOutputRepresentation fulfillmentOrderOutput = ConnectApi.FulfillmentOrder.createFulfillmentOrders(inputRepresentation);
                fulfillmentOrderIdList.addAll(fulfillmentOrderOutput.fulfillmentOrderIds);
            }
        }
        
        return fulfillmentOrderIdList;
    }
}