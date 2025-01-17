/*
Name : Send_Complaint_CCEC_RecordsQueueable
Test Class Name : Send_Complaint_CCEC_RecordsQueueableTest
Author : Sumit Gupta (sgupta3@kloudrac.com)
Date : Mar 04, 2022
Desc : 
Ref : Send_Complaint_CCEC_RecordsQueueable
*/
public class Send_Complaint_CCEC_RecordsQueueable implements Queueable,Database.AllowsCallouts {
    public List<string> updateIds;
    public Send_Complaint_CCEC_RecordsQueueable(List<String> caseid){
        this.updateIds = caseid;
    }
    
    public void execute(QueueableContext context) {
        system.debug('Send_Complaint_CCEC_RecordsQueueable Called');
        if(Test.isRunningTest()){
            Send_Complaint_CCEC_RecordsClass.calloutMethod(updateIds,'200');
        }else{
            Send_Complaint_CCEC_RecordsClass.calloutMethod(updateIds,'isTestFalse');
        }
    }
}