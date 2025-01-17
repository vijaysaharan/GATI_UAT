public with sharing class ContentOppoDocument {

    public static void checkimagecountlink(map<id, ContentDocumentLink> newmap)
    {
        
        list<ContentDocumentLink> attch=[select id,LinkedEntityid,LinkedEntity.type,ContentDocument.title from ContentDocumentLink where id in:newmap.keyset()]; 
        map<id,integer> parentvscount= new map<id,integer>();
        for(ContentDocumentLink ah:attch)
        {
                if( ah.LinkedEntity.type=='Opportunity' && ah.ContentDocument.title.Contains('Customer accept'))
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
            list < Opportunity> updatedOppoList= new list<Opportunity>();
            list<Opportunity> oppoList= [select id,Total__c from Opportunity where id in:parentvscount.keyset()];
            for(Opportunity oppo:oppoList)
            { if(parentvscount.containskey(oppo.id))
            {
                if(oppo.Total__c>0)
                oppo.Total__c= oppo.Total__c+parentvscount.get(oppo.id);
                else
                {
                    oppo.Total__c=parentvscount.get(oppo.id);
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
                if( ah.LinkedEntity.type=='Opportunity' && ah.ContentDocument.title.Contains('Customer accept'))
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
            list < Opportunity> updatedOppoList= new list<Opportunity>();
            list<Opportunity> oppoList= [select id,Total__c from Opportunity where id in:parentvscount.keyset()];
            system.debug(oppoList);
            for(Opportunity oppo:oppoList)
            { if(parentvscount.containskey(oppo.id))
            {
                if(oppo.Total__c>0)
                oppo.Total__c= oppo.Total__c-parentvscount.get(oppo.id);
                else
                {
                    oppo.Total__c=0;
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