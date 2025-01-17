trigger EmailMessageTrigger on EmailMessage (after insert,before insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        Set<Id> CaseIds = New Set<Id>();
        Map<Id,EmailMessage> emailIdToUpdateOnCase = New Map<Id,EmailMessage>();
        for(EmailMessage em : Trigger.New){
            if(em.Incoming == false && em.ParentId != null && String.valueOf(em.ParentId).contains('500')){
                CaseIds.add(em.ParentId);
            }
            if(em.Incoming == true && em.ParentId != null && String.valueOf(em.ParentId).contains('500') && em.ToAddress != null){
                emailIdToUpdateOnCase.put(em.ParentId,em);
            }
        }
        if(CaseIds != null && CaseIds.size()>0){
            EmailMessageTriggerHandler.updateFirstResponseOnCase(CaseIds);
        }
        if(emailIdToUpdateOnCase != null && emailIdToUpdateOnCase.size()>0){
            EmailMessageTriggerHandler.updateEmailAddressInCase(emailIdToUpdateOnCase);
        }
    }
    /*
    if(Trigger.isBefore && Trigger.isInsert){
        try{
            for(EmailMessage em : Trigger.New){
                if(em.Incoming == true && em.ParentId != null && String.valueOf(em.ParentId).contains('500') && em.FromAddress == 'noreply@gatikwe.com' && em.Subject.contains('Case transferred to you')){
                    em.addError('STOP RECURSTION OF CASE ASSIGNMENT MAIL');
                }
            }
        }catch(Exception e){}
    }*/
}