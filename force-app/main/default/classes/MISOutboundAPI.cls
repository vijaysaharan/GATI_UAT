public class MISOutboundAPI {
    @InvocableMethod(Label = 'CustomerCode')
    public static void calloutmethod(list<String> MISID){
        getCustomerCodeData(MISID);
    }
    @Future(callout = True)
    public static void getCustomerCodeData(list<String> MISID){
        Integration_Log__c Il;
        
        misobjPayload reqBody = new misobjPayload();
        
        MIS__c misobj = [select Rep_Type__c,Email_Id_1__c,Email_Id2__c,Email_Id3__c,Email_Id4__c,Email_Id5__c,
                         Email_Id6__c,Customer_Code__r.GATI_Customer_Code__c,Trigger_Type__c,Frequency__c,Status__c,Cumulative__c,
                         Booking_OU__c,Booking_OU__r.Name,CreatedBy.Staff_Code__c,CreatedDate,LastModifiedDate,LastModifiedBy.Staff_Code__c,
                         Field_List__c,Unique_MIS__c,Company_Of__c from MIS__c where id=:MISID];
        
        system.debug(misobj);
        reqBody.customerCode=misobj.Customer_Code__r.GATI_Customer_Code__c;
        System.debug(reqBody.customerCode);
        reqBody.reportType=misobj.Rep_Type__c;  
        reqBody.triggerType=misobj.Trigger_Type__c;
        reqBody.frequency=misobj.Frequency__c;
        reqBody.status=misobj.Status__c;
        reqBody.cummulative=misobj.Cumulative__c;
        reqBody.emailId1=misobj.Email_Id_1__c;
        reqBody.emailId2=misobj.Email_Id2__c;
        reqBody.emailId3=misobj.Email_Id3__c;
        reqBody.emailId4=misobj.Email_Id4__c;
        reqBody.emailId5=misobj.Email_Id5__c;
        reqBody.emailId6=misobj.Email_Id6__c;
        
        if(misobj.Booking_OU__c!=null)
        {
            reqBody.bookingStation=misobj.Booking_OU__r.Name;  
        }
        else
        {
            reqBody.bookingStation=''; 
        }
        
        if(misobj.CreatedBy.Staff_Code__c!=null)
        {
            reqBody.createdBy=misobj.CreatedBy.Staff_Code__c;  
        }
        else
        {
            reqBody.createdBy=''; 
        }        
        system.debug(reqBody.createdBy);
        reqBody.createdDate=misobj.CreatedDate.format('dd-MM-yyyy hh:mm:ss');
        reqBody.lastModifiedDate=misobj.LastModifiedDate.format('dd-MM-yyyy hh:mm:ss');
        reqBody.lastModifiedBy=misobj.LastModifiedBy.Staff_Code__c;
        system.debug(reqBody.lastModifiedBy);
        reqBody.fieldList=misobj.Field_List__c.replace(';',',');
        
        system.debug(reqBody.fieldList);
        reqBody.companyOf=misobj.Company_Of__c;
        if(misobj.Unique_MIS__c!=null)
        {
            reqBody.sequenceNo=misobj.Unique_MIS__c;  
        }
        else
        {
            reqBody.sequenceNo=''; 
        }
        system.debug('-- check body--'+reqBody);
        
        Http http = new Http();              
        HttpRequest req2 = new HttpRequest();
        String AuthParams = API_credential__mdt.getInstance('MISOutbound').Other_Auth_Parameter__c;
        String[] AuthParamsSplitted = AuthParams.split('\\|');
        for (String Authpar:AuthParamsSplitted)
        {
            String[] nameValue= Authpar.split('\\:');
            req2.setHeader(nameValue[0], nameValue[1]);                   
        }
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('accept','application/json');
        req2.setEndpoint(API_credential__mdt.getInstance('MISOutbound').Endpoint__c);
        
        req2.setMethod('POST');
        //System.debug(req2);
        req2.setBody(JSON.serialize(reqBody));
        //System.debug(req2);
        req2.setTimeout(50000);
        
        
        try{
            HttpResponse res2 = http.send(req2);
            if(res2.getStatusCode() == 200)
            {
               
        System.debug(res2.getStatusCode());
        System.debug('response='+res2.getBody());
         ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(res2.getBody(), ResponseWrapper.class);
                System.debug(+ responseObj); 
               System.debug(+ responseObj.response[0].sequenceNo); 
                misobj.Unique_MIS__c=responseObj.response[0].sequenceNo;
                misobj.MISButtonFlag__c= false;
                update misobj;  
            }
            
            
        }
        catch(Exception e){
            Il = new Integration_Log__c();
            Il.eRecordID__c=MISID[0];
            Il.Error_Message__c=e.getMessage()+' '+e.getCause()+' '+e.getLineNumber();
            Il.IsIntegration__c=true;
            Insert Il;
           // System.debug(e.getMessage()+' '+e.getCause()+' '+e.getLineNumber());
        }
    }
    
    
    public class misobjPayload{
        public string customerCode{get;set;}
        public string reportType{get;set;}
        public string triggerType{get;set;}
        public string frequency{get;set;}
        public string status{get;set;}
        public string cummulative{get;set;}
        public string emailId1{get;set;}
        public string emailId2{get;set;}
        public string emailId3{get;set;}
        public string emailId4{get;set;}
        public string emailId5{get;set;}
        public string emailId6{get;set;}
        public string bookingStation{get;set;}
        public string createdBy{get;set;}
        public string createdDate{get;set;}
        public string lastModifiedDate{get;set;}
        public string lastModifiedBy{get;set;}
        public string fieldList{get;set;}
        public string companyOf{get;set;}
        public string sequenceNo{get;set;}
        
    }
    public class ResponseWrapper{
        public String requid;
        public String result;
        public String sErrMsg;
        public List <SeqWrapper> response;
        
    }
    public class SeqWrapper{
        String sequenceNo;
    }   
        
}