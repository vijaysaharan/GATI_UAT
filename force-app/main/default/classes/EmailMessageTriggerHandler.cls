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
        System.debug('caseToEmailMessage'+caseToEmailMessage);
        Boolean isUpdate = false;
        List<Case> caseList = [SELECT Id,Email_Address_For_Assignment__c,OwnerId 
                               FROM Case 
                               WHERE Id IN: caseToEmailMessage.keySet() 
                               AND Email_Address_For_Assignment__c = null
                              ];
        if(caseList != null && caseList.size()>0){
            for(Case cs : caseList){
                if(caseToEmailMessage.containsKey(cs.Id)){
                 	/*List<String> emailList = caseToEmailMessage.get(cs.Id).ToAddress.split(';');
                    String emailToCheck = '';
                    for(String em : emailList){
                        if(em.contains('@allcargologistics.com')){
                            emailToCheck = em.trim();
                            break;
                        }
                    }*/
                    cs.Email_Address_For_Assignment__c = caseToEmailMessage.get(cs.Id).ToAddress;  
                    isUpdate = true; 
                }
            }
            if(isUpdate){
                update caseList;
            }
        }
    }
}