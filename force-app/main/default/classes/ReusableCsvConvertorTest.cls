@isTest
private class ReusableCsvConvertorTest {
    
    private static testMethod void testGetCsvData() {
        
        // create test data
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'test.csv'; // Set the PathOnClient field
        cv.VersionData = Blob.valueOf('Test data');
        insert cv;
        
        // call the method to be tested
        String result = ReuseableCsvConvertor.getCsvData(cv.Id);
        
        // verify the result
        System.assertEquals('Test data', result);
    }
    
    private static testMethod void testGetCsvDataError() {
        
        // create test data
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'test.csv'; // Set the PathOnClient field
        cv.VersionData = Blob.valueOf('Test data');
        insert cv;
        
        // call the method to be tested with an invalid contentVersionId
        try {
            String result = ReuseableCsvConvertor.getCsvData('invalidId');
            System.assert(false, 'Expected exception was not thrown.');
        } catch (AuraHandledException e) {
            // verify the exception message
            //System.assertEquals('List has no rows for assignment to SObject', e.getMessage());
        }
    }
}