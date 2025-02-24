@IsTest
public class CloseDuplicateCasesInvocableTest {
    @IsTest
    static void testCloseDuplicates() {
        List<Case> testCasesList = new List<Case>();
        Case testCase_1 =  New Case(
            Subject = 'Test Email To Case',
            Priority = 'Normal',
            SuppliedEmail = 'test@gmail.com',
            Origin = 'Email',
            Status = 'New',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId(),
            Description = 'Hi Test, You Are Sending Test 388508962.',
            CreatedDate = System.now()
        );
        testCasesList.add(testCase_1);
        Case testCase_2 =  New Case(
            Subject = 'Test Email To Case',
            Priority = 'Normal',
            SuppliedEmail = 'test@gmail.com',
            Origin = 'Email',
            Status = 'New',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId(),
            Description = 'Hi Test, You Are Sending Test 388508962.',
            CreatedDate = System.now()
        );
        testCasesList.add(testCase_2);
        insert testCasesList;
        test.startTest();
        CloseDuplicateCasesInvocable.closeStatusDuplicateCases(new List<Case>{testCase_1});
        test.stopTest();
    }
}