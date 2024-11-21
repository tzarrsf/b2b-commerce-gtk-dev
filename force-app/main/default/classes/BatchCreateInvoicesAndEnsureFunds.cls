global class BatchCreateInvoicesAndEnsureFunds implements Database.Batchable<sObject>  {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, FulfilledToName, OrderSummaryId FROM FulfillmentOrder WHERE Status = \'Fulfilled\' AND InvoiceId = NULL'
        );
    }
    
    
    global void execute(Database.BatchableContext bc, List<FulfillmentOrder> fos){
        String invoiceId;
        
        for(FulfillmentOrder fo : fos){
            try{
                // 1. Create Invoice
                invoiceId = createInvoice(fo.Id);
                
                // 2. Create EnsureFunds            
                createEnsureFunds(fo.OrderSummaryId, invoiceId); 
                
            } 
            catch (Exception e) {   
                // put here your exception logic 
            }  
        }            
    }
    
        
    global void finish(Database.BatchableContext bc){        
        
    }        
              
    
    private static String createInvoice(String fulfillmentOrderId) {            
      ConnectApi.FulfillmentOrderInvoiceInputRepresentation invoiceInput = new ConnectApi.FulfillmentOrderInvoiceInputRepresentation();
        ConnectApi.FulfillmentOrderInvoiceOutputRepresentation outputRepresentation = ConnectApi.FulfillmentOrder.createInvoice(fulfillmentOrderId, invoiceInput);

        return outputRepresentation.invoiceId;          
    }  
    
    
    private static void createEnsureFunds(String orderSummaryId, String invoiceId) {            
        ConnectApi.EnsureFundsAsyncInputRepresentation ensureFundsAsyncInput = new ConnectApi.EnsureFundsAsyncInputRepresentation();
        ensureFundsAsyncInput.invoiceId = invoiceId;
        ConnectApi.EnsureFundsAsyncOutputRepresentation outputRepresentation = ConnectApi.OrderSummary.ensureFundsAsync(orderSummaryId, ensureFundsAsyncInput);
    }     
}