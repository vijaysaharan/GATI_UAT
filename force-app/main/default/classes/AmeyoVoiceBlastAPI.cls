public class AmeyoVoiceBlastAPI {
    public static void voiceBlast(String vbid){
        Ameyo_Voice_Blast_Detail__c avbd = [select id,Process__c,Mobile_no__c,SF_ID__c,Reason__c,Reason_code__c,Docket_No__c,Customer_Name__c,Delivery_OU__c,Dly_Attempted_Date__c,
                                            Pick_Ref_no__c,Pickup_Attempted_Date__c,Pickup_Date_time__c from Ameyo_Voice_Blast_Detail__c where id = :vbid];
        Payload reqBody = new Payload();
        customerrec crec = new customerrec();
        
        reqBody.campaignId = 84;
        reqBody.leadId = 10776;
        crec.vb_id = avbd.id;
        crec.process = avbd.Process__c;
        //crec.phone1 = avbd.Mobile_no__c;
        crec.mobileno = avbd.Mobile_no__c;
        crec.sf_id = avbd.SF_ID__c;
        crec.docket_no = avbd.Docket_No__c;
        crec.reason_code = avbd.Reason_code__c;
        crec.pickup_datetime = String.valueOf(avbd.Pickup_Date_time__c);
        crec.pickup_attempted_date = String.valueOf(avbd.Pickup_Attempted_Date__c);
        crec.dly_attempted_date = String.valueOf(avbd.Dly_Attempted_Date__c);
        crec.customername = avbd.Customer_Name__c;
        String Reason = avbd.Reason__c;
        crec.ops_reason = reason;
        crec.vdelivery_ou = avbd.Delivery_OU__c;
        crec.pickup_refno = avbd.Pick_Ref_no__c;
        callback custDet = new callback();
        custdet.customerRecord = crec;
        reqBody.customerAndCallbackRecords.add(custDet);
        map<string,boolean> property = new map<string,boolean>();
        property.put('update.customer',true);
        property.put('migrate.customer',true);
        reqBody.properties = property;
        
        Http http = new Http(); 
        HttpRequest req = new HttpRequest();
        String hashkey = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').hash_key__c;
        String endpoint = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').endpoint__c;
        String host = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').host__c;
        String policyname = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').policy_name__c;
        String reqhost = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').requesting_host__c;
        string contenttype = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').content_type__c;
        req.setHeader('hash-key',hashkey);
        req.setHeader('host',host);
        req.setHeader('policy-name',policyname);
        req.setHeader('requesting-host',reqhost);
        req.setHeader('Content-Type',contenttype);
        req.setEndpoint(endpoint);
        String body = Json.serialize(reqBody);
        system.debug(reqBody.customerAndCallbackRecords[0].customerRecord);
        //string body = '{"campaignId":84,"customerAndCallbackRecords":[{"customerRecord":{"vb_id":"123456789abc","process":"NDR","sf_id":"123454","phone1":"9958617595"}},{"customerRecord":{"vb_id":"123456789xyz","process":"NDR","sf_id":"123454","phone1":"9561011781"}},{"customerRecord":{"vb_id":"123456789fabc","process":"NDR","sf_id":"123454","phone1":"9999999999"}}],"leadId":10776,"properties":{"update.customer":true,"migrate.customer":true}}';
        req.setBody('data='+body);
        req.setMethod('POST');
        req.setTimeout(12000);
        system.debug(req);
        HttpResponse res= http.send(req);
        System.debug('result: '+res);
        System.debug('result body: '+res.getBody());
    }
    
    public class Payload{
        public Integer campaignId{get;set;}
        public Integer leadId{get;set;}
        public List<callback> customerAndCallbackRecords = new List<callback>();
        public map<string,boolean> properties = new map<string,boolean>();
    } 
   
    public class callback{
        public customerrec customerRecord = new customerrec();
    }
    public class customerrec{
        public string vb_id{get;set;}
        public string process{get;set;}
        public string sf_id{get;set;}
        public string phone1{get;set;}
        public string docket_no{get;set;}
        public string customername{get;set;}
        public string pickup_datetime{get;set;}
        public string pickup_attempted_date{get;set;}
        public string dly_attempted_date{get;set;}
        public string mobileno{get;set;}
        public string reason_code{get;set;}
        public string ops_reason{get;set;}
        public string vdelivery_ou{get;set;}
        public string pickup_refno{get;set;}
        public string timezone = '';
    }
}