/*
Author     : Sumit Gupta (sgupta3@kloudrac.com)
Date       : Mar 10, 2022
Desc       : 
Class Name : Pickup_req_OutboundAPIQueueable
*/

@isTest(SeeAllData = false)
public class Pickup_req_OutboundAPIQueueableTest {
    static testMethod void myUnitTest(){
        
        
        List<string> caseId1 = new List<string>();
		caseId1.add('500p000000AqLwoAAF');  
            
        Test.startTest();
        System.enqueueJob(new Pickup_req_OutboundAPIQueueable(caseId1));
        Test.stopTest();  
    }
    

}