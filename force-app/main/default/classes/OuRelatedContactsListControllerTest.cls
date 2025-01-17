@isTest
public with sharing class OuRelatedContactsListControllerTest {
    @isTest
    public static void getRelatedContactsTest() {
        Organization_Master__c test1 = New Organization_Master__c(
            Name = '301302'
        );
        insert test1;
        Test.startTest();
        OuRelatedContactsListController.getRelatedContacts(test1.Id);
        Test.stopTest();
    }
}