public with sharing class DocketValidate {
    
    public Map<String, DocketJson.cls_response>  validate(String docketNo){
        try {
            Map<String,DocketJson.cls_response> sc = new Map<String, DocketJson.cls_response>();
            User CurrentUser = [SELECT Id, Name, FederationIdentifier, ADID__c, Profile.Name FROM user WHERE Id=:UserInfo.getUserId()];
            String fed;
            fed=CurrentUser.ADID__c;
            
            if(CurrentUser.Profile.Name == 'System Administrator'){
                fed='crmproj2';
            }
            if(fed == null){
                throw new IllegalArgumentException('Federation ID was not found on user');
            }
            else{
                docketverify docket = new docketverify();
                docket.docketNo = docketNo;
                docket.requestedBy = fed;                
                Http http = new Http();                
                HttpRequest req1 = new HttpRequest();
                Map<String, Object> obj = new Map<String, Object>();
                String AuthParams = API_credential__mdt.getInstance('DocketNoVerification').Other_Auth_Parameter__c;
                String[] AuthParamsSplitted = AuthParams.split('\\|');
                for (String Authpar:AuthParamsSplitted){
                    String[] nameValue= Authpar.split('\\:');
                    req1.setHeader(nameValue[0], nameValue[1]);                   
                }
                req1.setHeader('Content-Type','application/json');
                req1.setHeader('accept','application/json');
                req1.setEndpoint(API_credential__mdt.getInstance('DocketNoVerification').Endpoint__c);
                req1.setMethod('POST');
                req1.setTimeout(60000);
                req1.setBody(JSON.serialize(docket));
                
                HttpResponse res = new HttpResponse();
                Set<String> oudata= new Set<String>();
                Map<String, String> ous = new Map<String, String>();
                
                if(!Test.isRunningTest()){
                    res = http.send(req1);
                }
                else{                    
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{"requid":"GS21004","result":"successful", "sErrMsg":"","response":[{"docketNo":"177697167","companyId":"GKE","result":[{"DOCKET_NO":"177697167","CUSTOMER_CODE":"123456","PDC_BLOCK":"N","ASSURED_DLY_DT":"2025-06-12"}]}]}');
                    res.setStatusCode(200);
                }
                
                if(res.getStatusCode()==200){
                    try{ 
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='Docket Validation';
                        ic.IsIntegration__c=true;
                        ic.Inbound_JSON__c=res.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(docket);
                        insert ic;
                    }
                    catch(Exception e){}   
                }
                else{
                    try{ 
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='Docket validation';
                        ic.IsIntegration__c=true;
                        ic.Inbound_JSON__c=res.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(docket);
                        insert ic;
                    }
                    catch(Exception e){}   
                }
                obj =(map<string,object>)JSON.deserializeUntyped(res.getBody());                
                DocketJson ob=DocketJson.parse(res.getBody());
                for(DocketJson.cls_response re: ob.response){
                    if(re.result.size()>0){
                        sc.put(re.result[0].DOCKET_NO,re);
                    }                    
                }
            }
            
            return sc;
        }
        catch(Exception e){
            System.debug(e.getmessage()+' '+e.getlinenumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    class docketverify{
        String requestedBy;
        String docketNo;
    }
}