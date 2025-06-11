public class EmailMessageTriggerHandler {
    public static void updateFirstResponseOnCase(List<EmailMessage> emailMessageList){
        Set<Id> caseIds = new Set<Id>();

        for(EmailMessage em : emailMessageList){
            if(em.Incoming == false && em.FromAddress != 'customerservices@allcargologistics.com' && em.ParentId != null && String.valueOf(em.ParentId).contains('500')){
                caseIds.add(em.ParentId);
            }
        }

        if(caseIds.isEmpty()){
            return;
        }

        List<Case> caseList = [SELECT Id,First_Email_Response__c From Case Where Id IN: caseIds And First_Email_Response__c = null];
        if(caseList != null && caseList.size()>0){
            For(Case cs :caseList){
                cs.First_Email_Response__c = System.now();
            }
            update caseList;
        }
    }
    
    public static void updateEmailAddressInCase(List<EmailMessage> emailMessageList){
        Boolean isUpdate = false;
        Map<Id,EmailMessage> caseToEmailMessage = New Map<Id,EmailMessage>();
        try{
            for(EmailMessage em : emailMessageList){
                if(em.Incoming == true && em.ParentId != null && String.valueOf(em.ParentId).contains('500') && em.ToAddress != null){
                    caseToEmailMessage.put(em.ParentId,em);
                }
            }

            if(caseToEmailMessage.keySet().isEmpty()){
                return;
            }

            List<Case> caseList = [SELECT Id,Email_Address_For_Assignment__c,OwnerId 
                                FROM Case 
                                WHERE Id IN: caseToEmailMessage.keySet() 
                                AND Email_Address_For_Assignment__c = null
                                ];

            if(caseList != null && caseList.size()>0){
                Set<String> roundRobinEmails = new Set<String>(Label.RoundRobinEmails.split(','));
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
                            }
                            if(roundRobinEmails.contains(em.trim())){
                                emailToCheck = 'retail_support@allcargologistics.com';
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
        }catch(Exception e){
            Integration_Log__c integrationLog = new Integration_Log__c();
            integrationLog.Component_Name__c = 'Retail_Issue';
            integrationLog.Error_Message__c = e.getMessage();
            insert integrationLog;
        }
    }
    
    public static void createNewCaseForClosedCase(List<EmailMessage> emailMessageList){
        Set<Id> caseIds = new Set<Id>();
        Set<String> caseSubjects = new Set<String>();
        Set<String> caseFromAddresses = new Set<String>();
        Map<Id, EmailMessage> caseIdToEmailMessage = new Map<Id, EmailMessage>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        Map<Id, Case> newCasesToInsert = new Map<Id, Case>();
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
            oldCases = new Map<Id,Case>([SELECT Id, Subject, Status, SuppliedEmail, Company_of__c, Origin, SuppliedPhone,
                                         Customer_Email__c,ContactId,Mobile__c,Customer_Name__c,AccountId,Priority
                                         FROM Case 
                                         WHERE Id IN :caseIds
                                        ]);
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
            }
        }
    }
    
    public static void sendNotificationOnEmailReply(List<EmailMessage> emailMessageList){
        Set<Id> emailMessageIds = new Set<Id>();
        for(EmailMessage em : emailMessageList){
            if(em.Incoming == true && em.ParentId != null && String.valueOf(em.ParentId).contains('500')){
                emailMessageIds.add(em.Id);
            }
        }
        
        if(emailMessageIds.isEmpty()){
            return;
        }  
        
        Id notificationTypeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName='Customer_Email_Reply']?.Id;
        
        if(notificationTypeId == null){
            return;
        }
        
        for(EmailMessage em : [SELECT Id, ParentId, Parent.OwnerId, Subject, Parent.Origin, Parent.CaseNumber FROM EmailMessage WHERE Id IN :emailMessageIds AND Parent.Origin = 'Email']){
            notifyUsers(em, notificationTypeId);
        }
    }
    
    public static void notifyUsers(EmailMessage emailMessageDetail, Id notificationTypeId) {        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();        
        notification.setTitle('New Reply On Case - '+emailMessageDetail.Parent.CaseNumber);
        notification.setBody(emailMessageDetail.Subject);        
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(emailMessageDetail.ParentId);        
        try {
            notification.send(new Set<String>{emailMessageDetail.Parent.OwnerId});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    
    public static void updateAnaliticsOnCase(List<EmailMessage> emailMessageList){
        Set<Id> inboundCaseIds = new Set<Id>();
        Set<Id> outboundCaseIds = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<Case> caseListToUpdate = new List<Case>();
        
        for(EmailMessage em : emailMessageList){
            if(em.Incoming == true && em.ParentId != null && String.valueOf(em.ParentId).contains('500')){
                inboundCaseIds.add(em.ParentId);
            }
            if(em.Incoming == false && em.ParentId != null && String.valueOf(em.ParentId).contains('500')){
                outboundCaseIds.add(em.ParentId);
            }
        }
        
        caseList = [SELECT Id, IsReplied__c, Inbound_Emails__c, Outbound_Emails__c 
                    FROM Case 
                    WHERE (Id IN :inboundCaseIds OR Id IN :outboundCaseIds)
                   ];
        
        if(caseList.isEmpty()){
            return;
        }
        
        for(Case cs : caseList){
            if(inboundCaseIds.contains(cs.Id)){
                cs.IsReplied__c = false;
                cs.Inbound_Emails__c = cs.Inbound_Emails__c != null ? (cs.Inbound_Emails__c + 1) : 1;
                caseListToUpdate.add(cs);
            }
            else if(outboundCaseIds.contains(cs.Id)){
                cs.IsReplied__c = true;
                cs.Outbound_Emails__c = cs.Outbound_Emails__c != null ? (cs.Outbound_Emails__c + 1) : 1;
                caseListToUpdate.add(cs);
            }
        }
        
        if(!caseListToUpdate.isEmpty()){
            Database.update(caseListToUpdate, false);
        }
    }

    public static void verifyStatusChange(List<EmailMessage> emailMessageList, Map<Id, EmailMessage> emailMessageMap){
        List<EmailMessage> emailMessagesToDelete = new List<EmailMessage>();
        
        for(EmailMessage email : emailMessageList){
            if(email.Status == '3' && emailMessageMap.get(email.Id).Status == '5'){
                emailMessagesToDelete.add(email);
            }
        }

        if(!emailMessagesToDelete.isEmpty()){
            deleteOlderEmailMessages(emailMessagesToDelete);
        }
    }
    
    public static void deleteOlderEmailMessages(List<EmailMessage> emailMessageList){
        Set<Id> caseIds = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        Set<Id> emailMessageIds = new Set<Id>();
        Map<Id, Id> emailToCaseMap = new Map<Id, Id>();
        List<EmailMessage> emailsToDelete = new List<EmailMessage>();
        List<ContentDocumentLink> emailAttachments = new List<ContentDocumentLink>();
        List<ContentDocumentLink> caseAttachmentsToCreate = new List<ContentDocumentLink>();
        
        for(EmailMessage em : emailMessageList){
            if(em.ParentId != null && String.valueOf(em.ParentId).contains('500') && em.Status != '5'){
                caseIds.add(em.ParentId);
                emailMessageIds.add(em.Id);
            }
        }
        
        if (!caseIds.isEmpty()) {
            emailsToDelete = [SELECT Id, ParentId 
                              FROM EmailMessage 
                              WHERE ParentId IN :caseIds
                              AND Id NOT IN :emailMessageIds
                             ];
        }
        
        if(!emailsToDelete.isEmpty()){
            for(EmailMessage em : emailsToDelete){
                emailToCaseMap.put(em.Id, em.ParentId);
            }
        }
        
        List<ContentDocumentLink> attachmentList = [SELECT ContentDocumentId,LinkedEntityId 
                                                      FROM ContentDocumentLink 
                                                      WHERE (LinkedEntityId IN :emailToCaseMap.keySet() OR LinkedEntityId IN :caseIds)
                                                    ];
        
        for(ContentDocumentLink eachDocumentLink : attachmentList){
            if(caseIds.contains(eachDocumentLink.LinkedEntityId)){
                contentDocumentIds.add(eachDocumentLink.ContentDocumentId);
            }
            else{
                emailAttachments.add(eachDocumentLink);
            }
        }  

        for (ContentDocumentLink emailAttachment : emailAttachments) {
            if(!contentDocumentIds.contains(emailAttachment.ContentDocumentId)){
                caseAttachmentsToCreate.add(new ContentDocumentLink(
                    ContentDocumentId = emailAttachment.ContentDocumentId,
                    LinkedEntityId = emailToCaseMap.get(emailAttachment.LinkedEntityId),
                    ShareType = 'V'
                ));
                contentDocumentIds.add(emailAttachment.ContentDocumentId);
            }
        }
        
        if(!caseAttachmentsToCreate.isEmpty()){
            insert caseAttachmentsToCreate;
        }
        
        if(!emailsToDelete.isEmpty()){
            delete emailsToDelete;
        }
    }
}