public Without Sharing class Send_Complaint_CCEC_Records {
    @InvocableMethod(label ='AutoCCEC')
    public static void SendComplaintCCEC(List<FlowInput> inputs){
        List<string> caseId1 = new List<string>();
        for(FlowInput it : inputs){
            caseId1.add(it.caseid);
        }
        Send_Complaint_CCEC_RecordsQueueable idQueue = new Send_Complaint_CCEC_RecordsQueueable(caseId1);
        System.enqueueJob(idQueue); 
    }
    
    public class FlowInput{
        @InvocableVariable public String caseid;        
        @InvocableVariable public Boolean Checkbox;        
    }
}