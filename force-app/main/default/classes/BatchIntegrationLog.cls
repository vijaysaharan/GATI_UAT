global class BatchIntegrationLog implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select Id,CaseNumber__c,Component_Name__c, CreatedBy.Email,eRecordID__c,Error_message__c  from Integration_log__c where CaseNumber__c!=null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Integration_log__c> intlogs)
    {
        
       /* Map<id,List<Integration_log__c>> useridvsListintlog=new Map<id,List<Integration_log__c>>();
        Map<id,String> creatorIdsEmail=new Map<id,String>();
        Map<id,String> creatorIdsName=new Map<id,String>();
        
        for(Integration_log__c a:intlogs)
        {
            creatorIdsEmail.put(a.CreatedById,a.CreatedBy.email);
            creatorIdsName.put(a.CreatedById,a.CreatedBy.name);
            if(useridvsListintlog.ContainsKey(a.CreatedById))
            {
                List<Integration_log__c> userList=useridvsListintlog.get(a.CreatedById);
                userList.add(a);
                useridvsListintlog.put(a.CreatedById,userList);
            }
            else
            {
                List<Integration_log__c> userList=new List<Integration_log__c>();
                userList.add(a);
                useridvsListintlog.put(a.CreatedById,userList);
            }*/
       list <user_email__mdt> u= [select email__c from user_email__mdt];
        list<string> emailids= new list<string>();
        for(user_email__mdt it:u)
        {
            emailids.add(it.email__c);
        }
    
                
         //Integration_log__c il = [Select Id,CaseNumber__c,Component_Name__c, Error_Message__c, CreatedBy.Email,eRecordID__c    from Integration_log__c where CaseNumber__c!=null];
      
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>(); 
        for(Integration_log__c ic:intlogs)
        {
          //  List<Integration_log__c> ics=useridvsListintlog.get(ic);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.toaddresses = emailids;
                email.subject = 'ERROR!!!';
            email.setHtmlBody(table(ic));
            system.debug(email.toaddresses);
            system.debug(email.htmlbody);
            messages.add(email);
            
       
             }
         Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
    }
    
    public String table(Integration_log__c inttList)
    {
        String htmlBody='Hi '+',<br><br>';
        htmlBody+='Please rectify the error'+'<br><br>';
        
        //for(Integration_log__c ilg:inttList)
        //{
            htmlBody+=
                '<table width="100%" border="0" cellspacing="0" cellpadding="8" align="center" bgcolor="#F7F7F7">'
                
                +'<tr><td style="font-size: 14px; font-weight: normal; font-family:Calibri;line-height: 18px; color: #333;">'+inttList.CaseNumber__c+'has encountered an error'+ inttList.Error_Message__c+'</td></tr>'
                
                +'<tr><td style="font-size: 14px; font-weight: normal; font-family:Calibri;line-height: 18px; color: #333;"><HTML><a href="'+URL.getSalesforceBaseUrl()+'/'+inttList.eRecordID__c+'">'+URL.getSalesforceBaseUrl()+'/'+inttList.eRecordID__c+'</a></HTML></td></tr>'
                +'</table><br>';
       // }
       // 
        htmlBody+='Thanks & Regards'+'<br>';
        htmlBody+='Gati Team';
        System.debug(htmlBody);
        return htmlBody;
    } 
    

    global void finish(Database.BatchableContext BC)
    {
    }
}