global class SubmitBatchCreateInvoicesAndEnsureFunds implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchCreateInvoicesAndEnsureFunds createInvoice = new BatchCreateInvoicesAndEnsureFunds();
        ID batchprocessid = Database.executeBatch(createInvoice, 70);
    }
}