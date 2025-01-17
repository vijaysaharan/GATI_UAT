public with sharing class Contract_termination {
    @InvocableMethod
    public static void calloutMethod(List<String> accountIds){
        terminationRequest(accountIds);
    }
    @future(callout=true)
    public static void terminationRequest(List<String> accountIds){
        Integration_Log__c il;
        TerminationPayload reqBody = new TerminationPayload();
        Account acc = 
            [Select GATI_Company_Code__c,
                    Contract_Number__c,
                    Contract_end_date__c,
                    Remarks__c,
                    Extension_Date__c,
                    Contract_Status__c,
                    ExtensionNumber__c from Account where Id in :accountIds];
        String staffCode = [select Staff_Code__c from User where id = :UserInfo.getUserId()].Staff_Code__c;
        System.debug(acc);
        List<Lookup_Master__mdt> cc = Lookup_Master__mdt.getAll().values();
        for(Lookup_Master__mdt cinst:cc){
            if(cinst.External_Field_Value__c==acc.GATI_Company_Code__c)
                reqBody.companyId=cinst.External_Field_Value__c;
        }
        
        reqBody.contractNo = acc.Contract_Number__c;
        DateTime cEndDate;
        if(acc.Contract_end_date__c!=null){
            cEndDate =DateTime.newInstance(acc.Contract_end_date__c.year(),acc.Contract_end_date__c.month(),acc.Contract_end_date__c.day());
            reqBody.contractEndDate =cEndDate.format('dd-MM-yyyy hh:mm:ss');
        }else{
            reqBody.contractEndDate='';
        }
        DateTime dt = DateTime.now();
        reqBody.terminationDate = dt.format('dd-MM-yyyy hh:mm:ss'); //today
        reqBody.lastUpdatedDate = dt.format('dd-MM-yyyy hh:mm:ss'); //today
        reqBody.terminationReason = acc.Remarks__c; //need to be added with validation
        //reqBody.terminationCode = 52; //TBD
        reqBody.terminationRemarks = acc.Remarks__c; //need to be added
        reqBody.lofContractStatus = acc.Contract_Status__c; //api name needs to be changed
        reqBody.lastUpdatedBy = staffCode; //Current user staff code
        if(acc.Extension_Date__c!=null){
            DateTime cExtDate =DateTime.newInstance(acc.Extension_Date__c.year(),acc.Extension_Date__c.month(),acc.Extension_Date__c.day());
            reqBody.contractEndDate =cExtDate.format('dd-MM-yyyy hh:mm:ss');
        }else{
            reqBody.contractEndDate='';
        }
        reqBody.lofExtensionCnt = (Integer)acc.ExtensionNumber__c; //extension number
        
        List<Contract_transaction__mdt> ct = Contract_transaction__mdt.getAll().values();
        for(Contract_transaction__mdt cinst:ct){
            if(cinst.CRM_Field_Value__c==acc.Contract_Status__c)
                reqBody.contractTransType=cinst.External_Field_Value__c;
        }
        System.debug(json.serialize(reqBody));
        Http http = new Http();              
                HttpRequest req1 = new HttpRequest();
                String authParams = API_credential__mdt.getInstance('Contract_Termination').Other_Auth_Parameter__c;
                String[] authParamsSplitted = authParams.split('\\|');
                for (String authpar:authParamsSplitted)
                {
                    String[] nameValue= authpar.split('\\:');
                    req1.setHeader(nameValue[0], nameValue[1]);                   
                }
                req1.setHeader('Content-Type','application/json');
                req1.setHeader('accept','application/json');
                req1.setEndpoint(API_credential__mdt.getInstance('Contract_Termination').Endpoint__c);
                req1.setBody(JSON.serialize(reqBody));
                req1.setMethod('POST');
                System.debug(req1);
        try{
                HttpResponse res1 = http.send(req1);
                System.debug('res1.getBody()=='+res1.getBody());
                if(res1.getStatusCode() == 200) {    
                    //root = (Root)JSON.deserialize(res1.getbody(),Root.class); 
                    System.debug(res1);
                    Map<String, Object> contractResponse = (Map <String, Object>)JSON.deserializeUntyped(res1.getbody());
                    
                    String resultStatus = (String)contractResponse.get('result');
                    if(resultStatus=='failed')
                    {
                        il = new Integration_Log__c();
                        il.eRecordID__c=accountIds[0];
                        il.Error_Message__c=(String)contractResponse.get('sErrMsg');
                        il.IsIntegration__c=true;
                        Insert il;
                        throw new MyException('Error : '+(String)contractResponse.get('sErrMsg'));
                    }
                    else if(resultStatus=='successful')
                    {
                        system.debug('Contract terminated successfully!');
                        il = new Integration_Log__c();
                        il.eRecordID__c=accountIds[0];
                        il.Error_Message__c='Successfully Terminated';
                        il.IsIntegration__c=true;
                        Insert il;
                    }
                }
                else{
                    throw new MyException('Error fetching details');
                }
        }catch(Exception e){
            il = new Integration_Log__c();
            il.eRecordID__c=accountIds[0];
            il.Error_Message__c='Error During Request';
            il.IsIntegration__c=true;
            Insert il;
        }
    }
    
    public class MyException extends Exception{}
    
    public class TerminationPayload{
        public string companyId{get;set;}
        public string contractNo{get;set;}
        public string contractEndDate{get;set;}
        public string terminationDate{get;set;}
        public string terminationReason{get;set;}
        public string terminationRemarks{get;set;}
        public string lofContractStatus{get;set;}
        public string lastUpdatedBy{get;set;}
        public string lastUpdatedDate{get;set;}
        public Integer lofExtensionCnt{get;set;}
        public string contractTransType{get;set;}
        
    }
}