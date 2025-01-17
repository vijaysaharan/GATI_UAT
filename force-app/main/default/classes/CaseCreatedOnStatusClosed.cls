Global class CaseCreatedOnStatusClosed implements Messaging.InboundEmailHandler {
 global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        Case cs = new Case();
        cs.Status='New';
        cs.Origin='Email';
        cs.Priority='Low';
        cs.SuppliedEmail=email.fromAddress;
        cs.Subject=email.Subject;
        cs.Description= email.plainTextBody;
        insert cs;
        if(email.Subject!=null){
        if(email.Subject.Contains(cs.Subject)){
            
            
        }
        }
        
        if(cs.Status=='Closed'){
             Case cs1 = new Case();
        cs1.Status='Working';
        cs1.Origin='Email';
        cs1.Priority='Low';
        cs1.SuppliedEmail=email.fromAddress;
        cs1.Subject=email.Subject;
        cs1.Description= email.plainTextBody;
        insert cs1;
        }
        return null;
    }
}