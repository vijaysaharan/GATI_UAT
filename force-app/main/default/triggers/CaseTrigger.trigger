trigger CaseTrigger on Case (Before Insert,After Insert,Before Update, After Update)
{
    List<Case> caseidsPickup = new List<Case>();

    if(Trigger.isInsert && Trigger.isBefore){
        CaseHelper.stopCreateCaseWithWrongType(Trigger.New);
        for(Case cc: Trigger.new){
            if(cc.CCEC_Action_OU__c == null){
                if(cc.Stock_OU__c!=null){
                    cc.CCEC_Action_OU__c = cc.Stock_OU__c;
                }else if(cc.Stock_Receiving_OU__c!=null){
                    cc.CCEC_Action_OU__c = cc.Stock_Receiving_OU__c;
                }else if(cc.Delivery_OU__c != null){
                    cc.CCEC_Action_OU__c = cc.Delivery_OU__c;
                }
            } 
        }
        if(UserInfo.getName() == 'Integration User'){
            CaseHelper.checkPickupRefno(Trigger.New); 
        }
        Id complaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        List<Case> complaintCaseList = new List<Case>();
        
        for(Case c : trigger.new)
        {
            if(complaintRecordType == c.recordTypeId){
                complaintCaseList.add(c);
            }
        }
        if(complaintCaseList.size()>0){
            HolidaysChecking.esclation(complaintCaseList); 
        }   
        CaseHelper.derivingLocationPickupOU(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        List<case> caseForAttachmentError = new List<case>();
        for(case c : Trigger.new){
            if(c.Approval_Status__c == 'Y' && Trigger.oldMap.get(c.Id).Approval_Status__c  == 'Pending' && c.Type == 'Bill back of Expenses'){
                caseForAttachmentError.add(c);
            }
        }
        if(caseForAttachmentError != null && caseForAttachmentError.size()>0){
            CaseHelper.gaveErrorForAttachment(caseForAttachmentError);
        }
    }

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){  
        List<Case> caseList = new List<Case>();
        for(Case c : Trigger.new){
            if(c.AccountId == null && c.CustomerCode__c != null){
                caseList.add(c);
            }
        }
        if(caseList != null && caseList.size()>0){
            CaseHelper.blukExceptionHandle(caseList);
        }
    }

    if(trigger.isUpdate && trigger.isAfter){ 
        CaseHelper.callClaimRegApiUpdate(Trigger.new);
    }

    if(trigger.isUpdate && trigger.isBefore){       
        CaseHelper.changeCaseOwner(Trigger.New, Trigger.oldMap);
        if(UserInfo.getName() == 'Integration User'){
            CaseHelper.checkPickupRefno(trigger.new); 
        }
    }

    if(trigger.isAfter && trigger.isUpdate){  
        try{
            Map<Id,Profile> apiProfile = new Map<Id,Profile>([SELECT Id FROM Profile WHERE Name IN: new List<String>{'API User','User API'}]);
            if(!apiProfile.containsKey(UserInfo.getProfileId())){
                CaseHelper.shareCase(Trigger.newMap, Trigger.oldMap);
            }
        }
        catch(Exception e){}
    }

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        if(CheckRecursive.runAfterUpdate==true && !system.isBatch()){
            CheckRecursive.runAfterUpdate=false;
            CaseHelper.pickupOutboundCallout(Trigger.new);
        }
        CaseHelper.complaintClosedRelatedToPickup(Trigger.new, Trigger.oldMap);
    }
     
    if(Trigger.isBefore && (Trigger.isInsert)){
        CaseHelper.checkDuplicateDocketNumber(Trigger.new);        
        /*Query,Complaint,Service Request Changes For Preventing Duplicate Records*/
        CaseHelper.PreventDuplicateCasesForQuery(Trigger.New);
        CaseHelper.PreventDuplicateCasesForServiceRequest(Trigger.New);
    }
        
    if(Trigger.isBefore && Trigger.isUpdate){
        CaseHelper.prospectPickupToPuckup(Trigger.new,Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isUpdate && CheckRecursive.smsApiCall==true){
        CheckRecursive.smsApiCall=false;
        List<RecordType> rtType = [select Id,name, DeveloperName FROM RecordType WHERE DeveloperName = 'Complaint'];
        Map<Id,Case> caseMap = Trigger.oldMap;
        String message='';
        for(Case cas : Trigger.new){
            if(cas.Mobile__c!=null && cas.Origin!='WhatsApp' && cas.AccountId==null){
                if(cas.Pickup_Status__c=='ACP' && cas.Type=='Pick Up' && caseMap.get(cas.Id).Pickup_Status__c != cas.Pickup_Status__c){
                    message = 'Your pickup request with reference number'+ cas.CaseNumber+', scheduled for'+ cas.Pickup_Date__c+' has been assigned to our agent'+ cas.Pickup_GA_Name__c+' who can be reached on'+ cas.Pickup_GA_Contact__c+'. Contact us on 1860-123-4284 or customerservices@allcargologistics.com for assistance needed.Allcargogati';
                    SmsAlertOutbound.SMSCallOut(cas.Mobile__c, message);
                }
                else if(cas.Pickup_Status__c=='POP' && cas.Type=='Pick Up' && caseMap.get(cas.Id).Pickup_Status__c != cas.Pickup_Status__c){
                    message = 'Your pickup request with reference number'+ cas.CaseNumber+', scheduled for'+ cas.First_Schedule__c+' has been postponed to'+ cas.Pickup_Date__c+'. Just send Hi as WhatsApp message to 7400012000 to register a complaint in case of disagreement.Allcargogati';
                    SmsAlertOutbound.SMSCallOut(cas.Mobile__c, message);
                }
                else if(cas.Pickup_Status__c=='CAN' && cas.Type=='Pick Up' && caseMap.get(cas.Id).Pickup_Status__c != cas.Pickup_Status__c){
                    message = 'Your pickup request with reference number'+ cas.CaseNumber+', scheduled for'+cas.Pickup_Date__c+' has been cancelled due to'+ cas.Non_Pick_Up_Delivery_Reason__c+'. Just send Hi as WhatsApp message to 7400012000 to register a complaint in case of disagreement.Allcargogati';
                    SmsAlertOutbound.SMSCallOut(cas.Mobile__c, message);
                }
                else if(cas.Pickup_Status__c=='CLO' && cas.Type=='Pick Up' && caseMap.get(cas.Id).Pickup_Status__c != cas.Pickup_Status__c){
                    message = 'Your pickup request with reference number'+ cas.CaseNumber+' has been fulfilled. The consignment has been picked up from the scheduled address on'+ cas.Pickup_Date__c+'. Please note the Docket No'+ cas.Docket_Number__c+' for this consignment. Send Hi as a WhatsApp message to 7400012000 for assistance on-the-go with WhatsApp Genie. Allcargogati';
                    SmsAlertOutbound.SMSCallOut(cas.Mobile__c, message);
                }
                else if(cas.Docket_Number__c!=null && cas.RecordTypeId == rtType[0].Id && (cas.Complaint_Status__c=='C' || cas.Complaint_Status__c=='AC') && caseMap.get(cas.Id).Complaint_Status__c != cas.Complaint_Status__c){
                    SmsAlertOutbound.SMSCallOut(cas.Mobile__c, '');
                }
                else if(cas.Pick_Up_Ref_ID__c!=null && cas.RecordTypeId == rtType[0].Id && (cas.Complaint_Status__c=='C' || cas.Complaint_Status__c=='AC') && caseMap.get(cas.Id).Complaint_Status__c != cas.Complaint_Status__c){
                    SmsAlertOutbound.SMSCallOut(cas.Mobile__c, '');
                }
            }
        }
    }
    
    /*CLOSE CASE AND CCEC*/
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        List<case> caseToBeHandle = New List<Case>();
        for(Case cs : Trigger.New){
            if(Trigger.isInsert && cs.Complaint_Status__c == 'C' && cs.Status != 'Closed'){
                cs.Status = 'Closed';
            }else if(Trigger.isUpdate && (Trigger.oldMap.get(cs.Id).Complaint_Status__c != cs.Complaint_Status__c && cs.Complaint_Status__c == 'C' && cs.Status != 'Closed')){
                cs.Status = 'Closed';
            }
        }
        CaseHelper.complaintCloseCheck(Trigger.new, Trigger.oldMap);
    }
    
    /*CLOSE CASE AND CCEC*/
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        List<case> caseToBeHandle = New List<Case>();
        for(Case cs : Trigger.New){
            if(Trigger.isInsert && (cs.Complaint_Status__c == 'C' || cs.Status == 'Closed')){
                caseToBeHandle.add(cs);
            }else if(Trigger.isUpdate && ((Trigger.oldMap.get(cs.Id).Complaint_Status__c != cs.Complaint_Status__c && cs.Complaint_Status__c == 'C') || (Trigger.oldMap.get(cs.Id).Status != cs.Status && cs.Status == 'Closed'))){
                caseToBeHandle.add(cs);
            }
        }
        if(caseToBeHandle != null && caseToBeHandle.size()>0){
            CaseHelper.closeCCECAndCaseStatus(caseToBeHandle);
        }
    }
    
    /*Docket Number From Subject And Description*/
    if(Trigger.isBefore && Trigger.isUpdate){
        FetchDataFromDocketController.handleUserAssignment(Trigger.newMap,Trigger.oldMap);
    }
    /*Delete After Insert Case Of Assignment*/
    if(Trigger.isAfter && Trigger.isInsert){
        FetchDataFromDocketController.deleteAssignmentCase(Trigger.New);
    }
}