trigger extensionTrigger on ContentVersion (after insert , after update) {
    String ext = '';
    set<String> setExtAllowed = new set<String> {'pdf','jpg'};
    for (ContentVersion cv :Trigger.new) {
        ContentDocumentLink cdlsList = [select id,LinkedEntityid,LinkedEntity.type from ContentDocumentLink where ContentDocumentId = :cv.ContentDocumentId order by LinkedEntityid desc limit 1];
        system.debug(cv.FileType);
         system.debug(cv.ContentDocumentId);
         system.debug(cdlsList);
       
        String filename = cv.PathOnClient.toLowerCase();
          List<String> splits = filename.split('\\.');
            ext = splits.get(splits.size()-1);
            
        if(!setExtAllowed.Contains(splits[splits.size()-1]) && cdlsList.LinkedEntity.type=='Case' ) {
                cv.addError('File with extension exe or dll could not be attached!!');
            }

    }

}