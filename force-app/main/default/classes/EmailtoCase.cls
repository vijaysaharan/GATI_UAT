global class EmailtoCase implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            String fromAdd=email.fromAddress;
            contact c=[select id from contact where email=:fromAdd];
            case a1=new case();
            a1.origin='Email';
            a1.Status='New';
            a1.Priority='Medium';
            a1.subject=email.Subject;
            a1.description=email.plainTextBody;
            a1.contactId=c.Id;
            System.debug('email.subject--> '+email.Subject);
            insert a1;
           
           
          result.success=true; 
        }
        catch(Exception e)
        {
            result.success=false;
        }
        
return result;
    }

}