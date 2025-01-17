public class LeadTriggerHelperForCrossSell {    
    public static void sendEmailNotification(List<Lead> leadList){
		List<Messaging.SingleEmailMessage> emailList = New List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owdAddress = [SELECT Id, Address, DisplayName 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address='noreply@gatikwe.com'
                                               ];
        
        if(owdAddress != null && owdAddress.size() > 0){
            Schema.DescribeFieldResult fieldResult = Lead.Product__c.getDescribe();
            String fromEmail = owdAddress[0].Id;
            String gatiSpocEmailId = label.LeadEmailNotificationToEmail;
            String ccEmail = System.Label.Cross_Sell_Email;
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
            List<String> toEmail = new List<String>{};            
            Map<String,String> mapOfProduct = new Map<String,String>();

            for( Schema.PicklistEntry pickListVal : ple){
                mapOfProduct.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            
            for(Lead ld : leadList){
                Messaging.SingleEmailMessage emailData = New Messaging.SingleEmailMessage();
                if(ld.LeadSource == 'Cross Sell'){
                    String senderName = '';
                    String pruductName = '';
                    List<String> tempList = new List<String>();                    
                    String leadName = ld.Company;

                    if(ld.Cross_Sell_Receiver_Email_Id__c!=null){
                        toEmail.add(ld.Cross_Sell_Receiver_Email_Id__c);
                    }
                    If(gatiSpocEmailId != null && gatiSpocEmailId != ''){
                        toEmail.add(gatiSpocEmailId);
                    }
                    if(ld.Product__c!=null){
                        tempList = ld.Product__c.split(';');
                    }
                    for(String str : tempList){
                        pruductName += mapOfProduct.get(str)+',';
                    }
                    pruductName = pruductName.removeEnd(',');
                    if(ld.Cross_Sell_Sender_Name__c != null){
                        senderName = ld.Cross_Sell_Sender_Name__c;
                    }
                    if(toEmail != null && toEmail.size()>0){
                        emailData = sendMailLeadInsert(senderName,toEmail,ccEmail,fromEmail,leadName,ld.Id,pruductName);
                        emailList.add(emailData);
                    }
                }
            }
            if(emailList != null && emailList.size() > 0){
                Messaging.sendEmail(emailList);
            }
        }
    }

    public static Messaging.SingleEmailMessage sendMailLeadInsert(String senderName,List<String> toEmail,String ccEmail,String fromEmailId,String leadName,String leadId, String productName){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		String emailBody = '';
        List<String> toAddresses = toEmail;
        List<String> ccAddresses = new List<String>{ccEmail};

        email.setOrgWideEmailAddressId(fromEmailId);
        email.setToAddresses(toAddresses);
        email.setCcAddresses(ccAddresses);
        emailBody = 'Dear Colleague, <br/><br/>Cross Sell lead (<a href="'+System.Label.Lead_Showing_Base_URL+leadId+'/view">'+leadName+'</a>) has been shared by '+senderName+' from Gati KWE for Product('+productName+')  from the CRM. <br/> We request you to work on this lead and update the status within next 3 days.';
        emailBody+='<br/><br/> Regards,<br/> Cross-sell Team <br/>';
        emailBody+='<img src="'+System.Label.Gati_BaseUrl+'">';
        email.setSubject('Cross Sell Lead');
        email.setHtmlBody(emailBody);
        return email;
    }
	
    public static void sendEmailNotificationOwnerChange(List<Lead> leadList, Map<Id,Lead> oldLeadMap){
        List<Messaging.SingleEmailMessage> emailList = New List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> owdAddress = [SELECT Id, Address, DisplayName 
                                                FROM OrgWideEmailAddress 
                                                WHERE Address = 'noreply@gatikwe.com'
                                               ];
        
        if(owdAddress != null && owdAddress.size() > 0){
            String fromEmail = owdAddress[0].Id;
            String gatiSpocEmailId = label.LeadEmailNotificationToEmail;
            String ccEmail = System.Label.Cross_Sell_Email;
            List<String> toEmail = New List<String>();
            Set<Id> ownerIds = new Set<Id>();
            Map<Id,String> mapOwnerEmail = new Map<Id,String>();
            Map<Id,String> mapOwnerName = new Map<Id,String>();            
            Map<String,String> mapOfProduct = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = Lead.Product__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for(Lead ld: leadList){
                ownerIds.add(ld.OwnerId);
            }

            if(ownerIds != null && ownerIds.size()>0){
                List<User> userList = [SELECT Id,Email,Name,UserRole.Name 
                                       FROM User 
                                       WHERE Id IN: ownerIds
                                      ];

                if(userList != null && userList.size() > 0){
                    for(User usr : userList){
                        mapOwnerEmail.put(usr.Id,usr.Email);
                        mapOwnerName.put(usr.Id,usr.Name+'-'+usr.UserRole.Name);
                    }
                }
            }
            
            for( Schema.PicklistEntry pickListVal : ple){
                mapOfProduct.put(pickListVal.getValue(),pickListVal.getLabel());
            }
            
            for(Lead ld : leadList){
                String pruductName='';
                String senderName='';
                String receiverName='';
                String leadName = '';
                List<String> tempList = new List<String>();
                if(ld.LeadSource=='Cross Sell' && ld.OwnerId != oldLeadMap.get(ld.Id).OwnerId){
                    Messaging.SingleEmailMessage emailData = new Messaging.SingleEmailMessage();
                    if(ld.Cross_Sell_Receiver_Email_Id__c!=null){
                        toEmail.add(ld.Cross_Sell_Receiver_Email_Id__c);
                    }
                    if(gatiSpocEmailId != null && gatiSpocEmailId != ''){
                    	toEmail.add(gatiSpocEmailId);
                    }
                    toEmail.add(mapOwnerEmail.get(ld.OwnerId));
                    if(ld.Cross_Sell_Sender_Name__c!=null){
                        senderName = ld.Cross_Sell_Sender_Name__c;
                    }
                    if(ld.Product__c!=null){
                        tempList = ld.Product__c.split(';');
                    }
                    for(String str : tempList){
                        pruductName += mapOfProduct.get(str)+',';
                    }
                    pruductName = pruductName.removeEnd(',');
                    if(ld.Cross_Sell_Receiver_Name__c!=null){
                        receiverName=ld.Cross_Sell_Receiver_Name__c;
                    }
                    if(ld.FirstName!=null && ld.LastName!=null){
                        leadName = ld.FirstName+' '+ld.LastName;
                    }
                    else{
                        leadName = ld.LastName;
                    }
                    If(toEmail != null && toEmail.size()>0){
                        emailData = sendMailLeadUpdate(senderName,receiverName,mapOwnerName.get(ld.OwnerId),toEmail,ccEmail,fromEmail,leadName,ld.Id,pruductName);
                        emailList.add(emailData);
                    }
                }
            }
            if(emailList != null && emailList.size()>0){
                Messaging.sendEmail(emailList);
            }
        }
    }
    
    public static Messaging.SingleEmailMessage sendMailLeadUpdate(String senderName,String recieverName,String ownerName,List<String> toEmail,String ccEmail,String fromEmailId,String leadName, String leadId, String pruductName){
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		String emailBody = '';
        List<String> toAddresses = toEmail;
        List<String> ccAddresses = new List<String>{ccEmail};

        email.setOrgWideEmailAddressId(fromEmailId);
        email.setToAddresses(toAddresses);
        if(ccAddresses != null && ccAddresses.size() > 0){
            email.setCcAddresses(ccAddresses);
        }
        emailBody = 'Dear Colleague, <br/><br/>Cross Sell lead (<a href="'+System.Label.Lead_Showing_Base_URL+leadId+'/view">'+leadName+'</a>) has been shared by '+senderName+' to '+recieverName+' from Gati for Product ('+pruductName+' from the CRM. <br/> The lead is now assigned to '+ownerName+'. <br/> We request you to work on this lead and update the status within next 3 days';
        emailBody += '<br/><br/> Regards,<br/> Cross-sell Team <br/>';
        emailBody += '<img src="'+System.Label.Gati_BaseUrl+'">';
        email.setSubject('Cross Sell Lead');
        email.setHtmlBody(emailBody);

        return email;
    }

    public static void handleRevisitNotificationAndConversion(List<Lead> leadList){
        List<Lead> revisitLeadsForEmail = new List<Lead>();
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        LeadStatus convertedStatus = [SELECT Id, MasterLabel 
                                    FROM LeadStatus 
                                    WHERE IsConverted = true 
                                    LIMIT 1
                                   ];

        for(Lead ld : leadList){
            if( ld.LeadSource == 'Cross Sell' && (ld.Status == 'Revisit' || ld.Cross_Sell_Lead_Status__c  == '4') && ld.Revisit_Date__c != null){
                revisitLeadsForEmail.add(ld);
            }
            if(ld.LeadSource == 'Cross Sell' && ld.Status == 'Converted'){
                Database.LeadConvert leadToConvert = new Database.LeadConvert();
                leadToConvert.setLeadId(ld.Id);                
                leadToConvert.setConvertedStatus(convertedStatus.MasterLabel);
                leadsToConvert.add(leadToConvert);
            }
        }

        if(revisitLeadsForEmail != null && revisitLeadsForEmail.size()>0){
            sendEmailForRevisit(revisitLeadsForEmail);
        }

        if (leadsToConvert != null && leadsToConvert.size() > 0) {
            List<Database.LeadConvertResult> leadsToConvertedResult = Database.convertLead(leadsToConvert, false);
        }
    }
    
    public static void sendEmailForRevisit(List<Lead> leadList){
        List<Messaging.SingleEmailMessage> emailList = New List<Messaging.SingleEmailMessage>();
        String fromEmail = '';
		Map<Id,String> ownerIdToEmail = New Map<Id,String>();
		Set<Id> ownerIds = new Set<Id>();
		
		List<OrgWideEmailAddress> owdEmail = [SELECT Id, Address, DisplayName 
                                              FROM OrgWideEmailAddress 
                                              WHERE Address = 'noreply@gatikwe.com'
                                             ];
		
		
		If(owdEmail != null && owdEmail.size()>0){
			fromEmail = owdEmail[0].Id;
		}
		
		for(Lead ld : leadList){
			ownerIds.add(ld.OwnerId);
		}

		if(ownerIds != null && ownerIds.size()>0){
			List<User> userList = [SELECT Id, Email 
                                   FROM User 
                                   WHERE Id IN: ownerIds
                                  ];
			if(userList != null && userList.size()>0){
				for(User u : userList){
					ownerIdToEmail.put(u.Id,u.Email);
				}
			}
		}

		for(Lead ld : leadList){
			if(ownerIdToEmail.containsKey(ld.OwnerId)){
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();				
				String reasonRevisit='';
                String ownerEmail = ownerIdToEmail.get(ld.OwnerId);
                String ccEmail = System.Label.Cross_Sell_Email;
                List<String> toEmail = new List<String>{ownerEmail};
                String emailBody = '';
                List<String> toAddresses = toEmail;
                List<String> ccAddresses = new List<String>{ccEmail};
				
                if(ld.Reason_for_Revisit__c!=null){
					reasonRevisit = ld.Reason_for_Revisit__c;
                }

				email.setOrgWideEmailAddressId(fromEmail);
				email.setToAddresses(toAddresses);
				email.setCcAddresses(ccAddresses);
				emailBody = 'Dear Colleague, <br/>'+ld.Company+' was placed in cold storage on '+ld.Revisit_Date__c+' reason for re-visit '+reasonRevisit+'.<br/>It is time to revisit this customer. We request you to revisit this lead and update the status within the next 3 days.';
				emailBody+='<br/><br/> Regards,<br/> Cross-sell Team <br/>';
				emailBody+='<img src="'+System.Label.Gati_BaseUrl+'">';
				email.setSubject('Cross Sell Lead');
				email.setHtmlBody(emailBody);
				
				emailList.add(email);
			}
		}
		
		if(emailList != null && emailList.size()>0){
			Messaging.sendEmail(emailList);
		}
    }    

    public static void duplicatePreventExceptCrossSell(List<Lead> leadList){
        Set<String> emailSet = new Set<String>();
        Set<String> mobileSet = new Set<String>();
        Map<String, Lead> keyToLeads = new Map<String, Lead>();
        
        for(Lead ld : leadList){
            if(ld.LeadSource == 'Cross Sell' && (ld.GATI_Company_Code__c != '101' || ld.GATI_Company_Code__c != '102' )){
                ld.Cross_Sell_Topic__c = 'Cross Sell:'+ ld.Company;
                if(ld.Status == 'New'){
                    ld.Cross_Sell_Lead_Status__c = '1';
                }
            }
            if(ld.LeadSource != 'Cross Sell' && ld.MobilePhone != null && ld.Email != null){
                emailSet.add(ld.Email);
                mobileSet.add(ld.MobilePhone);
            }
        }

        List<Lead> existingLeadList = [SELECT Id, Email, Product__c, GATI_Company_Code__c,MobilePhone  
                                       FROM Lead 
                                       WHERE (Email IN: emailSet
                                       AND MobilePhone IN: mobileSet)
                                       AND LeadSource != 'Cross Sell'
                                       AND IsConverted = false
                                      ];

        if(existingLeadList != null && existingLeadList.size() > 0){
            for(Lead ld : existingLeadList){
                String key = ld.Email + '-' + ld.MobilePhone;
                keyToLeads.put(key, ld);
            }
        }

        for(Lead ld : leadList){
            if(ld.LeadSource != 'Cross Sell'){
                String key = ld.Email + '-' + ld.MobilePhone;
                if(keyToLeads.containsKey(key)){
                    ld.addError('Lead Already Generated..!');
                }
            }
        }
    }

    public static void approvalLockToLeads(List<Lead> leadList){
        List<Id> leadIdsToLock = new List<Id>();

        for(Lead ld : leadList){
            if(ld.LeadSource == 'Cross Sell' && ld.Cross_Sell_Lead_Created_From__c == 'GATI CRM'){
                leadIdsToLock.add(ld.Id);
            }
        }

        if(leadIdsToLock != null && leadIdsToLock.size() > 0){
            Approval.lock(leadIdsToLock);
        }
    }
}