public class cvhandler {
    public static void handlermethod(map<id,ContentDocumentLink> newmap){
	Set<String> imageTypes = new Set<String>{'pdf', 'jpg'};  
      List<string> list1 = new list<string>();
    list1.add('Case');
    list<ContentDocumentLink> attch=[select id,LinkedEntityid,LinkedEntity.type from ContentDocumentLink where id in:newmap.keyset()];
	system.debug(attch);
        for(ContentDocumentLink cdl : attch)
        {
            list<ContentVersion> cvs=[select id,PathOnClient from ContentVersion where ContentDocumentId=:cdl.ContentDocumentId];
            
            for(ContentVersion cv : cvs)
            {
                if(cdl.LinkedEntity.type=='Case' &&  !imageTypes.contains(cvHelper.getFileExtension(cv.PathOnClient)))
                {
                    
                }
            
            }
            
        }
    }
}