@RestResource(urlMapping='/CCECUpdateBulkversion2/*')
global with sharing class tempCCECUpdate {
    @HttpPost
    global static List<WrapperClass> doPost(){
        List<Wrapperclass> resultList = new List<Wrapperclass>();
        List<CCEC__c> CCECObjList = new List<CCEC__c>();
        List<CCEC_Remark__c> remarksList = new List<CCEC_Remark__c>();
        List<String> ccecNameList = new List<string>();
        List<CCEC__c> newCCECobj = new List<CCEC__c>();
        Map<String, Object> mpp = new Map<String, Object>();
        List<String> ccecOus = new List<String>();
        Map<String,Organization_Master__c> ccecOUToMaster = new Map<String,Organization_Master__c>();
        
        System.debug('ALL DATA-->'+RestContext.request.requestBody.toString());
        List<WrapperCCEC> reqCC = (List<wrapperCCEC>)json.deserialize(RestContext.request.requestBody.toString(), List<wrapperCCEC>.class);
        
        for(WrapperCCEC reqCCobj : reqCC){
            ccecNameList.add(reqCCobj.Name);
            if(reqCCobj.newCcecOu != null){
                ccecOus.add(reqCCobj.newCcecOu);
            }
        }
        for(CCEC__c c : [SELECT Id,Case__c,Status__c,First_response_time_Slab__c,Feedback__c,Closure_Adherence__c,CCEC_Closure_Date__c,CCEC_OU_Assignment_Logic__c,CCEC_OU_Assignment_Logic__r.REF_Code__c,Name,Case__r.Sub_Type__c,Proactive_CCEC_Flag__c FROM CCEC__c WHERE Name IN: ccecNameList]){
            mpp.put(c.Name, c);
        }
        if(ccecOus != null && ccecOus.size()>0){
            List<Organization_Master__c> orgMasters = [SELECT Id,REF_Code__c 
                                                       FROM Organization_Master__c 
                                                       WHERE REF_Code__c IN: ccecOus
                                                      ];
            if(orgMasters != null && orgMasters.size()>0){
                for(Organization_Master__c om : orgMasters){
                    if(!ccecOUToMaster.containsKey(om.REF_Code__c)){
                        ccecOUToMaster.put(om.REF_Code__c,om);
                    }
                }
            }
        }
        
        try{
            for(WrapperCCEC reqCCobj: reqCC){
                CCEC__c CCECobj = (CCEC__c)mpp.get(reqCCobj.name);
                CCEC__c cc = new CCEC__C();
                if(CCECobj != null){
                    if(reqCCobj.cCECStatus != null){
                        CCECobj.Status__c = reqCCobj.cCECStatus;
                    }
                    if(reqCCobj.firstResponsetimeSlab != null){
                        CCECobj.First_response_time_Slab__c = reqCCobj.firstResponsetimeSlab;
                    }
                    if(reqCCobj.feedback != null){
                        CCECobj.Feedback__c = reqCCobj.feedback;
                    }
                    if(reqCCobj.newCcecOu != null){
                        cc.NewCCECOU__c = reqCCobj.newCcecOu;
                    }
                    if(reqCCobj.newCCECFlag == 'Y' && reqCCobj.newCcecOu != null && cCECobj.Case__r.Sub_Type__c == 'NON DELIVERED' && cCECobj.Proactive_CCEC_Flag__c == false){
                        CCECobj.Status__c=reqCCobj.cCECStatus;
                        cc.Case__c=cCECobj.Case__c;
                        //cc.CCEC_OU_Assignment_Logic__c = [SELECT Id,REF_Code__c FROM Organization_Master__c WHERE REF_Code__c=:reqCCobj.newCcecOu].Id;
                        cc.CCEC_OU_Assignment_Logic__c = ccecOUToMaster.get(reqCCobj.newCcecOu).Id;
                        cc.Auto_CCEC_Flag__c=true;
                        cc.CCEC_Instructions__c='Connect Shipment/Arrange Delivery and share GA Details';
                        newCCECobj.add(cc);
                    }
                    if(reqCCobj.newCCECFlag != null && reqCCobj.newCCECFlag == 'N'){
                        CCECobj.Status__c=reqCCobj.cCECStatus;
                    }
                    if(reqCCobj.cPTadherence != null){
                        CCECobj.Closure_Adherence__c=reqCCobj.cPTadherence;
                    }
                }
                //Database.SaveResult result = Database.update(CCECobj,false);
                CCECObjList.add(CCECobj);
                CCEC_Remark__c CCECReobj = new CCEC_Remark__c();
                System.debug('CCECobj Id -> '+CCECobj.id);
                CCECReobj.CCEC__c = CCECobj.Id;
                if(reqCCobj.openRemarks != null){
                    CCECReobj.Open_Remarks__c = reqCCobj.openRemarks;
                } 
                if(reqCCobj.commentsBy != null){
                    CCECReobj.Comments_By__c = reqCCobj.commentsBy;
                }
                if(reqCCobj.remarkSeq != null){
                    CCECReobj.Remark_Seq__c = reqCCobj.remarkSeq;
                }
                if(reqCCobj.remarksProvidedBy != null){
                    CCECReobj.Remarks_Provided_By__c = reqCCobj.remarksProvidedBy;
                }
                if(reqCCobj.remarksDate != null){
                    CCECReobj.Remarks_Date__c = reqCCobj.remarksDate; 
                }
                //Database.SaveResult result2 = Database.insert(CCECReobj,false);
                remarksList.add(CCECReobj);
            }
            
            List<Database.SaveResult> result = new List<Database.SaveResult>();
            List<Database.SaveResult> result2 = new List<Database.SaveResult>();
            List<Database.SaveResult> result3;
            
            if(newCCECobj != null && newCCECobj.size()>0){
                System.debug('newccecobj LIST -> '+newccecobj);
                result3 = Database.insert(newCCECobj,false);
            }
            if(!CCECObjList.isEmpty()){
                result = Database.update(CCECObjList,false);
            }
            if(!remarksList.isEmpty()){
                result2 = Database.insert(remarksList,false);
            }
            
            for(Database.SaveResult res : result){
                if(res.isSuccess()){  
                    Wrapperclass wc = new Wrapperclass();
                    wc.status ='Success';
                    System.debug(result);
                    resultList.add(wc);
                }
                else{
                    Wrapperclass wc = new Wrapperclass();
                    wc.status ='Not Updated';
                    for(Database.Error er: res.geterrors()){
                        wc.error= er.getMessage();
                    }
                    resultList.add(wc);             
                }
            }
        } 
        catch(Exception e){
            Integration_Log__c log = new Integration_Log__c();
            log.Component_Name__c = 'CCEC with Remarks Inbound';
            log.Error_Message__c = e.getMessage();
            log.IsIntegration__c = true;
            insert log;
            if(log.Error_Message__c != null){
                wrapperclass wc = new wrapperclass();
                wc.Status ='ERROR!';
                wc.error = log.Error_Message__c;
                resultlist.add(wc);
            }
        }
        return resultlist;
    }
    
    public Class WrapperCCEC{
        String openRemarks{get;set;}
        String cCECStatus{get;set;}
        String name{get;set;}
        String firstResponsetimeSlab{get;set;}
        String commentsBy{get;set;}
        Integer feedback{get;set;}
        String cPTadherence{get;set;}
        DateTime cCECclosureDate{get;set;}
        Integer remarkSeq{get;set;}
        String remarksProvidedBy{get;set;}
        DateTime remarksDate{get;set;}
        String newCCECFlag{get;set;}
        String newCcecOu{get;set;}
        String complaintNo{get;set;}
    }
    global class Wrapperclass{
        String status {get;set;}
        String error {get;set;}
    }
}