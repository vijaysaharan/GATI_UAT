public class MCM_ReminderEmailOnAccount implements Database.Batchable<Sobject> {
 
    //public integer recordsProcessed;
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([Select id, Name,OwnerId,MCM_Required__c,owner.name,owner.email,RecordType.Name from Account where MCM_Required__c = true and RecordType.Name =:'Contract' order by owner.name]);  	 
        
    }
    
    public void execute(Database.BatchableContext bc,List<Account> accountList)
    {
        
        Map<id,List<Account>> useridvsListaccounts=new Map<id,List<Account>>();
        Map<id,String> ownerIdsEmail=new Map<id,String>();
        Map<id,String> ownerIdsName=new Map<id,String>();
        
        for(Account a:accountList)
        {
            ownerIdsEmail.put(a.OwnerId,a.Owner.email);
            ownerIdsName.put(a.OwnerId,a.Owner.name);
            if(useridvsListaccounts.ContainsKey(a.OwnerId))
            {
                List<Account> userList=useridvsListaccounts.get(a.OwnerId);
                userList.add(a);
                useridvsListaccounts.put(a.OwnerId,userList);
            }
            else
            {
                List<Account> userList=new List<Account>();
                userList.add(a);
                useridvsListaccounts.put(a.OwnerId,userList);
            }
            
        }
        Messaging.SingleEmailMessage[] messages= new List<Messaging.SingleEmailMessage>(); 
        for(Id acc:useridvsListaccounts.KeySet())
        {
            List<Account> accs=useridvsListaccounts.get(acc);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.toaddresses = new List<String>{OwnerIdsEmail.get(acc)};
                email.subject = 'Conduct MCM';
            email.setHtmlBody(table(accs,OwnerIdsName.get(acc)));
            system.debug(email.toaddresses);
            system.debug(email.htmlbody);
            messages.add(email);
            
        }
        Messaging.SendEmailResult[] result = Messaging.sendEmail(messages);
        
    }
    public String table(List<Account> accountList,String name)
    {
        String htmlBody='Hi '+name+',<br><br>';
        htmlBody+='Please conduct MCM for the accounts '+'<br><br>';
        
        for(Account act:accountList)
        {
            htmlBody+=
                '<table width="100%" border="0" cellspacing="0" cellpadding="8" align="center" bgcolor="#F7F7F7">'
                
                +'<tr><td style="font-size: 14px; font-weight: normal; font-family:Calibri;line-height: 18px; color: #333;">'+act.name+'</td></tr>'
                
                +'<tr><td style="font-size: 14px; font-weight: normal; font-family:Calibri;line-height: 18px; color: #333;"><HTML><a href="'+URL.getSalesforceBaseUrl()+'/'+act.id+'">'+URL.getSalesforceBaseUrl()+'/'+act.id+'</a></HTML></td></tr>'
                +'</table><br>';
        }
        htmlBody+='Thanks & Regards'+'<br>';
        htmlBody+='Gati Team';
        System.debug(htmlBody);
        return htmlBody;
    } 
    
    public void finish(Database.BatchableContext bc)
    {
        
    }
}