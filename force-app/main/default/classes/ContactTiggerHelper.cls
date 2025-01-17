public class ContactTiggerHelper {
    
    public static void duplicateContact(List<Contact> newContacts) {
        try {
            Set<String> phoneSet = new Set<String>();
            
            for (Contact con : newContacts) {
                phoneSet.add(con.MobilePhone);
            }
            
            List<Contact> existingContacts = [SELECT MobilePhone FROM Contact WHERE MobilePhone IN :phoneSet];
            
            for (Contact con : newContacts) {
                if (existingContacts.size() > 0) {
                    con.MobilePhone.addError('Duplicate Contact Found. Use Existing Contact.');
                }
            }
        } catch (Exception e) {
            // Handle the exception here
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    //Auto Creation of Employee Master on creation of Contact
    public static void employeeMasterCreationonInsert(List<Contact> newContacts) {
        List<Employee_Master__c> employeeMasterRecordsToCreate = new List<Employee_Master__c>();
        
        for (Contact newContact : newContacts) {
            if (newContact.StaffCode__c != null && newContact.Attached_OU__c != null) {
                Employee_Master__c newEmployee = new Employee_Master__c();
                newEmployee.First_Name__c = newContact.FirstName;
                newEmployee.Last_Name__c = newContact.LastName;
                newEmployee.Name__c = newContact.Name;
                newEmployee.Name = newContact.StaffCode__c;
                newEmployee.OU_Code__c = newContact.Attached_OU__c;
                employeeMasterRecordsToCreate.add(newEmployee);
            }
        }
        
        if (!employeeMasterRecordsToCreate.isEmpty()) {
            insert employeeMasterRecordsToCreate;
        }
    }
    //Auto Creation of Employee Master on Updation of Contact
    public static void employeeMasterCreationonUpdate(List<Contact> newContacts, Map<Id, Contact> oldContactsMap) {
        List<Employee_Master__c> employeeMastersToCreate = new List<Employee_Master__c>();
        
        for (Contact newContact : newContacts) {
            if (newContact.StaffCode__c != null && newContact.Attached_OU__c != null) {
                Contact oldContact = oldContactsMap.get(newContact.Id);
                
                if (oldContact == null || oldContact.StaffCode__c != newContact.StaffCode__c || oldContact.Attached_OU__c != newContact.Attached_OU__c) {
                    
                    Employee_Master__c newEmployee = new Employee_Master__c();
                    newEmployee.First_Name__c = newContact.FirstName;
                    newEmployee.Last_Name__c = newContact.LastName;
                    newEmployee.Name__c = newContact.Name;
                    newEmployee.Name = newContact.StaffCode__c;
                    newEmployee.OU_Code__c = newContact.Attached_OU__c;
                    employeeMastersToCreate.add(newEmployee);
                }
            }
        }
        
        if (!employeeMastersToCreate.isEmpty()) {
            insert employeeMastersToCreate;
        }
    }
    
    public static void processResignedContacts(List<Contact> updatedContacts) {
        List<User> usersToUpdate = new List<User>();
        Map<String, Id> staffCodeToManagerIdMap = new Map<String, Id>();
        
        for (Contact updatedContact : updatedContacts) {
            if (updatedContact.STAFF_STATUS__c == 'R') {
                if (updatedContact.StaffCode__c != null && updatedContact.STATUS__c == 'V') {
                    staffCodeToManagerIdMap.put(updatedContact.StaffCode__c, null);
                }
            }
        }
        
        List<User> matchingUsers = [SELECT Id, IsActive, ManagerId, Staff_Code__c FROM User WHERE Staff_Code__c IN :staffCodeToManagerIdMap.keySet()];
        
        Set<Id> managerIds = new Set<Id>();
        for (User matchingUser : matchingUsers) {
            if (matchingUser.IsActive) {
                managerIds.add(matchingUser.ManagerId);
                matchingUser.IsActive = false;
                usersToUpdate.add(matchingUser);
            }
        }
        
        Map<Id, User> managerIdToUserMap = new Map<Id, User>([SELECT Id,managerId FROM User WHERE Id IN :managerIds]);
        
        // Update the Owner field of the Contact record to the user's manager's ID
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Contact updatedContact : updatedContacts) {
            if (updatedContact.STAFF_STATUS__c == 'R' && updatedContact.StaffCode__c != null && updatedContact.STATUS__c == 'V') {
                Id managerId = staffCodeToManagerIdMap.get(updatedContact.StaffCode__c);
                if (managerId != null) {
                    User manager = managerIdToUserMap.get(managerId);
                    System.debug('manager '+manager);
                    if (manager != null) {
                        updatedContact.OwnerId = managerIdToUserMap.get(managerId).Id;
                        System.debug('OwnerId '+manager.Id);
                        contactsToUpdate.add(updatedContact);
                    }
                }
            }
        }
        
        // Update the contacts
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        
        // Update the users asynchronously in a separate transaction
        if (!usersToUpdate.isEmpty()) {
            String usersJson = JSON.serialize(usersToUpdate);
            updateUsersAsync(usersJson);
        }
    }
    
    @future
    public static void updateUsersAsync(String usersJson) {
        List<User> usersToUpdate = (List<User>) JSON.deserialize(usersJson, List<User>.class);
        update usersToUpdate;
    }
}