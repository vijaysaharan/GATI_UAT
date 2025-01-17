public without sharing class CanvasDetailsForClaims {
    @AuraEnabled
    Public static CanvasParametersCMS getData(String recId,String CanvasName,String objectName)
    {
        CanvasParametersCMS cp = new CanvasParametersCMS(); 
        CanvasParameter__mdt canvasParam = CanvasParameter__mdt.getInstance(CanvasName);
        System.debug('in Class');
        User userinfo = [SELECT ADID__c  FROM User where Id=:Userinfo.getUserId()];
        cp.puser=userinfo.ADID__c;
        System.debug(cp.puser+ ' '+userinfo.ADID__c);
        cp.requid = canvasParam.requid__c;
        cp.authorization=canvasParam.authorization__c;       
        if (String.isBlank(canvasParam.action__c))
        {cp.action=null;   
        }else {cp.action=canvasParam.action__c;}		
        if (String.isBlank(canvasParam.p1__c))
        {cp.p1=null;   
        }else {cp.p1=canvasParam.p1__c;}
        if (String.isBlank(canvasParam.p2__c))
        {cp.p2=null;   
        }else {cp.p2=canvasParam.p2__c;}
        if (String.isBlank(canvasParam.p3__c))
        {cp.p3=null;   
        }else {cp.p3=canvasParam.p3__c;}   
        system.debug(objectName+' '+recId);
        
        if(objectName=='Case' && recId!=null && recId!='' )	
        {
            Case cs = [Select Company_of__c,Type,CaseNumber
                       FROM Case Where Id=:recId];
            cp.p1 = cs.Company_of__c;
            cp.p2 = cs.Type;
            cp.p3 = cs.CaseNumber;
            System.debug(cs.Company_of__c);
            System.debug(cs.Type);
            System.debug(cs.CaseNumber);
        }
        if(objectName=='MIS__c' && recId!=null && recId!='' )
        {
            MIS__c m = [Select Company_Of__c,Unique_MIS__c
                        FROM MIS__c Where Id=:recId];
            cp.p1 = m.Company_of__c;
            cp.p2 = m.Unique_MIS__c;
            System.debug(m.Company_of__c);
            System.debug(m.Unique_MIS__c);
        }
        return cp;
    }
    
    public class CanvasParametersCMS{
        @AuraEnabled
        public String puser{get;set;}
        @AuraEnabled
        public String requid{get;set;}  
        @AuraEnabled
        public String authorization{get;set;}   
        @AuraEnabled
        public String action{get;set;}  
        @AuraEnabled
        public String cid{get;set;}			
        @AuraEnabled
        public String p1{get;set;}  
        @AuraEnabled
        public String p2{get;set;}  
        @AuraEnabled
        public String p3{get;set;}  
        @AuraEnabled
        public String p4{get;set;}  	
    }
}