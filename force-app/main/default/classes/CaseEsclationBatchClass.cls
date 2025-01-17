public class CaseEsclationBatchClass implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT  CaseNumber, CreatedDate,Status FROM Case');  
    }
    
    public void execute(Database.BatchableContext BC, List<Case> caseList) {
        System.debug(caseList);
        List <Case> ca =  new List<Case>();
        for(Case so :caseList)
        {
            Case c = (Case)so;
            ca.add(c);
        }    
        
        for(Case c : ca)
        {                      
            Double Days = Math.Floor((System.now().getTime()  - c.CreatedDate.getTime())/ (1000.0*60.0*60.0*24));                       
            if(Days > 1  &&  c.Status != 'Closed' )
            {
                String emailMessage = 'The case  ' + c.CaseNumber + ' has been ecalated ' + ' Please look into the case ' + 'Thankyou';
                Messaging.SingleEmailMessage mail  =   new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {'reems.agarwal3@gmail.com'};
                mail.setToAddresses(toAddresses);
                mail.setSubject('Case Escalation');
                mail.setPlainTextBody(emailMessage);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
                c.Status = 'Escalated';
            }
        }
    }   
    
    public void finish(Database.BatchableContext BC) {
    }
}