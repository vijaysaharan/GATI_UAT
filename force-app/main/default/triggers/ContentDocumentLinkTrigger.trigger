trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert,after update, after delete) {
    ContentCaseDocument.checkimagecountlink(Trigger.newmap);
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        contentdocumentlinktriggerhelper.countCOfiles(Trigger.New,null);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        contentdocumentlinktriggerhelper.countCOfiles(Trigger.old,null);
    }
}