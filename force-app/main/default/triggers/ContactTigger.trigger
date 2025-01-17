trigger ContactTigger on Contact (before insert, after insert, before update, after update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ContactTiggerHelper.duplicateContact(Trigger.new);
    } 
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ContactTiggerHelper.employeeMasterCreationonInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            ContactTiggerHelper.employeeMasterCreationonUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    if(Trigger.isAfter &&  Trigger.isUpdate){
        ContactTiggerHelper.processResignedContacts(Trigger.new);
    }
}