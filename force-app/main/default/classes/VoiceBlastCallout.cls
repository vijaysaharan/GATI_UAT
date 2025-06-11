public class VoiceBlastCallout implements Queueable, Database.AllowsCallouts {
    private List<Case> caseList;
    
    public VoiceBlastCallout(List<Case> caseList) {
        this.caseList = caseList;
    }
    
    public void execute(QueueableContext context) {
        List<Case> caseToUpdate = new List<Case>();
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
                            'sf_id' => caseRecord.Id,
                            'phone1' => caseRecord.Receiver_Contact_No__c,
                            'vb_id' => caseRecord.Id,
                            'dly_attempted_date' => caseRecord.PDC_DATE__c,                            
                            'ndr_code' => caseRecord.NDR_Code__c,
                            'delivery_ou' => caseRecord.Delivery_OU__r.Name,
                            'ndr_reason' => codeToProcessName.get(caseRecord.NDR_Code__c).Reason__c,
                            'docket_no' => caseRecord.Docket_Number__c,
                            'process' => codeToProcessName.get(caseRecord.NDR_Code__c).Process__c,
                            'reason_code' => caseRecord.NDR_Code__c
                            }
                });
            }
        }
        
        if(caseListObject != null && caseListObject.size() > 0){
            String payload = JSON.serialize(new Map<String, Object>{
                'campaignId' => 84,
                    'customerAndCallbackRecords' => caseListObject,
                    'leadId' => 10776,
                    'attempts'=> 0,
                    'status'=> 'NOT_TRIED',
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
            req.setTimeout(120000);
            req.setMethod('POST');
            req.setBody('data='+payload);       
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if(res.getStatusCode() == 200){
                for(Case eachCase : caseList){
                    Case updatableCase = eachCase.clone(false, true, false, false);
                    updatableCase.Id = eachCase.Id;
                    updatableCase.IsVoiceBlast__c = true;
                    caseToUpdate.add(updatableCase);
                }
            }
            
            if(!caseToUpdate.isEmpty()){
                Database.update(caseToUpdate, false);
            }

            Ameyo_Voice_Blast_Detail__c integrationLog = new Ameyo_Voice_Blast_Detail__c();
            integrationLog.InboundJSON__c = payload;
            integrationLog.OutboundJSON__c = res.getBody();
            Database.insert(integrationLog,false);
        }
    }
}