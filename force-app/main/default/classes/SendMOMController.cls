public class SendMOMController {
    @AuraEnabled
    public static list<wrapperClass> getSubjectAndBody(string TempId , string objectId, String contactId){
        list<wrapperClass> lstWrapperClass = new list<wrapperClass>();
        if(TempId != null && TempId != '')
        {
            EmailTemplate emailTemp = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Id =: TempId];
            List<Messaging.RenderEmailTemplateBodyResult> renderResults = Messaging.renderEmailTemplate(null, null, new List<String>{emailTemp.Subject, emailTemp.HtmlValue});
            
            wrapperClass wc = new wrapperClass();
            wc.subject = renderResults[0].getMergedBody();
            wc.body =  renderResults[1].getMergedBody() != null ?  renderResults[1].getMergedBody() :  ' '; 
            lstWrapperClass.add(wc);        
        }
        return lstWrapperClass;
    }
    
    @AuraEnabled
    public static void sendMailToSelectedContact(List<String> toAddress, List<String> ccAddress, List<String> bccAddress,string fileData,string subject,string body,string recordId,list<string> lstTOEnteredEmail , list<string>lstCCEnteredEmail,list<string> lstBCCEnteredEmail,String binaryExcel){
        list<Messaging.SingleEmailMessage> lstEmail = new list<Messaging.SingleEmailMessage>();
        list<Attachment> lstAtt = new list<Attachment>();
        Boolean isGPISent = false;
        Blob pdfBlob;
        List<Customer_Connect__c> customerConnectData = [SELECT Id,Call_Type__c, Sub_Type__c, Customer_Code__c, Customer_Code__r.Customer_Category__c, IsGPILetterSent__c, Approval_Status__c FROM Customer_Connect__c WHERE Id =: recordId];
        if(lstTOEnteredEmail != null && lstTOEnteredEmail.size()>0){
            ToAddress.addAll(lstTOEnteredEmail);
        }
        if(lstCCEnteredEmail != null && lstCCEnteredEmail.size()>0){
            ccAddress.addAll(lstCCEnteredEmail);
        }
        if(lstBCCEnteredEmail != null && lstBCCEnteredEmail.size()>0){
            bccAddress.addAll(lstBCCEnteredEmail);
        }
        if(toAddress != null && toAddress.size()>0){
            Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
            sEmail.setToAddresses(toAddress);
            sEmail.setSubject(subject);
            sEmail.setHtmlBody(body);
            sEmail.setUseSignature(true);
            sEmail.setWhatId(id.valueOf(recordId));
            if(ccAddress != null && ccAddress.size()>0){
                sEmail.setCcAddresses(ccAddress);   
            }
            if(bccAddress != null && bccAddress.size()>0){
                sEmail.setBccAddresses(bccAddress);   
            }
            
            Blob bodyForAttachXLSX;                
            try{
                bodyForAttachXLSX = EncodingUtil.base64Decode(binaryExcel);
            }
            catch(VisualforceException e){
                bodyForAttachXLSX=Blob.valueOf('Some text');
            }
            List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment attachXLSX = new Messaging.EmailFileAttachment();
            attachXLSX.setContentType('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            attachXLSX.setFileName('MinutesOfMeeting.xlsx');
            attachXLSX.setInline(false);
            attachXLSX.setBody(bodyForAttachXLSX);
            attachmentList.add(attachXLSX);
            
            //PDF Of GPI Call Type            
            if(customerConnectData != null && customerConnectData.size() > 0 && customerConnectData[0].Call_Type__c == 'General Price Increase' && 
               (customerConnectData[0].Sub_Type__c == 'Agreed Full Price Increase' || (customerConnectData[0].Sub_Type__c == 'Partial Price Increase' && customerConnectData[0].Approval_Status__c == 'Approved')) && 
               customerConnectData[0].Customer_Code__c != null && !(customerConnectData[0].IsGPILetterSent__c) &&
               (customerConnectData[0].Customer_Code__r.Customer_Category__c == 'Strategic' || customerConnectData[0].Customer_Code__r.Customer_Category__c == 'MSME' || customerConnectData[0].Customer_Code__r.Customer_Category__c == 'KEA')
              ){
                  PageReference pdfPage = Page.GPILetter;
                  isGPISent = true;
                  pdfPage.getParameters().put('id', customerConnectData[0].Id);                
                  if(Test.isRunningTest()){
                      pdfBlob = blob.valueOf('TEST VALUE');
                  }
                  else{
                      pdfBlob = pdfPage.getContentAsPDF();   
                  }
                  Messaging.EmailFileAttachment pdfAttachment = new Messaging.EmailFileAttachment();
                  pdfAttachment.setContentType('application/pdf');
                  pdfAttachment.setFileName('GPINotification.pdf');
                  pdfAttachment.setBody(pdfBlob);
                  attachmentList.add(pdfAttachment);
              }            
            sEmail.setFileAttachments(attachmentList);            
            lstEmail.add(sEmail);            
        }
        if(lstEmail != null && lstEmail.size()>0){
            List<Messaging.SendEmailResult> mailSentResult = Messaging.sendEmail(lstEmail);
            if(isGPISent && mailSentResult[0].isSuccess()){
                customerConnectData[0].IsGPILetterSent__c = true;
                update customerConnectData;   
            }
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            ContentVersion newVersion = new ContentVersion();
            newVersion.Title = 'MoM Attachment';
            newVersion.VersionData = EncodingUtil.base64Decode(binaryExcel);
            newVersion.FirstPublishLocationId = recordId;
            newVersion.PathOnClient = 'MoM.xlsx';
            contentVersionList.add(newVersion);
            if(isGPISent){
                ContentVersion newVersionGPI = new ContentVersion();
                newVersionGPI.Title = 'GPI Letter';
                newVersionGPI.VersionData = pdfBlob;
                newVersionGPI.FirstPublishLocationId = recordId;
                newVersionGPI.PathOnClient = 'GPILetter.pdf';
                contentVersionList.add(newVersionGPI);
            }
            if(contentVersionList.size()>0){
                Database.insert(contentVersionList, false);
            }
        }
    }
    
    public class wrapperClass{
        @auraEnabled
        public string subject {get;set;}
        @auraEnabled
        public string body {get;set;}
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getDefaultEmailIds(String connectId){
        Map<String,List<String>> mapToReturn = new Map<String,List<String>>();
        Set<Id> edcSet = new Set<Id>();
        Set<String> toAdd = new Set<String>();
        Set<String> ccAdd = new Set<String>();
        Set<String> bccAdd = new Set<String>();        
        List<Customer_Connect__c> connectData = [SELECT Id, Lead__c, Lead__r.Email, Customer_Code__c, Customer_Code__r.Email__c,Opportunity__r.Account.Email__c FROM Customer_Connect__c WHERE ID =:connectId];
        if(connectData != null && connectData.size() > 0){
            toAdd.add(connectData[0].Lead__c != null ? connectData[0].Lead__r.Email : connectData[0].Customer_Code__r.Email__c != null ? connectData[0].Customer_Code__r.Email__c : connectData[0].Opportunity__r.Account.Email__c);
        }
        List<Attendee__c> attendeeList = [SELECT Contact__r.Email, User__r.Email 
                                          FROM Attendee__c 
                                          WHERE Customer_Connect__c =: connectId
                                         ];
        List<Actionable__c> actionables = [SELECT Contact__r.Email,Actionable_EDC__c,Controller_EDC__c 
                                           FROM Actionable__c 
                                           Where Include_in_MOM__c = true
                                           AND Customer_Connect__c =: connectId
                                          ];
        if(attendeeList != null && attendeeList.size()>0){
            for(Attendee__c att : attendeeList){
                if(att.Contact__r.Email != null){
                    toAdd.add(att.Contact__r.Email);
                }
                if(att.User__r.Email != null){
                    ccAdd.add(att.User__r.Email);
                }
            }
        }
        if(actionables != null && actionables.size()>0){
            for(Actionable__c act : actionables){
                if(act.Contact__r.Email != null){
                    toAdd.add(act.Contact__r.Email);
                }
                if(act.Actionable_EDC__c != null){
                    edcSet.add(act.Actionable_EDC__c);
                }
                if(act.Controller_EDC__c != null){
                    edcSet.add(act.Controller_EDC__c);
                }
            }
        }
        if(edcSet != null && edcSet.size() > 0){
            List<Contact> conList = [SELECT Id,Email 
                                     FROM Contact 
                                     WHERE Attached_OU__c IN :edcSet 
                                     AND BANK_BRANCH_NAME__c = 'Head EDC Operations' 
                                     AND Email LIKE '%allcargologistics.com%'
                                    ];
            if(conList != null && conList.size() > 0){
                for(Contact con : conList){
                    ccAdd.add(con.Email);
                }
            }
        }
        if(connectId != null){
            mapToReturn.put('toList',new List<String>(toAdd));
            mapToReturn.put('ccList', new List<String>(ccAdd));
            mapToReturn.put('bccList', new List<String>{});
        }
        if(actionables != null && actionables.size() > 0){
            return mapToReturn;    
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static string getDefaultTemplateId(String templateName){
        try {
            List<EmailTemplate> et = [Select id,Name from EmailTemplate where DeveloperName = : templateName ];
            return JSON.serialize(et[0]) ;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static excelData getCustomerConnectData(String cusId){
        excelData returnData = new excelData();
        try {
            Customer_Connect__c customerConnectData = [SELECT Id, Name, Lead__r.Name, Customer_Code__r.Name, Opportunity__r.Account.Name, Visit_Date__c, Key_Discussion_Description__c
                                                       FROM Customer_Connect__c
                                                       WHERE ID = :cusId
                                                      ];
            List<Attendee__c> attendeeList = [SELECT Id, Name, Customer_Connect__c, Contact__c, Contact__r.Name, User__c, User__r.Name 
                                              FROM Attendee__c 
                                              WHERE Customer_Connect__c =: cusId
                                             ];
            List<Actionable__c> actionables = [SELECT Id, Name, Customer_Connect__c, Contact__r.Name, MCM_actionable__c, Task__c, 
                                               Action_Owner__r.Name, Due_Date__c, Status__c, Include_in_MOM__c 
                                               FROM Actionable__c 
                                               Where Include_in_MOM__c = true
                                               AND Customer_Connect__c =: cusId
                                              ];
            
            if(customerConnectData != null){
                returnData.customerConnect = customerConnectData;
            }
            if(attendeeList != null && attendeeList.size()>0){
                returnData.attendees = attendeeList;
            }
            if(actionables != null && actionables.size()>0){
                returnData.actionable = actionables;
            }
            
            return returnData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class excelData{
        @AuraEnabled public Customer_Connect__c customerConnect;
        @AuraEnabled public List<Attendee__c> attendees;
        @AuraEnabled public List<Actionable__c> actionable;
    }
}