global class LeadEmailNotificationBatch implements Database.batchable<sObject>,Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String leadSource = 'Cross Sell';
        String query = 'SELECT Id,FirstName,LastName,Cross_Sell_101_Products__c,Cross_Sell_102_Products__c,Cross_Sell_Lead_Created_From__c,Cross_Sell_Lead_Status__c,Cross_Sell_Zone__c,';
        query+='LeadSource,Last_Modified_Ageing__c,Cross_Sell_Sender_Name__c,Cross_Sell_Staff_master_Email__c,Cross_Sell_Receiver_Email_Id__c,Cross_Sell_Receiver_Name__c,Owner.UserRole.ParentRoleId FROM Lead WHERE Last_Modified_Ageing__c>3 AND LeadSource=:leadSource AND isConverted=false limit 10';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        System.debug('--- check 1 all data--'+scope);
        String fromEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE Address='noreply@gatikwe.com'].Id;
        String gatiSpocEmailId = [SELECT Id,Email,Name from User WHERE UserRole.Name='INSIDE SALES' and isActive=true limit 1].Email;
         String ccEmail = System.Label.Cross_Sell_Email;
         
        //ccEmail= System.Label.Cross_Sell_Email;
        Set<Id> ownerIds = new Set<Id>();
        Map<Id,String> mapOwnerEmail = new Map<Id,String>();
        Map<Id,String> mapOwnerName = new Map<Id,String>();
        Map<Id,String> mapOfVerticHead = new Map<Id,String>();
        Set<Id> userRoleId = new Set<Id>();
         for(Lead newLead: scope){
             ownerIds.add(newLead.OwnerId);
         }
         if(!ownerIds.isEmpty() && ownerIds.size()>0){
             List<User> userList = [SELECT Id,Email,Name,UserRole.Name,UserRole.ParentRoleId FROM User WHERE Id IN:ownerIds AND isActive=true];
             System.debug('-- list of user--'+userList);
             if(!userList.isEmpty() && userList.size()>0){
                 for(User usr : userList){
                     mapOwnerEmail.put(usr.Id,usr.Email);
                     mapOwnerName.put(usr.Id,usr.Name+'-'+usr.UserRole.Name);
                     userRoleId.add(usr.UserRole.ParentRoleId);
                 }
             }
             List<User> userListVertical = [SELECT Id,Name,Email,UserRoleId,UserRole.ParentRoleId from User WHERE UserRoleId IN:userRoleId AND isActive=true];
             if(!userListVertical.isEmpty() && userListVertical.size()>0){
                 for(user usr : userListVertical){
                     mapOfVerticHead.put(usr.UserRoleId,usr.Email);
                 }
             }
             
         }
         
        if(!scope.isEmpty() && scope.size()>0){
            
            LeadEmailNotificationBatch obj = new LeadEmailNotificationBatch();
            for(Lead leadBulk : scope){
                String[] toEmail = new String[]{};
                toEmail.add(gatiSpocEmailId);
                //toEmail.add('akumar4@kloudrac.com');
                if(mapOfVerticHead.get(leadBulk.Owner.UserRole.ParentRoleId)!=null)
                toEmail.add(mapOfVerticHead.get(leadBulk.Owner.UserRole.ParentRoleId));
                toEmail.add(mapOwnerEmail.get(leadBulk.OwnerId));
                if(leadBulk.Cross_Sell_Receiver_Email_Id__c!=null)
                toEmail.add(leadBulk.Cross_Sell_Receiver_Email_Id__c);
                String senderName='';
                String receiverName='';
                String leadName = '';
                if(leadBulk.Cross_Sell_Sender_Name__c!=null)
                    senderName= leadBulk.Cross_Sell_Sender_Name__c;
                if(leadBulk.Cross_Sell_Receiver_Name__c!=null)
                    receiverName = leadBulk.Cross_Sell_Receiver_Name__c;
                if(leadBulk.FirstName!=null && leadBulk.LastName!=null){
                    leadName = leadBulk.FirstName+' '+leadBulk.LastName;
                }else{leadName = leadBulk.LastName;}
                sendEmailNotificationPastDaysLead(senderName,receiverName,mapOwnerName.get(leadBulk.ownerId),toEmail,ccEmail,fromEmail,leadName,leadBulk.Id);
                
            }
        }
        
    } 
    global void finish(Database.BatchableContext BC) {
        System.debug('--- LeadEmailNotificationBatch run successfully--');
    }
    global void execute(SchedulableContext SC){
	 database.executeBatch(new LeadEmailNotificationBatch());
    }


    // Email Send Notification When Lead Pas 3 Days and no action
    global static void sendEmailNotificationPastDaysLead(String senderName,String recieverName,String ownerName,List<String> toEmail,String ccEmail,String fromEmailId,String leadName, String leadId){
        System.debug('-- to email--'+toEmail);
         System.debug('-- cc email--'+ccEmail);
        String emailBody = '';
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] to = toEmail;
        String[] cc = new String[]{ccEmail};
         email.setOrgWideEmailAddressId(fromEmailId);
        if(to!=null && to.size()>0)
         email.setToAddresses(to);
        if(cc!=null && cc.size()>0)
        email.setCcAddresses(cc);
        emailBody = 'Dear Colleague, <br/><br/>Cross-Sell lead ( <a href=" '+System.Label.Lead_Showing_Base_URL+leadId+'/view">'+leadName+'</a>)" > ) was shared by '+senderName+' to you '+ownerName+'.<br/> We have observed that it`s been 3 days ,but there is no action <br/> from the owner.We request you to work on this lead and update <br/> the status within next 3 days.';
        emailBody+='<br/><br/> Regards,<br/> Cross-sell Team <br/>';
        emailBody+='<img src="'+System.Label.Gati_BaseUrl+'">';
        email.setSubject('Cross Sell Lead');
        email.setHtmlBody(emailBody);
        
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            System.debug('-- email sent successfully--');
        }catch(exception ex){
            System.debug('-- error occur when send email--'+ex.getMessage());
        }
    }
}