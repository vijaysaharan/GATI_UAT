public class Send_Complaint_CCEC_RecordsQueueable implements Queueable,Database.AllowsCallouts {
    public List<string> updateIds;
    
    public Send_Complaint_CCEC_RecordsQueueable(List<String> caseid){
        this.updateIds = caseid;
    }
    
    public void execute(QueueableContext context) {
        if(Test.isRunningTest()){
            Send_Complaint_CCEC_RecordsClass.calloutMethod(updateIds,'200');
        }
        else{
            Send_Complaint_CCEC_RecordsClass.calloutMethod(updateIds,'isTestFalse');
        }
    }
}