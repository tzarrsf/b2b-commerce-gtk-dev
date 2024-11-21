global class BatchApproveOrderSummaries implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Status FROM OrderSummary WHERE Status = \'Created\''
        );
    }
    
    
    global void execute(Database.BatchableContext bc, List<OrderSummary> orderSummaries){
        for(OrderSummary os : orderSummaries){
            try {
                //Approve OrderSummary
                os.Status = 'Approved';
            } 
            catch (Exception e) {   
                //your exception code here
            }                          
        }      

        //Update batch        
        if(orderSummaries.size() > 0){
            update orderSummaries;
        }                    
    }
    
        
    global void finish(Database.BatchableContext bc){        
        
    }        
}