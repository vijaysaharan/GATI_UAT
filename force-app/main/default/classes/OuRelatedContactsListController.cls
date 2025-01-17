public without sharing class OuRelatedContactsListController {
   @AuraEnabled
   public static List<Contact> getRelatedContacts(Id recordId){
    try {
        List<Contact> contactList = New List<Contact>();
        contactList = [
                        SELECT Id,Name,Email,MobilePhone,BANK_BRANCH_NAME__c,StaffCode__c,Vertical__c,Staff_Role__c 
                        FROM Contact 
                        WHERE Attached_OU__c =: recordId
                        AND StaffCode__c != null
                        AND STAFF_STATUS__c = 'W'
                        ];
        return contactList;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
   }
}