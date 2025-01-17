trigger lstAttachementTobeRestricted on Attachment (before insert, before update){
   
    System.debug('ATT trigger');
   
    String ext = '';
    set<String> setExtNotAllowed = new set<String> {'txt','dll'};
    for (Attachment attachment :Trigger.new) {
        String filename = attachment.Name.toLowerCase();
          List<String> splits = filename.split('\\.');
            ext = splits.get(splits.size()-1);
            if(setExtNotAllowed.Contains(splits[splits.size()-1])) {
                attachment.addError('File with extension exe or dll could not be attached!!');
            }
    }
}