global class SubmitBatchApproveOrderSummaries implements Schedulable{
      global void execute(SchedulableContext sc){
        BatchApproveOrderSummaries approveOS = new BatchApproveOrderSummaries();
        ID batchprocessid = Database.executeBatch(approveOS, 200);
    }
}