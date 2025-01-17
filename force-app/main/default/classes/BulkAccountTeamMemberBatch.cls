global class BulkAccountTeamMemberBatch implements Database.Batchable<sobject> {
    String query;
    Map<Id, Id> mapAccountIdUserId = new Map<Id, Id>();
    Set<Id> setAccounts = new Set<Id>();
    List<Case> casesToUpdate = new List<Case>(); // Collect updated cases

    global BulkAccountTeamMemberBatch(String queryString, Map<Id, Id> getmapAccountIdUserId, Set<Id> getAccountIds) {
        query = queryString;
        mapAccountIdUserId = getmapAccountIdUserId;
        setAccounts = getAccountIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        for (Case eachCase : scope) {
            if (setAccounts.contains(eachCase.AccountId)) {
                eachCase.OwnerId = mapAccountIdUserId.get(eachCase.AccountId);
                casesToUpdate.add(eachCase); // Collect cases for update
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Use the PartnerSoapSforceCom.Soap for updating cases
        updateCasesWithSoapAPI(casesToUpdate);
    }

    private void updateCasesWithSoapAPI(List<Case> casesToUpdate) {
        PartnerSoapSforceCom.Soap sforceService = new PartnerSoapSforceCom.Soap();
        PartnerSoapSforceCom.SessionHeader_element headerElement = new PartnerSoapSforceCom.SessionHeader_element();
        headerElement.sessionId = UserInfo.getSessionId();
        sforceService.SessionHeader = headerElement;

        PartnerSoapSforceCom.sObject_x[] sObjectsToUpdate = new PartnerSoapSforceCom.sObject_x[casesToUpdate.size()];
        for (Integer i = 0; i < casesToUpdate.size(); i++) {
            Case caseRecord = casesToUpdate[i];
            PartnerSoapSforceCom.sObject_x caseSObject = new PartnerSoapSforceCom.sObject_x();
            caseSObject.type_x = 'Case';
            caseSObject.Id = caseRecord.Id;
            caseSObject.OwnerId = caseRecord.OwnerId;
            sObjectsToUpdate[i] = caseSObject;
        }

        PartnerSoapSforceCom.SaveResult[] results = sforceService.update_x(sObjectsToUpdate);

        // Process the results if needed
        for (Integer i = 0; i < results.size(); i++) {
            PartnerSoapSforceCom.SaveResult sr = results[i];
            if (sr.success) {
                // Case was updated successfully
                casesToUpdate[i].Id = sr.id; // Update the Id in the original list in case new Ids were generated
            } else {
                // Handle errors if necessary
                String errorMsg = sr.errors != null && sr.errors.size() > 0 ? sr.errors[0].message : 'Unknown error';
                System.debug('Error updating Case: ' + errorMsg);
            }
        }

        // Perform DML update for the cases after callouts are done
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
}