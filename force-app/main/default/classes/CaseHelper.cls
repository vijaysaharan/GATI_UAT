public without sharing class CaseHelper{
    
    public static void changeCaseOwner(List<Case> caseList, Map<Id,Case> oldMap){
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Id> accountIdVSUserIdMap = new Map<Id,Id>();
        Map<String,Group> nameToGroup = new Map<String,Group>();
        List<String> groupNameList = new List<String>{'Approvals','Exception Team','Prospective Pickup Team','Pickup Team','Issue resolution Team'};
        List<Group> groupList = [SELECT Id, Type, Name FROM Group WHERE Type = 'Queue' AND Name IN: groupNameList];
        //List<Account> excludeAccount = [SELECT Id FROM Account WHERE GATI_Customer_Code__c =:label.SpecialGatiCustomerCode];

        for (Case caseObj : caseList){
            if(caseObj.Docket_Validation__c == 'Valid' && 
               ((oldMap == null && caseobj.AccountId!= null) || 
                (oldMap != null && ((oldMap.get(caseObj.Id).AccountId == null && caseObj.AccountId != null )
                                    || (oldMap.get(caseObj.Id).AccountId != caseObj.AccountId) || (oldMap.get(caseObj.Id).AccountId == caseObj.AccountId)
                                    || (caseObj.AccountId != null && oldMap.get(caseObj.Id).Docket_Validation__c != caseObj.Docket_Validation__c))))){
                accountIdSet.add(caseObj.AccountId);
            }
        }
        
        if(accountIdSet != null && accountIdSet.size()>0){
            List<AccountTeamMember> AccoutTeamMemberList=[SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN: accountIdSet AND TeamMemberRole='Service Resource'];
            for(AccountTeamMember accountTeamMemberObj : AccoutTeamMemberList){
                accountIdVSUserIdMap.put(accountTeamMemberObj.AccountId,accountTeamMemberObj.UserId);
            }
        }
        
        if(groupList != null && groupList.size()>0){
            for(Group gp : groupList){
                nameToGroup.put(gp.Name, gp);
            }
        }
        
        /*
        List<Group> issueResolutionQueue= [SELECT Id from Group where Type = 'Queue' and Name='Issue resolution Team'];
        List<Group> pickupqueue= [SELECT Id from Group where Type = 'Queue' and Name='Pickup Team'];
        List<Group> prospectivepickupqueue= [SELECT Id from Group where Type = 'Queue' and Name='Prospective Pickup Team'];
        List<Group> exceptionqueue= [SELECT Id from Group where Type = 'Queue' and Name='Exception Team'];
        List<Group> approvalsqueue= [SELECT Id from Group where Type = 'Queue' and Name='Approvals'];
        */

        for (Case caseObj : caseList){
            if(caseObj.Status=='New'){
                caseObj.Status='Open(Assigned)';
                if(caseObj.AccountId != Null && accountIdVSUserIdMap != null && accountIdVSUserIdMap.containsKey(caseObj.AccountId)){
                    caseObj.OwnerId=accountIdVSUserIdMap.get(caseObj.AccountId);
                }  
                else if(caseobj.Type == 'Pick Up' && nameToGroup != null && nameToGroup.containsKey('Pickup Team')){
                    caseobj.OwnerId=nameToGroup.get('Pickup Team').Id;
                }
                else if(caseobj.Type == 'Prospect Pickup' && nameToGroup != null && nameToGroup.containsKey('Prospective Pickup Team')){
                    caseobj.OwnerId=nameToGroup.get('Prospective Pickup Team').Id;
                }
                else if(caseobj.Type == 'Exception' && nameToGroup != null && nameToGroup.containsKey('Exception Team')){
                    caseobj.OwnerId=nameToGroup.get('Exception Team').Id;
                }
                else if((caseobj.Type == 'ADD Extension' || caseobj.Type == 'Appointment Delivery' 
                        || caseobj.Type == 'Bill back of Expenses' || caseobj.Type == 'Rebooking') && nameToGroup != null && nameToGroup.containsKey('Approvals')){
                    caseObj.OwnerId=nameToGroup.get('Approvals').Id;
                }
                else if(nameToGroup != null && nameToGroup.containsKey('Issue resolution Team') && (caseobj.Type == 'Pending Pickup' || caseobj.Type == 'Claim' || caseobj.Type == 'Delayed Connection'
                        || caseobj.Type == 'Undelivered' || caseobj.Type == 'Partial Delivery' || caseobj.Type == 'Claims' 
                        || caseobj.Type == 'Invoicing and Others' || caseobj.Type == 'DELIVERY REQUESTED BEFORE ADD' 
                        || caseobj.Type == 'REBOOKING WITHOUT INFORMATION' || caseobj.Type == 'VARIANCE IN ADD' || caseobj.Type == 'WRONG DELIVERY UPDATED')){
                    caseObj.OwnerId=nameToGroup.get('Issue resolution Team').Id;
                }
            }
        }
    }
    
    public static void shareCase( Map<Id,Case> newCasesMap, Map<Id,Case> oldCasesMap){
        try{
            List<Case> updatedCases = new List<Case>();
            Set<Id> oldOwnerIds = new Set<Id>();

            for(Id csId : newCasesMap.keyset()){
                if(newCasesMap.get(csId).OwnerId != oldCasesMap.get(csId).OwnerId){
                    updatedCases.add(oldCasesMap.get(csId));
                    oldOwnerIds.add(oldCasesMap.get(csId).OwnerId);
                }
            }
            
            if(updatedCases != null && updatedCases.size() > 0 && oldOwnerIds != null && oldOwnerIds.size()>0){
                List<CaseTeamMember> caseTeamMembersToInsert = new List<CaseTeamMember>();
                Map<Id, Set<Id>> caseIdToCaseTeamMembers = new Map<Id, Set<Id>>();

                Map<Id,User> oldActiveOwners = new Map<Id,User>([SELECT Id, ProfileId, IsActive FROM User WHERE Id IN: oldOwnerIds AND IsActive = true]);
                CaseTeamRole role = [SELECT Id FROM CaseTeamRole WHERE Name ='Creator' LIMIT 1];
                List<CaseTeamMember> caseTeamMembers = [SELECT Id,MemberId,ParentId FROM CaseTeamMember WHERE ParentId IN :newCasesMap.keySet()];

                if(caseTeamMembers != null && caseTeamMembers.size() > 0){
                    for(CaseTeamMember cm : caseTeamMembers){
                        if(caseIdToCaseTeamMembers.containsKey(cm.ParentId)){
                            caseIdToCaseTeamMembers.get(cm.ParentId).add(cm.MemberId);
                        }
                        else{
                            caseIdToCaseTeamMembers.put(cm.ParentId, new Set<Id>{cm.MemberId});
                        }
                    }
                }
                
                for(Case cs : updatedCases){
                    if(oldActiveOwners.containskey(cs.ownerId) && cs.Origin != 'Email' && (!caseIdToCaseTeamMembers.containsKey(cs.Id) || (caseIdToCaseTeamMembers.containsKey(cs.Id) && !caseIdToCaseTeamMembers.get(cs.Id).contains(cs.CreatedById)))){
                        CaseTeamMember ctm = new CaseTeamMember();
                        ctm.ParentId = cs.Id;
                        ctm.MemberId = cs.CreatedById;
                        ctm.TeamRoleId = role.Id;
                        caseTeamMembersToInsert.add(ctm);
                    }
                }
                if(caseTeamMembersToInsert != null && caseTeamMembersToInsert.size()>0){
                    Database.Insert(caseTeamMembersToInsert, false);
                }
            }
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   
    
    //NOT Called From Trigger Or Any Class
    public static void dupCaseError(List <Case> caseList) {
        Set<String> casedocket = new set<String>();
        Set<String> casetype = new set<String>();
        set<String> docketvstype = new set<String>();

        for(Case c : caselist){
            if(c.Docket_Number__c!=null && c.Sub_Type__c!=null){
                casedocket.add(c.Docket_Number__c);
                casetype.add(c.Sub_Type__c);
            }
        }

        List <Case> allCase = [SELECT Id, Docket_Number__c, Sub_Type__c 
                                FROM Case 
                                WHERE Docket_Number__c IN: casedocket 
                                AND Docket_Number__c != Null 
                                AND Sub_Type__c IN: casetype 
                                AND Sub_Type__c != Null
                                ];
        for(Case c : allcase){
            if(c.Docket_Number__c!=null && c.Sub_Type__c!=null ){
                docketvstype.add(c.Docket_Number__c + c.Sub_Type__c);
            }
        }

        for (Case DupeCase : CaseList){
            if(docketvstype.contains(DupeCase.Docket_Number__c + DupeCase.Sub_Type__c)){
                DupeCase.addError('Duplicate Case Error! This record already exists for same DOCKET NUMBER and SUB TYPE.');
            }
        }
    }
    
    public static void checkPickupRefno (List<Case> CaseList){
        Set<String> pickupref = new Set<String>();
        Set<String> casenolist = new Set<String>();

        for(Case c : CaseList){
            if(c.Pick_Up_Ref_No__c != Null){
                pickupref.add(c.Pick_Up_Ref_No__c);
            }
            if(c.Pick_Up_Ref_No__c != Null && c.Type =='Pick Up'){
                casenolist.add(c.Pick_Up_Ref_No__c);
            }
        }
        /*
        List<Case> allCase = [SELECT Id, CaseNumber FROM Case WHERE CaseNumber IN: pickupref AND Type='Pick Up'];
        
        for(Case c : allCase){
            casenolist.add(c.CaseNumber);
        }
        */
        for(Case ca : CaseList){
            if(ca.type == 'Pending Pickup' && ca.Pick_Up_Ref_No__c != null && !casenolist.contains(ca.Pick_Up_Ref_No__c)){
                ca.Pick_Up_Ref_No__c.addError('Kindly,enter valid pickup reference number');
            }
        }
    }
    
    public static void prospectPickupToPuckup(List<Case> caseListProspect, Map<Id,Case> oldCase){
        List<Group> pickupqueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name='Pickup Team' limit 1];
        Id prospectPickupRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Prospect Pickup').getRecordTypeId();
        Id pickUpRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pick Up').getRecordTypeId();

        for(Case cc : caseListProspect){
            if(pickUpRecordType!= null && prospectPickupRecordType != null && oldCase.get(cc.Id).RecordTypeId == prospectPickupRecordType &&  cc.RecordTypeId == pickUpRecordType && pickupqueue != null){
                cc.OwnerId = pickupqueue[0].Id;
            }
        }
    }
    
    public static void blukExceptionHandle(List<Case> caseList){
        Set<Decimal> customerCodeList = new Set<Decimal>();

        for(Case c : caseList){
            customerCodeList.add(c.CustomerCode__c);
        }
        List<Account> aclist = [SELECT Id, Customer_Code__c FROM Account WHERE Customer_Code__c IN: customerCodeList];
        if(aclist != null && aclist.size()>0){
            Map<Decimal,Id> codetoAcc = new Map<Decimal,Id>();
            Map<Id,Id> accToUser = new Map<Id,Id>();

            for(Account ac : aclist){
                codetoAcc.put(ac.Customer_Code__c, ac.Id);
            }
            List<AccountTeamMember> AccoutTeamMemberList=[SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN: codetoAcc.Values() AND TeamMemberRole='Service Resource'];
            if(AccoutTeamMemberList != null && AccoutTeamMemberList.size()>0){
                for(AccountTeamMember atm : AccoutTeamMemberList ){
                    accToUser.put(atm.AccountId, atm.UserId);
                }
            }
            for(Case c : caseList){
                if(accToUser.containsKey(c.AccountId)){
                    c.ownerId = accToUser.get(c.AccountId);
                }
                if(codetoAcc.containsKey(c.CustomerCode__c)){
                    c.AccountId = codetoAcc.get(c.CustomerCode__c);
                }
            }
        }  
    }
    
    //NOT Call By Trigger Or Any Class
    public static void exceptionCreation(List<Case> caseList){
        Map<String, String> docketNumberWithSubType = new Map<String, String>();

        for(Case cc : caseList){
            if(cc.Docket_Number__c != null && cc.Type == 'Exception'){
                docketNumberWithSubType.put(cc.Docket_Number__c, cc.Docket_Number__c+'.'+cc.Sub_Type__c+'.'+cc.Stock_OU__c);
            }
        }
        
        List<Case> caseOldList = [SELECT Id, Docket_Number__c, Unique_Docket_Subtype__c, Sub_Type__c, Stock_OU__c 
                                  FROM Case WHERE Docket_Number__c IN:docketNumberWithSubType.keySet() AND Status='Open(Assigned)'];
        for(Case caseMatch : caseList){
            for(Case caseOldmatch : caseOldList){
                if(docketNumberWithSubType.get(caseMatch.Docket_Number__c) == caseOldmatch.Docket_Number__c+'.'+caseOldmatch.Sub_Type__c+'.'+caseOldmatch.Stock_OU__c){
                    caseMatch.Docket_Number__c.addError('One case already exist with this docker number, please try another.');
                }
            }
        }
    }
    
    public static void derivingLocationPickupOU(List<Case> caseList){
        Set<Id> orgIds = new Set<Id>();
        Map<Id,Organization_Master__c> orgMap = new Map<Id,Organization_Master__c>();
        
        for(Case casecc : caseList){
            if(casecc.Status != 'Closed' && (casecc.Type=='Pick Up' || casecc.Type=='Prospect Pickup') && casecc.Pick_Up_Pincode__c!=null){
                orgIds.add(casecc.Pick_Up_Pincode__c);
            }
        }
        
        List<Organization_Master__c> orgList = [SELECT Id,Location__c,Parent__c from Organization_Master__c WHERE Id IN:orgIds];
        if(!orgList.isEmpty() && orgList.size()>0){
            for(Organization_Master__c org: orgList){
                orgMap.put(org.Id,org);
            }
            
            for(Case updateOU : caseList){
                if(orgMap.containsKey(updateOU.Pick_Up_Pincode__c) && orgMap.get(updateOU.Pick_Up_Pincode__c).Location__c != null)
                    updateOU.Shipper_Location__c = orgMap.get(updateOU.Pick_Up_Pincode__c).Location__c;
                if(orgMap.containsKey(updateOU.Pick_Up_Pincode__c) && orgMap.get(updateOU.Pick_Up_Pincode__c).Parent__c != null)
                    updateOU.PickUp_OU__c = orgMap.get(updateOU.Pick_Up_Pincode__c).Parent__c;
                if(updateOU.Type =='Prospect Pickup'){
                    updateOU.Receiver_Pincode__c = updateOU.Delivery_Pincode_Location__r.Name;
                }
            }
        } 
    }
    
    public static void caseCloseAutoCCECClose(List<Case> newList){
        Set<Id> caseIds = new Set<Id>();
        List<CCEC__c> closeCCECAuto = new List<CCEC__c>();
        for(Case cs : newList){
            if(cs.Type=='Exception'){
                if((cs.Sub_Type__c=='Likely to fail' || cs.Sub_Type__c=='Likely to be lost') && cs.Status=='Closed'){
                    caseIds.add(cs.Id);
                }
            }
        }
        if(!caseIds.isEmpty() && caseIds.size()>0){
            List<CCEC__c> ccecList = [SELECT Id,Case__c,Status__c FROM CCEC__c WHERE Case__c IN:caseIds AND Status__c='OP'];
            if(!ccecList.isEmpty() && ccecList.size()>0){
                for(CCEC__c cc : ccecList){
                    cc.Status__c='CL';
                    closeCCECAuto.add(cc);
                }
            }
            if(!closeCCECAuto.isEmpty() && closeCCECAuto.size()>0){
                database.update(closeCCECAuto,true);
            }
        }        
    }
    
    //API Callout for Type Claim
    public static void callClaimRegApiUpdate(List<Case> caseList){
        List<Id> claimIds = new List<Id>();
        for(Case cs : caseList){
            if(cs.Type == 'Claim'){
                claimIds.add(cs.Id);
            }
        }
        if(claimIds != null && claimIds.size() > 0){
            Claim_Registration_OutboundAPI.calloutMethod(claimIds);
        }
    }
    
    
    public static void checkDuplicateDocketNumber(List<Case> cases) {
        Set<String> docketNumbers = new Set<String>();
        for (Case c : cases) {
            if ( c.Docket_Number__c != null && c.Type =='Delayed Connection' && c.Complaint_Status__c == 'O') {
                docketNumbers.add(c.Docket_Number__c);
            }
        }
        List<Case> existingCasesList = [SELECT ID, Type, Status, Docket_Number__c FROM Case WHERE Docket_Number__c IN :docketNumbers AND Type = 'Delayed Connection' AND Complaint_Status__c = 'O'];
        
        Map<String, Id> docketNumberToCaseId = new Map<String, Id>();
        for (Case existingCases : existingCasesList) {
            docketNumberToCaseId.put(existingCases.Docket_Number__c, existingCases.Id);
        }
        for (Case newCases : cases) {
            if (docketNumberToCaseId.containsKey(newCases.Docket_Number__c)) {
                newCases.addError('Another case with the same docket number and an open status already exists: ' + docketNumberToCaseId.get(newCases.Docket_Number__c));
            }
        }
    }
    
    public static void populateContactFields(List<Case> cases) {
        Set<Id> contactIds = new Set<Id>();
        for (Case caseRecord : cases) {
            if (caseRecord.ContactId != null) {
                contactIds.add(caseRecord.ContactId);
            }
        }
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Email, MobilePhone, MailingAddress FROM Contact WHERE Id IN :contactIds]);
        
        for (Case caseRecord : cases) {
            if (caseRecord.Type == 'Pick Up' && caseRecord.ContactId != null) {
                Contact contact = contactsMap.get(caseRecord.ContactId);
                if (contact != null) {
                    caseRecord.Customer_Email__c = contact.Email;
                    caseRecord.SuppliedPhone = contact.MobilePhone;
                    caseRecord.Pickup_Address1__c = formatMailingAddress(contact.MailingAddress);
                }
            }
        }
    }
    
    private static String formatMailingAddress(Address address) {
        if (address != null) {
            String formattedAddress = '';
            if (address.street != null) {
                formattedAddress += address.street + '\n';
            }
            if (address.city != null) {
                formattedAddress += address.city + ', ';
            }
            if (address.state != null) {
                formattedAddress += address.state + ' ';
            }
            if (address.postalCode != null) {
                formattedAddress += address.postalCode;
            }
            return formattedAddress.trim();
        }
        return null;
    }
    
    public static void gaveErrorForAttachment(List<Case> caseList){
        Map<Id,ContentVersion> caseIdContentVersionMap = New Map<Id,ContentVersion>();
        List<ContentVersion> conVersionList = [Select Id,FirstPublishLocationId From ContentVersion Where FirstPublishLocationId In: caseList];
        if(conVersionList != null && conVersionList.size()>0){
            For(ContentVersion cv : conVersionList){
                caseIdContentVersionMap.put(cv.FirstPublishLocationId,cv);
            }
        }
        For(Case cs : caseList){
            if(!caseIdContentVersionMap.containsKey(cs.Id)){
                cs.addError('Please upload the required document before proceeding with the approval process.');
            }
        }
    }
       
    //Preventing Qurey Cases with same docket number if Status is not closed
    public static void PreventDuplicateCasesForQuery(List<Case> caseList){
        Set<String> docketNumberSet = new Set<String>();
        Map<String,List<Case>> docketNumberToCase = new Map<String,List<Case>>();

        Id queryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Query').getRecordTypeId();
        
        for(Case cs : caseList){
            if(cs.RecordTypeId == queryRecordTypeId  && cs.Docket_Number__c != null){        
                docketNumberSet.add(cs.Docket_Number__c);
            }
        }
        List<Case> existingCaseList = [SELECT Id, Docket_Number__c
                                        FROM Case
                                        WHERE RecordTypeId =: queryRecordTypeId
                                        AND Docket_Number__c IN: docketNumberSet
                                        AND Status != 'Closed'
                                      ];
        if(existingCaseList != null && existingCaseList.size()>0){
            for(Case cs : existingCaseList){
                if(docketNumberToCase.containsKey(cs.Docket_Number__c)){
                    docketNumberToCase.get(cs.Docket_Number__c).add(cs);
                }else{
                    docketNumberToCase.put(cs.Docket_Number__c,new List<Case>{cs});
                }
            }
            for(Case c : caseList){
                if(docketNumberToCase.containsKey(c.Docket_Number__c)){
                    c.addError('Case is already created with this docket number and case is not closed.');
                }
            }
        }
    }
    
    //Prevent Cases Of Service Request Type And same docket Number And Status is Open
    public static void PreventDuplicateCasesForServiceRequest(List<Case> caseList){
        Set<String> docketNumberSet = new Set<String>();
        Map<String,List<Case>> docketNumberToCase = new Map<String,List<Case>>();
        Id serviceRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        
        for(Case cs : caseList){
            if((cs.RecordTypeId == serviceRequestRecordTypeId || cs.RecordTypeId == complaintRecordTypeId) && cs.Docket_Number__c != null){        
                docketNumberSet.add(cs.Docket_Number__c);
            }
        }
        
        List<Case> existingCaseList = [SELECT Id, Docket_Number__c, Type , RecordTypeId
                                        FROM Case
                                        WHERE (RecordTypeId =: serviceRequestRecordTypeId OR RecordTypeId =: complaintRecordTypeId)
                                        AND Docket_Number__c IN: docketNumberSet
                                        AND Status != 'Closed'
                                      ];
        
        if(existingCaseList != null && existingCaseList.size()>0){
            for(Case cs : existingCaseList){
                String key = cs.Docket_Number__c +'-'+ cs.Type+'-'+cs.RecordTypeId;
                if(docketNumberToCase.containsKey(key)){
                    docketNumberToCase.get(key).add(cs);
                }else{
                    docketNumberToCase.put(key,new List<Case>{cs});
                }
            }
            for(Case c : caseList){
                String key = c.Docket_Number__c+'-'+c.Type+'-'+c.RecordTypeId;
                if(docketNumberToCase.containsKey(key)){
                    c.addError('Case is already created with this docket number and case is not closed.');
                }
            }
        }
    }
    
    //Close Case And CCEC
    public static void closeCCECAndCaseStatus(List<Case> caseList){
        List<CCEC__c> ccecList = New List<CCEC__c>();
        ccecList = [SELECT Id, Status__c FROM CCEC__c WHERE Case__c IN: caseList AND Status__c = 'OP'];
        if(ccecList != null && ccecList.size()>0){
            for(CCEC__c cc : ccecList){
                cc.Status__c = 'AC';
            }
            update ccecList;
        }
    }
    
    //Prevent Case Creation With Wrong Case Type
    public static void stopCreateCaseWithWrongType(List<Case> caseList){
        List<String> typeValues = new List<String>();

        Schema.DescribeFieldResult typeDescribe = Case.Type.getDescribe();
        List<Schema.PicklistEntry> pickListData = typeDescribe.getPicklistValues();
        for(Schema.PicklistEntry entry : pickListData){
            typeValues.add(entry.getValue());
        }
        
        for(Case cs : caseList){          
            if(cs.Type != null && !typeValues.contains(cs.Type)){
                cs.addError('Please select correct case type');
            }
        }
    }

    //Complaint Close Related to PickUp
    public static void complaintClosedRelatedToPickup(List<Case> caseList, Map<Id, Case> caseOldMap){
        Set<Id> pickupCaseIds = new Set<Id>();
        List<Case> complaintCases = new List<Case>();
        List<Case> complaintToUpdate = new List<Case>();

        Id pickupRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick_Up').getRecordTypeId();

        for(Case cs : caseList){
            if(cs.RecordTypeId == pickupRecordTypeId && (cs.Pickup_Status__c == 'CAN' || cs.Pickup_Status__c == 'CLO' || cs.Pickup_Status__c == 'FORC') && cs.Pickup_Status__c != caseOldMap.get(cs.Id).Pickup_Status__c){
                pickupCaseIds.add(cs.Id);
            }
        }

        if(pickupCaseIds != null && pickupCaseIds.size() > 0){
            complaintCases = [SELECT Id, Status FROM Case Where Pick_Up_Ref_ID__c IN :pickupCaseIds AND Complaint_Status__c NOT IN ('C','AC')];
        }

        if(complaintCases != null && complaintCases.size() > 0){
            for(Case complaint : complaintCases){
                complaint.Complaint_Status__c = 'C';
                complaintToUpdate.add(complaint);
            }
        }

        if(complaintToUpdate != null && complaintToUpdate.size() > 0){
            Database.update(complaintToUpdate, false);
        }
    }    
    
    //Pickup Outbound Callout
    public static void pickupOutboundCallout(List<Case> caseList){
        List<Case> caseToSend = new List<Case>();

        Id pickupRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick_Up').getRecordTypeId();
        Id prospectPickupRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prospect_Pickup').getRecordTypeId();
        Id serviceRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();

        for(Case cs : caseList){
            if(cs.Type == 'Pick Up' && cs.Sync_flag__c == false && (cs.RecordTypeId == pickupRecordTypeId || cs.RecordTypeId == prospectPickupRecordTypeId || cs.RecordTypeId == serviceRequestRecordTypeId)){
                caseToSend.add(cs);
            }
        }

        if(caseToSend != null && caseToSend.size() > 0){
            Pickup_req_OutboundAPINew pickup = new Pickup_req_OutboundAPINew(caseToSend);
            Database.executeBatch(pickup, 1);
        }
    }

    //Close Complaint When It Created With Pick that have status is CAN or pickup CLO.
    public static void complaintCloseCheck(List<Case> caseList, Map<Id, Case> caseOldMap){
        Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        Set<Id> pickUpIds = new Set<Id>();
        Set<Id> closedPickupIds = new Set<Id>();
        List<Case> ComplaintsForUpdate = new List<Case>();

        for(Case complaint : caseList){
            if(complaint.RecordTypeId == complaintRecordTypeId && complaint.Pick_Up_Ref_ID__c != null && (complaint.Complaint_Status__c != 'C' || complaint.Complaint_Status__c != 'AC')){
                pickUpIds.add(complaint.Pick_Up_Ref_ID__c);
                ComplaintsForUpdate.add(complaint);
            }
        }

        if(pickUpIds != null && pickUpIds.size() > 0){
            List<Case> pickupCases = [SELECT Id, Pickup_Status__c 
                                      FROM Case 
                                      WHERE Id IN :pickUpIds
                                      AND (Pickup_Status__c = 'CAN' OR Pickup_Status__c = 'CLO' OR Pickup_Status__c = 'FORC')
                                     ];
            for(Case pickup : pickupCases){
                closedPickupIds.add(pickup.Id);
            }
        }

        if(closedPickupIds != null && closedPickupIds.size() > 0){
            for(Case cs : ComplaintsForUpdate){
                if(closedPickupIds.contains(cs.Pick_Up_Ref_ID__c)){
                    cs.Complaint_Status__c = 'C';
                    cs.Status = 'Closed';
                }
            }
        }
    }

    //Case Owner Assignment According to Account Associated OU
    public static void CaseOwnerAssignment(List<Case> caseList){
        Set<Id> accountIds = new Set<Id>();
        List<AccountTeamMember> accountTeamList = new List<AccountTeamMember>();
        Map<Id, Account> accountToId = new Map<Id, Account>();
        Map<Id, List<AccountTeamMember>> accountIdToTeamMap = new Map<Id, List<AccountTeamMember>>();

        for(Case cs : caseList){
            if(cs.AccountId != null){
                accountIds.add(cs.AccountId);
            }
        }
        if(accountIds != null && accountIds.size() > 0){
            accountToId = new Map<Id, Account>([SELECT Id, Associated_OU__c, Associated_OU__r.Parent__r.Parent__r.CSUser__c,
                                                Customer_Category__c 
                                                FROM Account 
                                                WHERE Id IN :accountIds 
                                                AND Customer_Category__c IN ('Strategic','KEA','MSME') 
                                                AND Associated_OU__c != null
                                                AND Associated_OU__r.Parent__r.Parent__r.RecordType.DeveloperName  = 'EDC' 
                                                AND Associated_OU__r.Parent__r.Parent__r.CSUser__c != null 
                                                AND Associated_OU__r.Parent__r.Parent__r.CSUser__r.IsActive = true
                                              ]);
            if(accountToId.keySet() != null && accountIds.size() > 0){
                accountTeamList = [SELECT Id,AccountId FROM AccountTeamMember WHERE AccountId IN :accountToId.keySet() AND TeamMemberRole = 'Service Resource'];
            }
            if(accountTeamList != null && accountTeamList.size() > 0){
                for(AccountTeamMember member : accountTeamList){
                    if(accountIdToTeamMap.containsKey(member.AccountId)){
                        accountIdToTeamMap.get(member.AccountId).add(member);
                    }
                    else{
                        accountIdToTeamMap.put(member.AccountId, new List<AccountTeamMember>{member});
                    }
                }
            }
            if(accountToId.keySet() != null && accountIds.size() > 0){
                for(Case cs : caseList){
                    if(cs.AccountId != null && accountToId.containsKey(cs.AccountId) && !accountIdToTeamMap.containsKey(cs.AccountId)){
                        cs.OwnerId = accountToId.get(cs.AccountId).Associated_OU__r.Parent__r.Parent__r.CSUser__c;
                        cs.Status = 'Open(Assigned)';
                    }
                }
            }
        }            
    }
}