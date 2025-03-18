trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert,after update, after delete) {
    system.debug('In trigger');
    //ContentOppoDocument.checkimagecountlink(trigger.newmAP);
    ///ContentAccountDocument.checkimagecountlink(trigger.newmAP);
    ContentCaseDocument.checkimagecountlink(trigger.newmap);
    
    if(trigger.isafter && (trigger.isupdate || trigger.isinsert)){
        contentdocumentlinktriggerhelper.countCOfiles(trigger.new,null);
    }
    if(trigger.isafter && trigger.isdelete){
        contentdocumentlinktriggerhelper.countCOfiles(trigger.old,null);
    }
    
}