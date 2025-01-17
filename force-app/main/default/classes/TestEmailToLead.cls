@isTest
private class TestEmailToLead {
    static testMethod void Test_LeadonInsertion() {
        // create a new email and envelope object
         Messaging.InboundEmail email = TestFactory.getEmail('create Lead','FirstName LastName','rishabh@gmail.com');
         Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = TestFactory.getAttachment('my attachment text','textfile.txt','text/plain');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        // call the email service class and test it with the data in the testMethod
        EmailToLead emailProcess = new EmailToLead();
        emailProcess.handleInboundEmail(email, env);
        
        // query for the lead the email service created
        Lead l = [select id, firstName, lastName, email from lead where firstName = 'FirstName' and lastName = 'LastName'];
        System.assertEquals(l.firstName,'FirstName');
        System.assertEquals(l.lastName,'LastName');
        System.assertEquals(l.email,'rishabh@gmail.com');
        // find the attachment
        Attachment a = [select name from attachment where parentId =: l.id];
        System.assertEquals(a.name,'textfile.txt');  
    
    }
    
    static testMethod void Test_LeadonUpdate() {
        // create a new email and envelope object
        //Lead ll = TestFactory.getLead('rishabh@gmail.com','LastName','New','201005','9205065585','Company');
        Lead p = new Lead();
        p.LeadSource='Email';
        p.Email='rishabh@gmail.com';
        p.LastName='LastName';
        p.PostalCode='670987';
        p.Company='company';
        p.Phone='8909876';
        p.MobilePhone='7675436789';
        insert p;
        //Lead p= [select id, Email from lead where id =:ll.id ];
    	Messaging.InboundEmail email = TestFactory.getEmail('create Lead','FirstName LastName','rishabh@gmail.com');
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        
        // add an attachment
        Messaging.InboundEmail.BinaryAttachment attachment = TestFactory.getAttachment('my attachment text','textfile.txt','text/plain');
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        // call the email service class and test it with the data in the testMethod
        EmailToLead emailProcess = new EmailToLead();
        emailProcess.handleInboundEmail(email, env);
        
        // query for the lead the email service created
        Lead l = [select id, firstName, lastName, email from lead where email ='rishabh@gmail.com'];
        System.assertEquals(l.email,'rishabh@gmail.com');
        // find the attachment
        Attachment a = [select name from attachment where parentId =: l.id];
        System.assertEquals(a.name,'textfile.txt');  
    
    } 

}