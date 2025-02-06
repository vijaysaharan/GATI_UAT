public class OUAssignController {
    @AuraEnabled
    public static List<OperationalUnitWrapper> getOperationalUnit(Id leadId){
        try {
            List<Organization_Master__c> pincodeLocations = new List<Organization_Master__c>();
            Map<Id, OperationalUnitWrapper> operationUnitToData = new Map<Id, OperationalUnitWrapper>();
            List<Lead> leadDetails = [SELECT Id, PostalCode,Lead_Assigned_OU__c  FROM Lead WHERE Id = :leadId AND PostalCode != null];

            if(leadDetails != null && leadDetails.size() > 0){
                String pincode = leadDetails[0].PostalCode;
                Id currentAssignedOu = leadDetails[0].Lead_Assigned_OU__c;
                Id pincodeLocationId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('Pincode').getRecordTypeId();
                Id operationalUnitId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('Operation_Unit').getRecordTypeId();

                pincodeLocations = [SELECT Id, RecordTypeId, Parent__c, Parent__r.RecordTypeId, Parent__r.Name 
                                    FROM Organization_Master__c 
                                    WHERE Name = :pincode
                                    AND Parent__c != :currentAssignedOu
                                    AND RecordTypeId = :pincodeLocationId
                                    AND Parent__r.RecordTypeId = :operationalUnitId
                                    ];
            }

            if(pincodeLocations != null && pincodeLocations.size() > 0){
                for(Organization_Master__c OrgMaster : pincodeLocations){
                    if(OrgMaster.Parent__c != null && !operationUnitToData.containsKey(OrgMaster.Parent__c)){
                        OperationalUnitWrapper operationUnitWrap = new OperationalUnitWrapper();
                        operationUnitWrap.operationId = OrgMaster.Parent__c;
                        operationUnitWrap.operationName = OrgMaster.Parent__r.Name;
                        operationUnitToData.put(OrgMaster.Parent__c, operationUnitWrap);
                    }
                }
            }
            return operationUnitToData.values();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateAssignedOU(Id leadId, Id assignedOuId){
        try {
            Lead leadDetail = new Lead(Id = leadId);
            leadDetail.Lead_Assigned_OU__c = assignedOUId;
            Database.SaveResult saveResult = Database.update(leadDetail);
            return saveResult.isSuccess();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class OperationalUnitWrapper{
        @AuraEnabled public Id operationId{get;set;}
        @AuraEnabled public String operationName{get;set;}
    }
}