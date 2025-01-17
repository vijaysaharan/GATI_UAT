trigger CCECTrigger on CCEC__c (before insert,after insert,before update, after update) {
    
    List<String> ccecIds = new List<String>();
    
    for(CCEC__c ccec : Trigger.new){
        ccecIds.add(ccec.Id);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        ManualCCECOutboundAPI.SendCCEC(ccecIds);
    }
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        //CCECHelper.caseAutoClose(Trigger.new);
    }
}