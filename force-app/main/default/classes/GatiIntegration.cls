@RestResource(urlMapping='/SendRecord/*')
global with sharing class GatiIntegration {
    @HttpPost
    global static Wrapperclass doPost(){
        RestRequest req = RestContext.request;
        String reqBody = (req.requestBody.toString());
        System.debug(reqBody);
        MRWrapperClass reqMR = (MRWrapperClass)json.deserialize(reqBody, MRWrapperClass.class);
        //Invoice__c invoice = [SELECT ID FROM Invoice__c where Gati_Inv_eid__c=:reqMR.gatiEID];
        Invoice__c parInvoice = new Invoice__c (Name=reqMR.invoiceNumber);
        // parInvoice.Name=reqMR.InvoiceNumber;
        Money_Receipt__c mr = new Money_Receipt__c();
        try{
            mr.Gati_MR_eid__c= reqMR.gatiEID;
            //mr.Invoice_Number_del__c= invoice.ID;
            mr.Invoice_Number_del__r= parInvoice;
           // mr.Transaction_ID__c= reqMR.tID;
            mr.Transaction_Type__c= reqMR.tType;
            mr.Transaction_Amount__c= reqMR.tAmount;
            mr.Transaction_Status__c= reqMR.tStatus;
            mr.Transaction_Pending_With__c= reqMR.tpending;
            mr.Transaction_Date__c= reqMR.tDate;
            mr.Transaction_Approved_Date__c= reqMR.tApproveDate;
            System.debug(mr);
            insert mr;
        }
        
        catch(Exception e){
            Integration_Log__c log = new Integration_Log__c();
            log.Component_Name__c='CreditNote, AMR, IMR';
            log.Error_Message__c=e.getMessage();
            log.IsIntegration__c=true; 
            insert log; 
            if(log.Error_Message__c!=null)
            {
                wrapperclass wc = new wrapperclass();
                wc.status ='ERROR!';
                wc.error=log.Error_Message__c;
                return wc;
            }
            
        }
        wrapperclass wc = new wrapperclass();
        wc.Status ='Success';
        return wc;
    }
    
    
    public class MRWrapperClass{
        public string gatiEID;
        public decimal tID;
        public string tType;
        public decimal tAmount;
        public string tStatus;
        public string tpending;
        public date tDate;
        public date tApproveDate;
        public string invoiceNumber;
    }  
    global class Wrapperclass {
        
        String status {get;set;}
        String error {get;set;}  
    }
    
}