global class ChangeAccountTeam {
    private static final String TEST_SESSION_ID = 'TEST_SESSION_ID';
    @InvocableMethod(label='Change Account Team' description='Change Account Team')
    global static List<Results> execute(List<Requests> requestList) {    
        
        List< Results> outputs = new List<Results>{};
            system.debug('RequestSize'+requestList.size());
        for (Requests request: requestList) {
            Results curResult = new Results();
            try{
                partnerSoapSforceCom.Soap myPartnerSoap = new partnerSoapSforceCom.Soap(); 
                String objecttype;
                if(request.targetRecordCollection == null) {
                    request.targetRecordCollection = new List<Sobject>();
                } else {
                    objecttype = request.targetRecordCollection[0].getSObjectType().getDescribe().getName();
                }
                
                if(request.targetRecord != null) {
                    objecttype = request.targetRecord.getSObjectType().getDescribe().getName();
                    request.targetRecordCollection.add(request.targetRecord);
                }
                System.debug('targetRecordCollection is: ' + request.targetRecordCollection);
                
                System.debug('objectype is: ' + objecttype);
                
                partnerSoapSforceCom.SessionHeader_element sessionHeader = new partnerSoapSforceCom.SessionHeader_element();  
                sessionHeader.sessionId = Test.isRunningTest() ? TEST_SESSION_ID : Page.usf3__GenerateSessionIdForLWC.getContent().toString();
                
                partnerSoapSforceCom.OwnerChangeOptions_element optionList = new partnerSoapSforceCom.OwnerChangeOptions_element();
                optionList.options = new List<partnerSoapSforceCom.OwnerChangeOption>();
                myPartnerSoap.OwnerChangeOptions = optionList;
                myPartnerSoap.sessionHeader = sessionHeader;
                partnerSoapSforceCom.OwnerChangeOption opt = new partnerSoapSforceCom.OwnerChangeOption();
                
                if(request.enforceNewOwnerHasReadAccess != null) {
                    opt.execute=request.enforceNewOwnerHasReadAccess;
                    opt.type_x = 'EnforceNewOwnerHasReadAccess';
                    optionList.options.add(opt);
                }
                
                if(request.TransferOwnedOpenCases != null) {
                    opt = new partnerSoapSforceCom.OwnerChangeOption();
                    opt.execute=request.TransferOwnedOpenCases;
                    opt.type_x = 'TransferOwnedOpenCases';
                    optionList.options.add(opt);
                } 
                List<partnerSoapSforceCom.sObject_x> xSObjectList = new List<partnerSoapSforceCom.sObject_x>();
                for(Sobject sobj : request.targetRecordCollection) {
                    partnerSoapSforceCom.sObject_x xSObj = new partnerSoapSforceCom.sObject_x();
                    xSObj.Id = sobj.Id;
                    xSObj.OwnerId = request.newOwnerId;
                    xSObj.type_x =  sobj.Id.getSObjectType().getDescribe().getName();
                    xSObjectList.add(xSObj);
                }
                
                if(String.isNotEmpty(request.targetRecordId)) {
                    partnerSoapSforceCom.sObject_x xSObj = new partnerSoapSforceCom.sObject_x();
                    xSObj.Id = request.targetRecordId;
                    Id sobjectId = (Id)request.targetRecordId;
                    xSObj.OwnerId = request.newOwnerId;
                    xSObj.type_x = sobjectId.getSObjectType().getDescribe().getName();
                    xSObjectList.add(xSObj);
                }
                List<partnerSoapSforceCom.SaveResult> mySaveResults = myPartnerSoap.update_x(xSObjectList);
                curResult.success = true;
                curResult.errorMessage = '';
                Integer i = 0;
                
                ProvideCsv__e pe = new ProvideCsv__e();
                pe.csvString__c = '';
                if(mySaveResults != null) {
                    for(partnerSoapSforceCom.SaveResult saveResult : mySaveResults) {
                        if(!saveResult.success) {
                            curResult.success = false;
                            curResult.errorMessage += '\n' + SaveResult.errors[0].message;
                            pe.csvString__c += '"' + ((String)request.targetRecordCollection[i].get('GATI_Customer_Code__c')) + '","' + SaveResult.errors + '"\n';
                            System.debug('csvString__c  ::'+ ((String)request.targetRecordCollection[i].get('GATI_Customer_Code__c')) + '","' + SaveResult.errors[0].message + '"\n');
                            ProvideCsv__e eventVal = new ProvideCsv__e();
                            eventVal.csvString__c = '"' + (String) request.targetRecordCollection[i].get('GATI_Customer_Code__c') + '","' + saveResult.errors[0].message + '"';
                            eventVal.ObjectName__c = (String) request.targetRecordCollection[i].get('GATI_Customer_Code__c');
                            EventBus.publish(eventVal);
                        } 
                        i++;
                    }
                    
                    Eventbus.publish(pe);
                }
                outputs.add(curResult);
                
            }catch(Exception e) {
                curResult.success = false;
                curResult.errorMessage = e.getMessage();
                outputs.add(curResult);
            }
        }
        return outputs;
    }
    
    
    global class Requests {
        
        @InvocableVariable
        global List<SObject> targetRecordCollection;
        
        @InvocableVariable
        global string targetRecordId;
        @InvocableVariable
        global SObject targetRecord;
        @InvocableVariable(required=true)
        global string newOwnerId;
        @InvocableVariable(label='Fail if the the new owner doesn\'t have read access on this record')
        global Boolean EnforceNewOwnerHasReadAccess;
        @InvocableVariable(label='When Transferring Cases with an Account, Transfer Open Cases Owned By The Original Owner')
        global Boolean TransferOwnedOpenCases;
        @InvocableVariable(label='When Transferring Cases with an Account, Transfer Open AND Closed Cases Owned By The Original Owner')
        global Boolean TransferAllOwnedCases;
    }
    
    global class Results {
        @InvocableVariable
        global Boolean success;
        @InvocableVariable
        global String errorMessage;
        
    }
}