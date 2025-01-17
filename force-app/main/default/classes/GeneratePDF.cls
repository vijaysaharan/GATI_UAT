public with sharing class GeneratePDF {
    @InvocableMethod(label='Attachment')
    public static list<String> getPDFData(List<String> Qid){
        
        Pdfpayload reqBody = new Pdfpayload();
        list<String> errormessage= new  list<String>();
        String em ='true';
        errormessage.add(em);
        Quote qt = 
            [Select Id,Name,actionType__c,Test_LOF_number__c,
             Account.GATI_Company_Code__c,outputType__c,PrintFor__c,
             Account.Associated_OU__r.Name,
             AmendedVersion__c
             from Quote where ID in :Qid];
       String ADID = [select ADID__c from User where id = :UserInfo.getUserId()].ADID__c;
        reqBody.contractNo=qt.Test_LOF_number__c;
        reqBody.actionType=qt.actionType__c;
        reqBody.ouCode=qt.Account.Associated_OU__r.Name;
        reqBody.outputType=qt.outputType__c;
        reqBody.printFor=qt.PrintFor__c;
        reqBody.requestedBy=ADID;
        reqBody.amendedVersion=qt.AmendedVersion__c;
        reqBody.companyId = qt.Account.GATI_Company_Code__c;
        System.debug(JSON.serialize(reqBody));
        Http http = new Http();              
        HttpRequest req1 = new HttpRequest();
        String authParams = API_credential__mdt.getInstance('Generate_PDF').Other_Auth_Parameter__c;
        String[] authParamsSplitted = authParams.split('\\|');
        for (String authpar:authParamsSplitted)
        {
            String[] nameValue= Authpar.split('\\:');
            req1.setHeader(nameValue[0], nameValue[1]);                   
        }
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setEndpoint(API_credential__mdt.getInstance('Generate_PDF').Endpoint__c);
        req1.setBody(JSON.serialize(reqBody));
        req1.setMethod('POST');
        req1.setTimeout(15000);
        System.debug(req1); 
        
        //System.debug('res1.getBody()=='+res1.getBody());        
        try{
            HttpResponse res1 = http.send(req1);
            if(res1.getStatusCode() == 200) {
                
                
                ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(res1.getBody(), ResponseWrapper.class);
                
                System.debug('pdf=> ' + responseObj.response.result);
                
                
                
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; 
                conVer.PathOnClient = 'ClientPDF.pdf'; 
                conVer.Title = 'File '; 
                conVer.VersionData = EncodingUtil.base64Decode(responseObj.response.result); 
                insert conVer;
                system.debug(conVer.ContentLocation);
                
                
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                
                
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = Qid[0]; 
                cDe.ShareType = 'I';
                cDe.Visibility = 'AllUsers';
                insert cDe;
                system.debug('abc'+cDe.Id);
                
            }else{
                throw new AuraHandledException('Error fetching details');
                
            }
            
            
            
        }
        
        
        catch(Exception e){
            Integration_Log__c log = new Integration_Log__c();
            log.Component_Name__c='Generate PDF Log';
            log.Error_Message__c=e.getMessage();
            errormessage[0]=log.Error_Message__c;
            log.IsIntegration__c=true; 
            insert log;   
            System.debug('abc');
             return errormessage;
        }
        return errormessage;
        
    }
    
    
    
    
    class Pdfpayload{
        public string companyId{get;set;}
        public string contractNo{get;set;}
        public string actionType{get;set;}
        public string ouCode{get;set;}
        public string outputType{get;set;}
        public string printFor{get;set;}
        public string requestedBy{get;set;}
        public decimal amendedVersion{get;set;}
        
    }
    
    public class ResponseWrapper{
        public String requid;    //GS21003
        public String result;    //successful
        public String sErrMsg;    //
        public AttachmentWrapper response;
        
    }
    public class AttachmentWrapper{
        String contractNo;
        String result;
    }
    
}