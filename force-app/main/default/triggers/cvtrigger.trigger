trigger cvtrigger on ContentVersion (before insert,before update) {
    
    Set<Schema.SObjectType> objsPreventImageFiles = new Set<Schema.SObjectType>{
        Case.SObjectType
            };
                Set<String> imageTypes = new Set<String>{'pdf', 'jpg'};  
                    integer i=0;
    try{
    List<Id> contentDocIds = new List<Id>();
    List<ContentVersion> images = new List<ContentVersion>();
    for ( ContentVersion cv : Trigger.new ) {
        
        if ( !imageTypes.contains(cvHelper.getFileExtension(cv.PathOnClient)) ) {
            images.add(cv);
            contentDocIds.add(cv.ContentDocumentId);
        }
    }
     System.debug('line 18'+images);
    if ( !images.isEmpty() ){ 
        Map<Id, List<ContentDocumentLink>> contentDocToLinks = new Map<Id, List<ContentDocumentLink>>();
        
        for(Id cdisingle :contentDocIds)
        {
                List<ContentDocumentLink> cdlsList = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where ContentDocumentId =:cdisingle];
                System.debug(cdlsList);
                for ( ContentDocumentLink cdl : cdlsList ) {
                    System.debug(cdl);
                    if ( !contentDocToLinks.containsKey(cdl.ContentDocumentId) ) {
                        contentDocToLinks.put(cdl.ContentDocumentId, new List<ContentDocumentLink>());
                    }
                    contentDocToLinks.get(cdl.ContentDocumentId).add(cdl);
                }
                
            } 
            
            
            for ( ContentVersion cv : images ) {
                
                List<ContentDocumentLink> cdls = contentDocToLinks.get(cv.ContentDocumentId);
                System.debug(cdls);
                if ( cdls != null ) {
                    for ( ContentDocumentLink cdl : cdls ) {
                        ContentDocumentLink CDLinks=[select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where ContentDocumentId= :cdl.ContentDocumentId];
                        System.debug(CDLinks);
                        Case cc =[Select Id,RecordType.Name from case where id= :CDLinks.LinkedEntityId];
                        System.debug(cc);
                        if ( cdl.LinkedEntityId != null && objsPreventImageFiles.contains(cdl.LinkedEntityId.getSObjectType()) && cc.RecordType.Name=='Claim') {
                            System.debug(cc.RecordType.Name);
                            cv.addError('Please');
                            break;
                        } 
                    }
                }
            }
        }
    } 
    Catch(Exception e){
        System.debug(e);
        
    }
        
    }