public class ContentCaseDocument {
    public static void checkimagecountlink(Map<Id, ContentDocumentLink> newmap){
        Integer inc = 0;
        System.debug('ContentDocument'+newmap);
        List<ContentDocumentLink> attch=[SELECT Id, LinkedEntityid, LinkedEntity.Type, ContentDocument.Title FROM ContentDocumentLink WHERE Id IN: newmap.keyset()]; 
        map<id,integer> parentvscount= new map<id,integer>();
        for(ContentDocumentLink ah : attch){
            if( ah.LinkedEntity.type=='Case' && (ah.ContentDocument.title.equalsIgnoreCase('Docket copy') || ah.ContentDocument.title.equalsIgnoreCase('invoice') || ah.ContentDocument.title.equalsIgnoreCase('claim letter'))){
                if(parentvscount.containsKey(ah.LinkedEntityid)){
                    parentvscount.put(ah.LinkedEntityid,parentvscount.get(ah.LinkedEntityid)+1);
                }
                else{
                    parentvscount.put(ah.LinkedEntityid,1);
                }
            }
        }
        
        if(parentvscount.keyset().size()>0 ){
            List<Case> updatedOppoList = new List<Case>();
            List<Case> oppoList= [SELECT Id, Total_Upload__c FROM Case WHERE Id IN: parentvscount.keyset()];
            for(Case oppo : oppoList){ 
                if(parentvscount.containskey(oppo.id)){
                    if(oppo.Total_Upload__c>0){
                        oppo.Total_Upload__c= oppo.Total_Upload__c+parentvscount.get(oppo.id);   
                    }
                    else{
                        oppo.Total_Upload__c=parentvscount.get(oppo.id);
                    }
                    updatedOppoList.add(oppo);
                }
            }
            if(updatedOppoList.size()>0){
                update updatedOppoList;
            }
        }
    }
    
    public static void ondeletecontentDocument(Map<Id,contentDocument> newmap){
        List<ContentDocumentLink> attch=[SELECT Id, LinkedEntityid, LinkedEntity.Type, ContentDocument.Title FROM ContentDocumentLink WHERE contentdocumentid IN: newmap.keyset()];        
        Map<Id,Integer> parentvscount= new Map<Id,Integer>();
        for(ContentDocumentLink ah : attch){
            if( ah.LinkedEntity.type=='Case' && (ah.ContentDocument.title.equalsIgnoreCase('Docket copy') || ah.ContentDocument.title.equalsIgnoreCase('Claim letter') || ah.ContentDocument.title.equalsIgnoreCase('Invoice'))){
                if(parentvscount.containsKey(ah.LinkedEntityid)){
                    parentvscount.put(ah.LinkedEntityid,parentvscount.get(ah.LinkedEntityid)+1);
                }
                else{
                    parentvscount.put(ah.LinkedEntityid,1);
                }
            }
        }
        if(parentvscount.keyset().size()>0){
            List<Case> updatedOppoList= new List<Case>();
            List<Case> oppoList= [SELECT Id, Total_Upload__c FROM Case WHERE Id IN: parentvscount.keyset()];
            system.debug(oppoList);
            for(Case oppo:oppoList){ 
                if(parentvscount.containskey(oppo.id)){
                    if(oppo.Total_Upload__c>0){
                        oppo.Total_Upload__c= oppo.Total_Upload__c-parentvscount.get(oppo.id);
                    }
                    else{
                        oppo.Total_Upload__c=0;
                    }
                    updatedOppoList.add(oppo);
                }
            }
            if(updatedOppoList.size()>0){
                update updatedOppoList;
            }
        }
    }
}