global class CreateCaseFromEmail implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Pattern pattern1 = Pattern.compile('\\b\\d{9}\\b');
        String uppercaseSubject = email.subject != null ? email.subject.toUpperCase() : '';
        String uppercaseBody = email.plainTextBody != null ? email.plainTextBody.toUpperCase() : '';
        String foundValue = null;

        Matcher matcherSubject = pattern1.matcher(uppercaseSubject);
        Matcher matcherBody = pattern1.matcher(uppercaseBody);

        if (matcherSubject.find()) {
            foundValue = matcherSubject.group();
        }else if(matcherBody.find()){
            foundValue = matcherBody.group();
        }
        System.debug('foundValue'+foundValue);
        
        String fromAddress = envelope.fromAddress;
        String messageId = email.messageId;
        System.debug('messageId'+messageId);
        List<Contact> contactFromEmail = [SELECT Id,AccountId From Contact WHERE Email =: fromAddress];
        
        Case newCaseRecord = New Case();
        newCaseRecord.Subject = email.subject;
        newCaseRecord.Description = email.plainTextBody;
        newCaseRecord.SuppliedEmail = envelope.fromAddress;
        newCaseRecord.SuppliedName = email.fromName;
        if(contactFromEmail != null && contactFromEmail.size()>0){
            newCaseRecord.ContactId = contactFromEmail[0].Id;
            if(contactFromEmail[0].AccountId != null){
                newCaseRecord.AccountId = contactFromEmail[0].AccountId;
            }
        }
        if(foundValue != null && foundValue != ''){
            Map<String,Object> apiResult = caseComponent.docketValidation(foundValue);
            if(apiResult != null){
                newCaseRecord = mappedToUpdatedCase(apiResult,newCaseRecord);
            }
        }
        insert newCaseRecord;

        EmailMessage emailMsg = new EmailMessage();
        emailMsg.Subject = email.subject;
        emailMsg.HtmlBody = email.htmlBody;
        emailMsg.TextBody = email.plainTextBody;
        emailMsg.FromAddress = envelope.fromAddress;
        emailMsg.FromName = email.fromName;
        emailMsg.Status = '3';
        emailMsg.ParentId = newCaseRecord.Id;
        insert emailMsg;

        if(email.textAttachments != null){
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = newCaseRecord.Id;
                insert attachment;
            }
        }
        if(email.binaryAttachments != null){
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = newCaseRecord.Id;
                insert attachment;
            }
        }
        result.success = true;
        return result;
    }
    
    private Case mappedToUpdatedCase(Map<String,Object> apiResult,Case newCase){
        List<Object> apiResponse = (List<Object>) apiResult.get('response');
        If(apiResult.get('result') == 'successful' && apiResult.get('response') != null && apiResponse.size()>0){
            List<Object> result = (List<Object>) ((Map<String,Object>)apiResponse[0]).get('result');
            String accId= (String)((Map<String,Object>)result[0]).get('CUSTOMER_CODE');
            String delstn = (String)((Map<String,Object>)result[0]).get('DELIVERY_STN');
            String booking = (String)((Map<String,Object>)result[0]).get('BOOKING_STN');
            String stockUO = (String)((Map<String,Object>)result[0]).get('STOCK_OU');
            newCase.Docket_Number__c = String.valueOf(((Map<String,Object>)result[0]).get('DOCKET_NO'));
            newCase.Consignee_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_MOBILE_NO');
            newCase.Risk_Coverage__c = (String)((Map<String,Object>)result[0]).get('DOCKET_TYPE');
            newCase.Decl_Cargo_value__c = (Decimal)((Map<String,Object>)result[0]).get('DECL_CARGO_VAL');
            newCase.Consignor_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_NAME');
            newCase.Booking_OU__c = (String)apiResult.get(booking);
            newCase.AccountId = (String) apiResult.get(accId);
            newCase.Docket_Status__c = (String)((Map<String,Object>)result[0]).get('DOCKET_STATUS');
            newCase.No_of_Packages_Delivered__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS_DELIVERED');
            newCase.Assured_Delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('ASSURED_DLY_DT'));
            newCase.Consignor_Mobile_No__c = (String)((Map<String,Object>)result[0]).get('CONSIGNOR_MOBILE_NO');
            newCase.Actual_Weight_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('ACTUAL_WT');
            newCase.COD_Type__c = (String)((Map<String,Object>)result[0]).get('COD_TYPE');
            newCase.POD_Type__c = (String)((Map<String,Object>)result[0]).get('POD_TYPE');
            newCase.Booking_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('BKG_DT'));
            newCase.Delivery_OU__c= (String)apiResult.get(delstn);
            newCase.Consignor_Pincode__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('CONSIGNOR_PINCODE'));
            newCase.PROD_SERV_CODE__c = Decimal.valueOf((String)((Map<String,Object>)result[0]).get('PROD_SERV_CODE'));
            newCase.Charged_Wt__c = String.valueOf((Decimal)((Map<String,Object>)result[0]).get('CHARGED_WT'));
            newCase.No_Of_Packages_Booked__c = (Decimal)((Map<String,Object>)result[0]).get('NO_OF_PKGS');
            newCase.Consignee_Name__c = (String)((Map<String,Object>)result[0]).get('CONSIGNEE_NAME');
            newCase.Actual_delivery_Date__c = Date.valueOf((String)((Map<String,Object>)result[0]).get('APPROVED_DLY_DT'));
            newCase.Docket_Validation__c= 'Valid';
            newCase.Company_of__c  = ((Map<String,Object>)apiResponse[0]).get('companyId') == 'GKE'?'102':'101';
            newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
            
            If ((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != 'N') {
                newCase.PDC_BLOCK__c = '0';
            }Else If((String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != null && (String)((Map<String,Object>)result[0]).get('PDC_BLOCK') != 'Y'){
                newCase.PDC_BLOCK__c = '1';
            }
            
            If ((String)((Map<String,Object>)result[0]).get('STOCK_OU') != null && (String)((Map<String,Object>)result[0]).get('STOCK_OU') != '') {
                newCase.Stock_OU__c = (String)apiResult.get((String)((Map<String,Object>)result[0]).get('STOCK_OU'));
            }
            
            If ((String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU') != null && (String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU') != '') {
                newCase.Stock_Receiving_OU__c = (String)apiResult.get((String)((Map<String,Object>)result[0]).get('STOCK_RECEIVING_OU'));
            }
            System.debug('newCase'+newCase);
        }
        return newCase;
    }
}