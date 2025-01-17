public class SmsAlertOutbound implements Database.Batchable<sObject>,Database.AllowsCallouts{
    @InvocableMethod(label='SMSApi') 
    public static void calloutMethod(List<FlowInput> inputs){
        FlowInput objInput = inputs.get(0);
        
        SMSCallOut(objInput.str1,objInput.str2);
    }
    
    public map<id,FlowInput> caseToMessageMap;
    public List<case> caseToSendSms;
    
    public SmsAlertOutbound(map<id,FlowInput> caseToMessageMap,List<case> caseToSendSms){
        this.caseToMessageMap = caseToMessageMap;
        this.caseToSendSms = caseToSendSms;
    }
    
    public Iterable<sobject> start(Database.BatchableContext bc){
        return this.caseToSendSms;
    }
    
    public void execute(Database.BatchableContext bc, List<sobject> caseToSendSms){
        for(sobject c : caseToSendSms){
            SMSCallOut(this.caseToMessageMap.get(c.id).str1,this.caseToMessageMap.get(c.id).str2);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
    
    @future(callout = true)
    public static void SMSCallOut( String num,String msg){
        SMSWrapper reqbody = new SMSWrapper();
        Integration_Log__c Il;
        smsbodyobj msgobj =new smsbodyobj();
        reqbody.messages.add(msgobj);
        
        Http http = new Http();              
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        req.setEndpoint(API_credential__mdt.getInstance('smsApi').Endpoint__c);
        reqbody.ver=SmsAPI__mdt.getInstance('reebookingSms').ver__c; 
        reqbody.key=SmsAPI__mdt.getInstance('reebookingSms').key__c; 
        msgobj.dest.add(num);
        msgobj.send=SmsAPI__mdt.getInstance('reebookingSms').send__c;
        msgobj.text=msg;
        req.setBody(JSON.serialize(reqBody));
        req.setMethod('POST');        
        HttpResponse result= http.send(req);
        
        ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
        Integration_Log__c ic = new Integration_Log__c();
        ic.Component_Name__c='SMS push notification log';
        if(!Test.isRunningTest()){
            ic.Error_Message__c=responseObj.status.get('desc');
        }
        ic.IsIntegration__c=true; 
        ic.Inbound_JSON__c=result.getBody();
        ic.Outbound_JSON__c=JSON.serialize(reqBody);        
        ic.eObject__c = 'Case';
        insert ic;         
    }
    
    public class SMSWrapper{
        public decimal ver{get;set;}
        public String key{get;set;}
        public List<smsbodyobj> messages = new List<smsbodyobj>();
        
    }
    public class smsbodyobj{
        public list<String> dest= new list<String>();
        public String text{get;set;}
        public String send{get;set;}
    }
    public class ResponseWrapper{
        public String ackid; 
        public map<string,string> status = new map<string,string>();        
    }
}