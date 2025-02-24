public class ContentCaseDocument {
    

    public static void checkimagecountlink(map<id, ContentDocumentLink> newmap)
    {
        integer inc=0;
        list<ContentDocumentLink> attch=[select id,LinkedEntityid,LinkedEntity.type,ContentDocument.title from ContentDocumentLink where id in:newmap.keyset()]; 
        map<id,integer> parentvscount= new map<id,integer>();
        for(ContentDocumentLink ah:attch)
        {
                
                if( ah.LinkedEntity.type=='Case' && (ah.ContentDocument.title.equalsIgnoreCase('Docket copy') || ah.ContentDocument.title.equalsIgnoreCase('invoice') || ah.ContentDocument.title.equalsIgnoreCase('claim letter')))
        {
            
            if(parentvscount.containsKey(ah.LinkedEntityid))
            {
                parentvscount.put(ah.LinkedEntityid,parentvscount.get(ah.LinkedEntityid)+1);
            }
            else
            {
                parentvscount.put(ah.LinkedEntityid,1);
            }
        }
         
        }
       
        if(parentvscount.keyset().size()>0 )
        {
            list < Case> updatedOppoList= new list<Case>();
            list<Case> oppoList= [select id,Total_Upload__c  from Case where id in:parentvscount.keyset()];
            for(Case oppo:oppoList)
            { if(parentvscount.containskey(oppo.id))
            {
                if(oppo.Total_Upload__c>0)
                oppo.Total_Upload__c= oppo.Total_Upload__c+parentvscount.get(oppo.id);
                else
                {
                    oppo.Total_Upload__c=parentvscount.get(oppo.id);
                }
                updatedOppoList.add(oppo);
                
            }
            }
            if(updatedOppoList.size()>0)
            {
                update updatedOppoList;
            }
            
        }
    }
    
    public static void ondeletecontentDocument(map<id,contentDocument> newmap)
    {
        list<ContentDocumentLink> attch=[select id,LinkedEntityid,LinkedEntity.type,ContentDocument.title  from ContentDocumentLink where contentdocumentid in:newmap.keyset()];        
        map<id,integer> parentvscount= new map<id,integer>();
        for(ContentDocumentLink ah:attch)
        {
                if( ah.LinkedEntity.type=='Case' && (ah.ContentDocument.title.equalsIgnoreCase('Docket copy') || ah.ContentDocument.title.equalsIgnoreCase('Claim letter') || ah.ContentDocument.title.equalsIgnoreCase('Invoice')))
        {
            if(parentvscount.containsKey(ah.LinkedEntityid))
            {
                parentvscount.put(ah.LinkedEntityid,parentvscount.get(ah.LinkedEntityid)+1);
            }
            else
            {
                parentvscount.put(ah.LinkedEntityid,1);
            }
        }
         
        }
        if(parentvscount.keyset().size()>0)
        {
            list < Case> updatedOppoList= new list<Case>();
            list<Case> oppoList= [select id,Total_Upload__c from Case where id in:parentvscount.keyset()];
            system.debug(oppoList);
            for(Case oppo:oppoList)
            { if(parentvscount.containskey(oppo.id))
            {
                if(oppo.Total_Upload__c>0)
                oppo.Total_Upload__c= oppo.Total_Upload__c-parentvscount.get(oppo.id);
                else
                {
                    oppo.Total_Upload__c=0;
                }
                updatedOppoList.add(oppo);
                
            }
            }
            if(updatedOppoList.size()>0)
            {
                update updatedOppoList;
            }
            
        }
        
    }
}