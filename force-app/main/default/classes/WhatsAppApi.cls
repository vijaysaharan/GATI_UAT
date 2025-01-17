public class WhatsAppApi {
    @InvocableMethod(label='WhatsAppApi') 
    public static void calloutMethod(List<FlowInput> inputs){
        /*
        FlowInput objInput = inputs.get(0);
        
       // WhatsAppCallOut(objInput.str1,objInput.str2);
        WhatsAppApiCall w = new WhatsAppApiCall();
        w.mobilenumber = objInput.str1;
        w.templateInfo = objInput.str2;
        System.enqueueJob(w);*/
    }


    
}
    // @future(callout=true)
    // public static void WhatsAppCallOut(String mobilenumber,String templateInfo)
    // {
    //     WhatsAppWrapper reqbody = new WhatsAppWrapper();
    //     Integration_Log__c Il;
        
    //     reqbody.bot_id=WhatsApp__mdt.getInstance('WhatsAppApiData').Bot_Id__c; 
    //     // reqbody.text = '';
    //     reqbody.mobileNumber=mobilenumber;
    //     reqbody.service=WhatsApp__mdt.getInstance('WhatsAppApiData').Service__c; 
    //     reqbody.template_info = templateInfo;
    //     String Authorization = WhatsApp__mdt.getInstance('WhatsAppApiData').Authorization_Id__c;
    //     String[] nameValue= Authorization.split('\\:');
        
    //     Http http = new Http();              
    //     HttpRequest req = new HttpRequest();
        
    //     req.setHeader(nameValue[0],nameValue[1]);
    //     req.setHeader('Content-Type','application/json');
    //     //req.setHeader('accept','application/json');
    //     req.setEndpoint(WhatsApp__mdt.getInstance('WhatsAppApiData').EndPoint__c);
    //     req.setBody(JSON.serialize(reqBody));
    //     req.setMethod('POST');
    //     System.debug(req);
    //     HttpResponse result= http.send(req);
    //     System.debug('result.getBody()=='+result.getBody());  
        
        
    //     ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
        
        
    //     Integration_Log__c ic = new Integration_Log__c();
    //     ic.Component_Name__c='WhatsApp push notification log';
    //     ic.Error_Message__c=responseObj.response_message;
    //     ic.IsIntegration__c=true; 
    //     ic.Inbound_JSON__c=result.getBody();
    //     ic.Outbound_JSON__c=JSON.serialize(reqBody);
        
    //     ic.eObject__c = 'Case';
    //     insert ic; 
        
        
    // }
    // public class WhatsAppWrapper{
    //     public String bot_id{get;set;}
    //     // public String text{get;set;}
    //     public String service{get;set;}
    //     public String mobileNumber{get;set;}
    //     public String template_info{get;set;}
    // }
    
    
    // }
    // public class ResponseWrapper{
    //     public String response_code; 
    //     public String response_message; 
    //     public String msg_id; 
        
    // }
    
//}