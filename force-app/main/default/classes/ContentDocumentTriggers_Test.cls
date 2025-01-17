@isTest
public class ContentDocumentTriggers_Test {
    private static Opportunity getCustomObject(){
        
        Opportunity item = new Opportunity(
            Name = 'Test Item',
            CloseDate = System.today().addDays(10),
            Amount = 452100,
            StageName = 'Qualified'
        );
        insert item;
        return item;
    }
    @isTest
    static void testCDLinkcud() {
        Opportunity item = getCustomObject();
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = item.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        ContentDocumentLinkTriggerHelper.updateallCOs();
        
        delete cdl;
    }
    @isTest
    static void deletedoc() {
        Opportunity item = getCustomObject();
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = item.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        delete documents;
    }
    
}