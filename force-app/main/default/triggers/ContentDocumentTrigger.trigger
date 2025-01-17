trigger ContentDocumentTrigger on ContentDocument (before delete) {
 if(trigger.isbefore && trigger.isdelete)
    {
        ContentOppoDocument.ondeletecontentDocument(trigger.oldmap);
        ContentAccountDocument.ondeletecontentDocument(trigger.oldmap);
        ContentCaseDocument.ondeletecontentDocument(trigger.oldmap);
        contentdocumentlinktriggerhelper.documentdelete(trigger.oldmap);
    }
    
    
}