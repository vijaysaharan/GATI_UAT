public class VoiceBlastCallout implements Queueable, Database.AllowsCallouts {
    private List<Case> caseList;
    
    public VoiceBlastCallout(List<Case> caseList) {
        this.caseList = caseList;
    }
    
    public void execute(QueueableContext context) {
        String hashkey = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').hash_key__c;
        String endpoint = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').endpoint__c;
        String host = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').host__c;
        String policyname = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').policy_name__c;
        String reqhost = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').requesting_host__c;
        String contenttype = AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').content_type__c;        
        List<Map<String, Object>> caseListObject = new List<Map<String, Object>>();
        Map<String, AmeyoProcessName__mdt> codeToProcessName = new Map<String, AmeyoProcessName__mdt>();
        List<AmeyoProcessName__mdt> processNames = [SELECT Id, DeveloperName, Code__c, Process__c, Reason__c FROM AmeyoProcessName__mdt];
        
        if(processNames != null && processNames.size() > 0){
            for(AmeyoProcessName__mdt apn : processNames){
                codeToProcessName.put(apn.Code__c, apn);
            }
        }
        
        for(Case caseRecord : caseList){
            if(codeToProcessName.containsKey(caseRecord.NDR_Code__c)){
                caseListObject.add(new Map<String, Object>{
                    'customerRecord' => new Map<String, Object>{
                        'process' => codeToProcessName.get(caseRecord.NDR_Code__c).Process__c,
                            'sf_id' => caseRecord.Id,
                            'phone1' => caseRecord.ContactPhone,
                            'vb_id' => caseRecord.Id,
                            'dly_attempted_date' => null,
                            'Pickup_Date__c' => caseRecord.Pickup_Date__c,
                            'pickup_attempted_date' => null,
                            'mobileno' => caseRecord.ContactMobile,
                            'pickup_refno' => caseRecord.Case_Name__c,
                            'reason_code' => caseRecord.NDR_Code__c,
                            'delivery_ou' => caseRecord.Delivery_OU__r.Name,
                            'ops_reason' => codeToProcessName.get(caseRecord.NDR_Code__c).Reason__c,
                            'customername' => caseRecord.Contact.Name,
                            'docket_no' => caseRecord.Docket_Number__c
                            }
                });
            }
        }
        
        if(caseListObject != null && caseListObject.size() > 0){
            String payload = JSON.serialize(new Map<String, Object>{
                'campaignId' => 84,
                    'customerAndCallbackRecords' => caseListObject,
                    'leadId' => 10776,
                    'properties' => new Map<String, Boolean>{
                        'update.customer' => true,
                            'migrate.customer' => true
                            }
            });
            
            HttpRequest req = new HttpRequest();
            req.setHeader('hash-key',hashkey);
            req.setHeader('host',host);
            req.setHeader('policy-name',policyname);
            req.setHeader('requesting-host',reqhost);
            req.setHeader('Content-Type',contenttype);
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setBody('data='+payload);  
            System.debug('Request Body '+payload);        
            Http http = new Http();
            HttpResponse res = http.send(req); 
            
            Ameyo_Voice_Blast_Detail__c integrationLog = new Ameyo_Voice_Blast_Detail__c();
            integrationLog.InboundJSON__c = payload;
            integrationLog.OutboundJSON__c = res.getBody();
            Database.insert(integrationLog,false);
        }
    }
}