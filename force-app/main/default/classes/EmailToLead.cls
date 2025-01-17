public with sharing class EmailToLead implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        List<Lead> leads = [SELECT ID,Email,Description__c from Lead where Email =: email.fromAddress];    
        
        if(leads.size()==0)
        {
            Lead l =new Lead();
            if(email.fromName.substring(0,email.fromName.indexof(' '))!=null ){ 
                   l.FirstName = email.fromName.substring(0,email.fromName.indexof(' '));
               }       
            l.LastName = email.fromName.substring(email.fromName.indexof(' '));
            l.Email = email.fromAddress;
            l.Status = 'New';
            l.Company = l.FirstName +' '+ l.LastName;
            l.LeadSource ='Email';
            String subject = email.subject; 
            l.Description__c= 'Subject: ' +subject + '\n'+ 'Description: '+ email.plainTextBody; 
            insert l;
            System.debug(l.id);
            List<Attachment> attachments =new list<Attachment>();
            
            if(email.binaryAttachments != null && email.binaryAttachments.size()>0)
            {
                for(integer i =0; i<email.binaryAttachments.size(); i++)
                {
                    attachments.add( 
                        new Attachment(ParentId= l.ID,
                                       Name = email.binaryAttachments[i].filename,
                                       Body = email.binaryAttachments[i].body)); 
                }
            }
            if(!attachments.isEmpty())
            {
                insert attachments;
            }
        }
        else{
            Lead l= leads[0];
        	System.debug(l);
            String subject = email.subject; 
            l.Description__c=l.Description__c+'\n \n ' + 'Subject: ' +subject + '\n'+ 'Description: '+ email.plainTextBody;
            Database.update(l,false);
            
             List<Attachment> attachments =new list<Attachment>();
            
            if(email.binaryAttachments != null && email.binaryAttachments.size()>0)
            {
                for(integer i =0; i<email.binaryAttachments.size(); i++)
                {
                    attachments.add( 
                        new Attachment(ParentId= l.ID,
                                       Name = email.binaryAttachments[i].filename,
                                       Body = email.binaryAttachments[i].body)); 
                }
            }
            if(!attachments.isEmpty())
            {
                insert attachments;
            }

        }
        
        result.success=true;
        return result;
    }
}