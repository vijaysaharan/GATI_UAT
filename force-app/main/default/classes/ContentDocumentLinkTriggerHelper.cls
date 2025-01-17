public class ContentDocumentLinkTriggerHelper {
    public static void countCOfiles(List<contentdocumentlink> cdls, Set<Id> deleteddocids){
        Set<Id> COids = new Set<Id>();
        for (contentdocumentlink cdl: cdls){
            //does the contentDocumentLink that was just added/update/deleted link to our custom object? Replace ### below with the 3-character id prefix for your custom object
            if(string.valueof(cdl.linkedentityid).left(3)=='006'){
                COids.add(cdl.linkedentityid);
            }
        }
        if(COids.size()>0){
            list<Opportunity> PSAs = [Select id, Document_Count__c from Opportunity where id in :COids];
            map<id,integer> attachmentcounts = CountAttachedFiles.countfiles(COids, deleteddocids);
            for(Opportunity CO: PSAs){
                CO.Document_Count__c = attachmentcounts.get(CO.id);
            }
            update PSAs;
        }
    }
    
    public static void documentdelete (Map<Id,contentdocument> cdmap){
        //used in the contentdocument trigger, essential to handle the delete function
        set<id> deleteddocids = cdmap.keySet();
        list<contentdocumentlink> cdls = [select id, linkedentityid from contentdocumentlink where contentdocumentid in :deleteddocids];
        
        countCOfiles(cdls, deleteddocids);
    }
    
    public static void updateallCOs(){
        //this is here to allow us to play catch-up and update all the PSAs with current document counts
        list<Opportunity> COs = [Select id, Document_Count__c from Opportunity];
        set<id> COids = new set<id>();
        for(Opportunity CO: COs){
            COids.add(CO.id);
        }
        
        list<contentdocumentlink> cdls = [Select id, linkedentityid from contentdocumentlink where linkedentityid in :COids];
        
        countCOfiles(cdls,null);
    }
}