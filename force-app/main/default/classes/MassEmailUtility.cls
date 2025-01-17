public class MassEmailUtility {
    public static Messaging.SingleEmailMessage sendEmail(String userEmail, String accId, String conId,Id orgWideDefaultId,EmailTemplate emailTemplate,String url){
        String emailBody = '';
        String[] toEmail = new String[]{userEmail};
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(orgWideDefaultId);
        email.setToAddresses(toEmail);
        email.setTargetObjectId(conId);
        email.setWhatId(accId);
        list<wrapperClass> bodyAndSubject = getSubjectAndBody(emailTemplate,accId,conId);
        emailBody = bodyAndSubject[0].body;
        emailBody += 'Feedback Link: <a href="'+ url + '?accountId=' + accId + '&contactId=' + conId +'">Customer Feedback</a> <br/><br/>';
        emailBody+='<br/>Best regards,<br/> Team- Allcargogati <br/>';
        emailBody+='<br/><img src="'+label.CustomerFeedbackImgURL+'"/>';
        email.setSubject(bodyAndSubject[0].subject);
        email.setHtmlBody(emailBody);
        return email;
    }
    
    public static list<wrapperClass> getSubjectAndBody(EmailTemplate emailTemp , string objectId, String contactId)
    {
        list<wrapperClass> lstWrapperClass = new list<wrapperClass>();
        if(emailTemp != null)
        {
            List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(contactId, objectId, new List<String>{emailTemp.Subject, emailTemp.HtmlValue});
            wrapperClass wc = new wrapperClass();
            wc.subject = renderResults[0].getMergedBody();
            wc.body =  renderResults[1].getMergedBody() != null ?  renderResults[1].getMergedBody() :  ' '; 
            lstWrapperClass.add(wc);        
        }
        return lstWrapperClass;
    }
    
    public class wrapperClass{
        @auraEnabled
        public string subject {get;set;}
        @auraEnabled
        public string body {get;set;}
    }
}