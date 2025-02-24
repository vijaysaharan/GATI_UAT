public class EmailMessageTriggerHandler {
    public static void updateFirstResponseOnCase(Set<Id> caseIds){
        List<Case> caseList = [SELECT Id,First_Email_Response__c From Case Where Id IN: caseIds And First_Email_Response__c = null];
        if(caseList != null && caseList.size()>0){
            For(Case cs :caseList){
                cs.First_Email_Response__c = System.now();
            }
            update caseList;
        }
    }
    
    public static void updateEmailAddressInCase(Map<Id,EmailMessage> caseToEmailMessage){
        Boolean isUpdate = false;
        List<Case> caseList = [SELECT Id,Email_Address_For_Assignment__c,OwnerId 
                               FROM Case 
                               WHERE Id IN: caseToEmailMessage.keySet() 
                               AND Email_Address_For_Assignment__c = null
                              ];
        if(caseList != null && caseList.size()>0){
            for(Case cs : caseList){
                if(caseToEmailMessage.containsKey(cs.Id)){
                 	List<String> emailList = caseToEmailMessage.get(cs.Id).ToAddress.split(';');
                    if(caseToEmailMessage.get(cs.Id).CcAddress != null){
                        emailList.addAll(caseToEmailMessage.get(cs.Id).CcAddress.split(';'));
                    }
                    if(caseToEmailMessage.get(cs.Id).BccAddress != null){
                        emailList.addAll(caseToEmailMessage.get(cs.Id).BccAddress.split(';'));
                    }
                    String emailToCheck = '';
                    for(String em : emailList){
                        if(em.contains('@allcargologistics.com') || em.contains('@gati')){
                            emailToCheck = em.trim();
                            break;
                        }
                    }
                    cs.Email_Address_For_Assignment__c = emailToCheck;  
                    isUpdate = true; 
                }
            }
            if(isUpdate){
                update caseList;
            }
        }
    }
    
    public static void createNewCaseForClosedCase(List<EmailMessage> emailMessageList){
        Set<Id> caseIds = new Set<Id>();
        Set<String> caseSubjects = new Set<String>();
        Set<String> caseFromAddresses = new Set<String>();
        Map<Id, EmailMessage> caseIdToEmailMessage = new Map<Id, EmailMessage>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        Map<Id, Case> newCasesToInsert = new Map<Id, Case>();
        List<EmailMessage> emailMessageToUpdate = new List<EmailMessage>();
        List<Case> subjectAddressCases = new List<Case>();
        Map<String, Case> subjectAddressToCases = new Map<String, Case>();
        
        for(EmailMessage em : emailMessageList){
            if(em.Incoming == true && em.ParentId != null && String.valueOf(em.ParentId).contains('500')){
                caseIds.add(em.ParentId);
                caseSubjects.add(em.Subject.trim());
                caseFromAddresses.add(em.FromAddress.trim());
            }
        }
        
        if(caseIds != null && caseIds.size() > 0){
            oldCases = new Map<Id,Case>([SELECT Id, Subject, Status, SuppliedEmail FROM Case WHERE Id IN :caseIds]);
        }
        
        if(caseFromAddresses != null && caseFromAddresses.size() > 0 && caseSubjects != null && caseSubjects.size() > 0){
            subjectAddressCases = [SELECT Id, Subject, SuppliedEmail FROM Case WHERE Subject IN :caseSubjects AND SuppliedEmail IN :caseFromAddresses AND Status != 'Closed'];
        }
        
        if(subjectAddressCases != null && subjectAddressCases.size() > 0){
            for(Case cs : subjectAddressCases){
                subjectAddressToCases.put(cs.Subject+'-'+cs.SuppliedEmail, cs);
            }
        }
        
        for(EmailMessage em : emailMessageList){
            if(oldCases.containsKey(em.ParentId) && oldCases.get(em.ParentId).Status == 'Closed' && !subjectAddressToCases.containsKey(em.Subject.trim()+'-'+em.FromAddress.trim())){
                caseIdToEmailMessage.put(em.ParentId, em);
            }
            else if(oldCases.containsKey(em.ParentId) && oldCases.get(em.ParentId).Status == 'Closed' && subjectAddressToCases.containsKey(em.Subject.trim()+'-'+em.FromAddress.trim())){
                em.ParentId = subjectAddressToCases.get(em.Subject+'-'+em.FromAddress).Id;
            }
        }
        
        if(caseIdToEmailMessage != null && caseIdToEmailMessage.keySet().size() > 0){
            for(Id caseId : caseIdToEmailMessage.keySet()){
                Case newCase = oldCases.get(caseId).clone(false, true, false, false);
                newCase.Status = 'New';
                newCase.Subject = caseIdToEmailMessage.get(caseId).Subject;
                newCasesToInsert.put(caseId, newCase);
            }
        }
        
        if(newCasesToInsert != null && newCasesToInsert.values().size() > 0){
            insert newCasesToInsert.values();
        }
        
        if(caseIdToEmailMessage != null && caseIdToEmailMessage.keySet().size() > 0){
            for(Id caseId : caseIdToEmailMessage.keySet()){
                EmailMessage em = caseIdToEmailMessage.get(caseId);
                em.ParentId = newCasesToInsert.containsKey(caseId) ? newCasesToInsert.get(caseId).Id : caseId;
                emailMessageToUpdate.add(em);
            }
        }
        
        if(emailMessageToUpdate != null && emailMessageToUpdate.size() > 0){
            Database.update(emailMessageToUpdate, false);
        }
    }
}