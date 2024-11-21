global class BatchExportFulfillmentOrders implements Database.Batchable<sObject> {
    
    // collect the batches of records or objects to be passed to execute
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, FulfillmentOrderNumber, FulfilledToAddress, ' +
            '  (SELECT Id, Quantity, FulfillmentOrderId, FulfillmentOrderLineItemNumber, OrderItem.Product2.ProductCode ' +
            '   FROM FulfillmentOrderLineItems) ' +
            'FROM FulfillmentOrder ' +
            'WHERE Exported__c = false AND Status = \'Allocated\''
        );
    }
    
    
    // process each batch of records
    global void execute(Database.BatchableContext bc, List<FulfillmentOrder> fulfillmentOrders){
        /*
         * CSV file format:
         * FulfillmentOrderNumber, FulfilledToAddress, FulfillmentOrderLineItemNumber, ProductCode, Quantity
        */
        String fileContext = '';
        for(FulfillmentOrder fo: fulfillmentOrders)
        {
            for(FulfillmentOrderLineItem foLine:fo.FulfillmentOrderLineItems)
            {
                fileContext = fileContext + '"'+ fo.FulfillmentOrderNumber + '","' + 
                    getAddress(fo.FulfilledToAddress) + '","' + 
                    foLine.FulfillmentOrderLineItemNumber + '","' + 
                    foLine.OrderItem.Product2.ProductCode + '",' +
                    foLine.Quantity + '\n';
            }
        }
        
        if (fileContext != '')
        {
            Export_FOI__c exportFO = new Export_FOI__c();
            exportFO.ExportName__c = 'Export Fulfilment Orders';
            exportFO.ExportDate__c = system.today();
            insert exportFO;
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; 
            conVer.Title = 'Fulfillment Orders';  
            conVer.VersionData = Blob.valueOf(fileContext);
            conVer.PathOnClient = 'FulfillmentOrders.csv';
            insert conVer;
            
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDoc;
            cDocLink.LinkedEntityId = exportFO.Id; 
            cDocLink.ShareType = 'V'; 
                    
            insert cDocLink;
            
        }
        
        for(FulfillmentOrder fo: fulfillmentOrders)
        {
            fo.Exported__c = true;
            fo.Status = 'Assigned';
        }
        if(fulfillmentOrders.size() > 0){
            update fulfillmentOrders;
        }
    }    
    
    
    // execute any post-processing operations
    global void finish(Database.BatchableContext bc){

    } 
    
    private String getAddress(Address address){
        return address.getStreet() + ' '+ 
            address.getCity() + ' '+ 
            address.getState() + ' '+ 
            address.getPostalCode() + ' '+ 
            address.getCountry();
        
    }

}