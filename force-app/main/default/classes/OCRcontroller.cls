public  with sharing class OCRcontroller {
    public static FINAL String  OCR_API         = 'https://api.einstein.ai/v2/vision/ocr';
    public static FINAL String  OCR_MODEL       = 'OCRModel';
    public static FINAL String  OCR_MODEL_TABEL = 'tabulatev2';
    @auraEnabled
    public static AuraResponseWrapper callserver(id versionid,id docid)
    {
        try{ContentVersion content = [SELECT Title,VersionData FROM 
                                      ContentVersion 
                                      where id =:versionid 
                                      LIMIT 1];
            
            String sample = EncodingUtil.base64Encode(content.VersionData);
            String result = EinsteinAPIService.imageOCR(OCR_API, sample, OCR_MODEL, true, true); 
            EinsteinOCRResponse response = (EinsteinOCRResponse)System.JSON.deserialize(result, EinsteinOCRResponse.class);
            Lead a= new Lead();
            SObject sobjectRecord = Schema.getGlobalDescribe().get('Lead').newSObject() ;
            sobjectRecord.put('LeadSource','OCR');
            list<AuraResponseWrapper>  data=new list<AuraResponseWrapper> ();
            for(EinsteinOCRResponse.Probabilities prob : response.probabilities)
            {AuraResponseWrapper datas= new AuraResponseWrapper();
             datas.response=prob.attributes.tag;
             datas.result=prob.label;
             data.add(datas);
                //system.debug('prob'+ prob);
             
                switch on prob.attributes.tag {
                    when 'PERSON' {
                        sobjectRecord.put('LastName',prob.label);
                    }
                    when 'PHONE' {
                        sobjectRecord.put('Phone',prob.label);
                    }
                    when 'MOBILE_PHONE'{
                        sobjectRecord.put('MobilePhone',prob.label);
                    }
                    when 'EMAIL'{
                        sobjectRecord.put('EMAIL',prob.label);
                    }
                    when 'WEBSITE' {
                        
                        sobjectRecord.put('Website',prob.label);
                        
                    }
                    when 'ADDRESS' {
                        
                        sobjectRecord.put('Street',prob.label);
                        
                    }
                    when 'ORG' {
                        
                        sobjectRecord.put('Company',prob.label);
                        
                    }
                    when 'OTHER' {
                        
                        if(prob.label.contains(' ') && !prob.label.isNumeric() && sobjectRecord.get('LastName')==null)
                        {
                           
                            system.debug('tag is '+ prob.attributes.tag+' other');
                            system.debug('label is '+ prob.label +' if');
                            sobjectRecord.put('LastName',prob.label);
                            
                        }
                        
                        if(prob.label.isNumeric())
                        {
                            
                            system.debug('phone +'+prob.label);
                            
                              sobjectRecord.put('MobilePhone',prob.label);
                            
                        }
                        sobjectRecord.put('Company',prob.label);
                           system.debug('tag is '+ prob.attributes.tag);
                system.debug('label is '+ prob.label);
                        
                    }
                    
                }
                
            }
           /* insert sobjectRecord;
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = docid;//Add ContentDocumentId
            cDocLink.LinkedEntityId = sobjectRecord.id;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//, InternalUsers, SharedUsers
            Insert cDocLink;*/
            AuraResponseWrapper wrapper = new AuraResponseWrapper();
            wrapper.data = data;
            
            wrapper.record = sobjectRecord;
            return wrapper;
           }
        Catch(exception e)
        {
            database.delete(docid);
            system.debug(e.getCause()+' '+e.getMessage());
            AuraResponseWrapper wrapper = new AuraResponseWrapper();
            wrapper.response =e.getMessage() ;
            //   wrapper.record = 'error;
            wrapper.result='Error';
            
            return wrapper;
        }
    }
    public class AuraResponseWrapper{
        @auraEnabled
       public list<AuraResponseWrapper> data;
        @auraEnabled
        public string result{get;set;}
        @AuraEnabled
        public string response { get; set; }
        @AuraEnabled	
        public sObject record { get; set; }
    }
}