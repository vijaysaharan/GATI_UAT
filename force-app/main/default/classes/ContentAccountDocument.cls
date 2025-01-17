public with sharing class ContentAccountDocument {
    
    public static void checkimagecountlink(map<id, ContentDocumentLink> newmap)
    {
        
        list<ContentDocumentLink> attch=[select id,LinkedEntityid,LinkedEntity.type,ContentDocument.title from ContentDocumentLink where id in:newmap.keyset()];        
        map<id,integer>uploadsvscount= new map<id,integer>();
        for(ContentDocumentLink ah:attch)
        {
            if( ah.LinkedEntity.type=='Account' && ah.ContentDocument.title.Contains('Extension'))
            {
                if(uploadsvscount.containsKey(ah.LinkedEntityid))
                {
                    uploadsvscount.put(ah.LinkedEntityid,uploadsvscount.get(ah.LinkedEntityid)+1);
                }
                else
                {
                    uploadsvscount.put(ah.LinkedEntityid,1);
                }
            }
            system.debug(uploadsvscount);
            if(uploadsvscount.keyset().size()>0)
            {
                list <Account> updatedAccountList= new list<Account>();
                list<Account> accountList= [select id,Uploads__c from Account where id in:uploadsvscount.keyset()];
                system.debug(accountList);
                for(Account acc:accountList)
                { 
                    if(uploadsvscount.containskey(acc.id))
                    {
                        if(acc.Uploads__c>0){
                            acc.Uploads__c= acc.Uploads__c+uploadsvscount.get(acc.id);
                        }
                        else
                        {
                            acc.Uploads__c=uploadsvscount.get(acc.id);
                        }
                        updatedAccountList.add(acc);
                        
                    }
                }
                if(updatedAccountList.size()>0)
                {
                    update updatedAccountList;
                }
                
            }
        }
    }
    
    public static void ondeletecontentDocument(map<id,contentDocument> newmap)
    {
        list<ContentDocumentLink> attch=[select id,ContentDocument.title,LinkedEntityid,LinkedEntity.type from ContentDocumentLink where contentdocumentid in:newmap.keyset()];        
        map<id,integer>uploadsvscount= new map<id,integer>();
        for(ContentDocumentLink ah:attch)
        {
            if( ah.LinkedEntity.type=='Account' && ah.ContentDocument.title.Contains('Extension'))
            {
                if(uploadsvscount.containsKey(ah.LinkedEntityid))
                {
                    uploadsvscount.put(ah.LinkedEntityid,uploadsvscount.get(ah.LinkedEntityid)+1);
                }
                else
                {
                    uploadsvscount.put(ah.LinkedEntityid,1);
                }
            }
            system.debug(uploadsvscount);
            if(uploadsvscount.keyset().size()>0)
            {
                list <Account> updatedAccountList= new list<Account>();
                list<Account> accountList= [select id,Uploads__c from Account where id in:uploadsvscount.keyset()];
                system.debug(accountList);
                for(Account acc:accountList)
                { 
                    if(uploadsvscount.containskey(acc.id))
                    {
                        if(acc.Uploads__c>0)
                            acc.Uploads__c= acc.Uploads__c-uploadsvscount.get(acc.id);
                        else
                        {
                            acc.Uploads__c=0;
                        }
                        updatedAccountList.add(acc);
                        
                    }
                }
                if(updatedAccountList.size()>0)
                {
                    update updatedAccountList;
                }
                
            }
        }
    }
}