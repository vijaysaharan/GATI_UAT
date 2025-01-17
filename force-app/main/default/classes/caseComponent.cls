public without sharing class caseComponent {
    @AuraEnabled
    public static Map<String,Object> docketValidation(String docketNo){
        try {
           User CurrentUser=[Select id,name,FederationIdentifier,ADID__c,Profile.Name from user where id=:UserInfo.getUserId()];
          string fed;
          fed=CurrentUser.ADID__c;
           if(CurrentUser.Profile.Name=='System Administrator' || CurrentUser.Profile.Name == 'User API')
           {
           fed='crmproj2';
           }
            if(fed==null)
           {
               throw new IllegalArgumentException('Federation ID was not found on user');
           }
           else {
               docketverify docket= new docketverify();
               docket.docketNo=docketNo;
               docket.requestedBy=fed;

                Http http = new Http();              
            HttpRequest req1 = new HttpRequest();
            map<string,Object> obj = new map<string,Object>();
            String AuthParams = API_credential__mdt.getInstance('DocketNoVerification').Other_Auth_Parameter__c;
            String[] AuthParamsSplitted = AuthParams.split('\\|');
            for (String Authpar:AuthParamsSplitted)
            {
                String[] nameValue= Authpar.split('\\:');
                req1.setHeader(nameValue[0], nameValue[1]);                   
            }
            req1.setTimeout(2*60*1000);
            req1.setHeader('Content-Type','application/json');
            req1.setHeader('accept','application/json');
            req1.setEndpoint(API_credential__mdt.getInstance('DocketNoVerification').Endpoint__c);
            req1.setMethod('POST');
            req1.setBody(JSON.serialize(docket));
            Httpresponse res=http.send(req1);
               set<string> oudata= new set<String>();
               String CustomerData;
               String CompanyCode;
             map<string,string> ous= new map<string,string>();  
            if(res.getStatusCode()==200)
            {

                 obj =(map<string,object>)JSON.deserializeUntyped(res.getBody());
                
                DocketJson ob=DocketJson.parse(res.getBody());
                system.debug(ob.response);
                for(DocketJson.cls_response re: ob.response)
                {
                    if(re.result.size()>0)
                    {
                        oudata.add(re.result[0].BOOKING_STN);
                        oudata.add(re.result[0].DELIVERY_STN);
                        if(re.result[0].STOCK_OU !=null || re.result[0].STOCK_OU!=''){oudata.add(re.result[0].STOCK_OU);}
                        if(re.result[0].STOCK_DISPATCH_OU!=null || re.result[0].STOCK_DISPATCH_OU!=''){oudata.add(re.result[0].STOCK_DISPATCH_OU);}
                        if(re.result[0].STOCK_RECEIVING_OU!=null || re.result[0].STOCK_RECEIVING_OU!=''){oudata.add(re.result[0].STOCK_RECEIVING_OU);}
                        CustomerData =re.result[0].CUSTOMER_CODE;
                        CompanyCode =re.companyId=='GKE'?'102':'101';
                    }
                }
                list<Organization_Master__c> org= [select id,name,Ref_Code__C from Organization_Master__c where ref_code__c in: oudata];
                
                if (CustomerData!=null && CustomerData!='')
                {
                   for(Account Acc :[Select Id from Account where Customer_Code__c=: Decimal.valueOf(CustomerData+'.'+CompanyCode)])                  
                   {
                       system.debug(Acc.Id);
                        obj.put(CustomerData,Acc.Id);
                   }
                }
                if(org.size()>0)
                {
                    for(Organization_Master__c ors: org)
                    {
                        obj.put(ors.ref_Code__C,ors.id);
                    }
                }
            
                 system.debug(obj);
              if(!obj.isEmpty())
              {
                  return obj;
              }
              else {
                  return null;
              }
           }
        
           else{
               throw new CalloutException(res.getBody());
           }
          
        }
    } 
        
        catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    class docketverify{
        string requestedBy;
        string docketNo;
    }

    @AuraEnabled
    public static Integer fetchCaseBasesOnDocket(String subType, String docket){
        List<Case> caseList =[SELECT Id, Docket_Number__c, Sub_Type__c FROM Case WHERE Docket_Number__c=:docket AND Sub_Type__c=:subType AND Status='Open(Assigned)'];
        if(!caseList.isEmpty() && caseList.size()>0){
            System.debug('--- check case opened--'+caseList.size());
            return caseList.size();
        }
        return 0;
    }
}