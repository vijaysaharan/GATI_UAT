@isTest
public class CanvasDetailsForCMSTestClass {
    @istest static void testCanvas(){
        
        Quote q = TestFactory.insertQuote('test', 'test', 'Print', 'BoundPaper', 'LETTER OF OFFER', '101');
        Account a = TestFactory.getAccount('test','KEA','400071',true);
        test.startTest();
        CanvasDetailsForCMS.getData(q.OpportunityId,'EditLOF','Opportunity');
        CanvasDetailsForCMS.getData(q.Id,'EditLOF','Quote');
        CanvasDetailsForCMS.getData(a.Id,'EditLOF','Account');
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'Hello World';
        t.Status = 'Open';
        t.Priority = 'Normal';
        t.WhatId = q.Id;
        insert t;
        CanvasDetailsForCMS.getData(t.Id,'EditLOF','Activity');
        
        
        Test.StopTest();
    }
    
}