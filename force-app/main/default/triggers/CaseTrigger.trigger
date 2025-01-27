trigger CaseTrigger on Case (Before Insert,After Insert,Before Update, After Update){
    /*Before Insert*/
    if(Trigger.isBefore && Trigger.isInsert){
        Id complaintRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        List<Case> complaintCaseList = new List<Case>();

        for(Case cc : Trigger.new){
            if(cc.CCEC_Action_OU__c == null){
                if(cc.Stock_OU__c!=null){
                    cc.CCEC_Action_OU__c = cc.Stock_OU__c;
                }else if(cc.Stock_Receiving_OU__c!=null){
                    cc.CCEC_Action_OU__c = cc.Stock_Receiving_OU__c;
                }else if(cc.Delivery_OU__c != null){
                    cc.CCEC_Action_OU__c = cc.Delivery_OU__c;
                }
            } 
            if(cc.recordTypeId == complaintRecordType){
                complaintCaseList.add(cc);
            }
        }
        if(complaintCaseList.size()>0){
            HolidaysChecking.esclation(complaintCaseList); 
        } 
        if(UserInfo.getName() == 'Integration User'){
            CaseHelper.checkPickupRefno(Trigger.New); 
        }
        
        CaseHelper.stopCreateCaseWithWrongType(Trigger.New);
        CaseHelper.derivingLocationPickupOU(Trigger.new);
        CaseHelper.checkDuplicateDocketNumber(Trigger.new);
        CaseHelper.PreventDuplicateCasesForQuery(Trigger.new);
        CaseHelper.PreventDuplicateCasesForServiceRequest(Trigger.new);
        CaseHelper.CaseOwnerAssignment(Trigger.new);
    }

    /*After Insert*/
    if(Trigger.isAfter && Trigger.isInsert){
        FetchDataFromDocketController.deleteAssignmentCase(Trigger.New);
    }
    
    /*Before Update*/
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
        if(UserInfo.getName() == 'Integration User'){
            CaseHelper.checkPickupRefno(Trigger.new); 
        }
        CaseHelper.changeCaseOwner(Trigger.new, Trigger.oldMap);
        CaseHelper.prospectPickupToPuckup(Trigger.new,Trigger.oldMap);
        FetchDataFromDocketController.handleUserAssignment(Trigger.newMap,Trigger.oldMap);
    }

    /*Before Insert Or Before Update*/
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){  
        List<Case> caseList = new List<Case>();
        for(Case c : Trigger.new){
            if(Trigger.isInsert && c.Complaint_Status__c == 'C' && c.Status != 'Closed'){
                c.Status = 'Closed';
            }
            else if(Trigger.isUpdate && (Trigger.oldMap.get(c.Id).Complaint_Status__c != c.Complaint_Status__c && c.Complaint_Status__c == 'C' && c.Status != 'Closed')){
                c.Status = 'Closed';
            }
            if(c.AccountId == null && c.CustomerCode__c != null){
                caseList.add(c);
            }
        }
        if(caseList != null && caseList.size()>0){
            CaseHelper.blukExceptionHandle(caseList);
        }
        CaseHelper.complaintCloseCheck(Trigger.new, Trigger.oldMap);
    }

    /*After Update*/
    if(Trigger.isAfter && Trigger.isUpdate){
        Map<Id,Profile> apiProfile = new Map<Id,Profile>([SELECT Id FROM Profile WHERE Name IN: new List<String>{'API User','User API'}]);
        CaseHelper.callClaimRegApiUpdate(Trigger.new);
        if(!apiProfile.containsKey(UserInfo.getProfileId())){
            CaseHelper.shareCase(Trigger.newMap, Trigger.oldMap);
        }
    } 

    /*After Update And Avoid Recursion*/
    if(Trigger.isAfter && Trigger.isUpdate && CheckRecursive.smsApiCall == true){
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

    /*After Insert Or After Update*/
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        List<case> caseToBeHandle = New List<Case>();
        
        for(Case cs : Trigger.New){
            if(Trigger.isInsert && (cs.Complaint_Status__c == 'C' || cs.Status == 'Closed')){
                caseToBeHandle.add(cs);
            }
            else if(Trigger.isUpdate && ((Trigger.oldMap.get(cs.Id).Complaint_Status__c != cs.Complaint_Status__c && cs.Complaint_Status__c == 'C') || (Trigger.oldMap.get(cs.Id).Status != cs.Status && cs.Status == 'Closed'))){
                caseToBeHandle.add(cs);
            }
        }
        if(CheckRecursive.runAfterUpdate==true && !system.isBatch()){
            CheckRecursive.runAfterUpdate=false;
            CaseHelper.pickupOutboundCallout(Trigger.new);
        }
        if(caseToBeHandle != null && caseToBeHandle.size()>0){
            CaseHelper.closeCCECAndCaseStatus(caseToBeHandle);
        }
        CaseHelper.complaintClosedRelatedToPickup(Trigger.new, Trigger.oldMap);
    }
}