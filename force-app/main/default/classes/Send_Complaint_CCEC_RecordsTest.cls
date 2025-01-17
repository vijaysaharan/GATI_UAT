@isTest
public class Send_Complaint_CCEC_RecordsTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31006","result":"successful", "sErrMsg":"","response":[{"complaintRefNo":"00439524","result":"Posted Successfully "}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31006","result":"successful", "sErrMsg":"","response":[]}');
            res.setStatusCode(201);
            return res;
        }
    }
    /*@isTest
Static void testmethod2(){
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
Test.startTest();
Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
User user1=TestFactory.getUser('Test', 'Test', 'GMT', 'eu_ES', 'ISO-8859-1', 'en_US',
'Test'  + '@sdkksdhfhdsjhf.com', 'Test' + '@asjgdgsad.com');
AccountTeamMember accTeam=TestFactory.getAccountTeamMember(Acc1.id,user1.Id,'Service Resource');
Case case1=ServiceTestFactory.getCase('Claim','Email',null);
List<Case> caselist= new List<Case>();
for(Case cc:[Select id,origin,AccountId from case])
{
cc.AccountId=Acc1.Id;
Caselist.add(cc);

}
update Caselist;
CaseHelper.checkPickupRefno(caselist);
Test.stopTest();
}*/
    @isTest
    static void teststart()
    {   
        
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
            Account acc2=TestFactory.getAccount('TestAccount10' , 'SME', '521181', True);
            Account acc3=TestFactory.getAccount('TestAccount33' , 'SME', '521191', True);
            User user1=TestFactory.getUser('Test', 'Test', 'GMT', 'eu_ES', 'ISO-8859-1', 'en_US',
                                           'Test'  + '@sdkksdhfhdsjhf.com', 'Test' + '@asjgdgsad.com');
            User user2=TestFactory.getUser('Test2', 'Test2', 'GMT', 'eu_ES', 'ISO-8859-1', 'en_US',
                                           'Test2'  + '@sdkksdhfhdsjhf2.com', 'Test2' + '@asjgdgsad2.com');
            User user3=TestFactory.getUser('Test33', 'Test33', 'GMT', 'eu_ES', 'ISO-8859-1', 'en_US',
                                           'Test33'  + '@sdkksdhfhdsjhf2.com', 'Test33' + '@asjgdgsad2.com');
            AccountTeamMember accTeam=TestFactory.getAccountTeamMember(Acc1.id,user1.Id,'Service Resource');
            AccountTeamMember acc1Team=TestFactory.getAccountTeamMember(Acc2.Id,user2.Id,'Sales Rep');
            AccountTeamMember acc3Team=TestFactory.getAccountTeamMember(Acc3.id,user3.Id,'Service Resource');
            Case case1=ServiceTestFactory.getCase('Claim','Email',null);
            
          //  ServiceTestFactory.newCaseHistory(case1);
            //case3.AccountId=Acc3.Id;
            List<Case> caselist= new List<Case>();
            for(Case cc:[Select id,origin,AccountId from case])
            {
                cc.AccountId=Acc3.Id;
                Caselist.add(cc);
                
            }
            update Caselist;
            
        	CCEC__c ccec1 = ServiceTestFactory.getCCEC(case1.id);
            CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing', ccec1.Id,'CSA');
        	Test.startTest();
           // Send_Complaint_CCEC_Records.calloutMethod(case1.id,false);
			
           // Send_Complaint_CCEC_Records.calloutMethod(case1.id,false);
            Test.stopTest();
            Group group1=TestFactory.getGroup('test group', 'Queue');
            // QueuesObject queue=TestFactory.getQueuesObject(group1.id, 'Case');
            //Case case5 = TestFactory.getCase(null,'Pick Up','Email',null);
            //Case case6 = TestFactory.getCase(case5.CaseNumber,'Pending Pickup','Email',null);         
            Case case2=ServiceTestFactory.getCase('Claim','Email',null);
            Case case4=ServiceTestFactory.getCase2('Email',null);
            Case case5=ServiceTestFactory.getCase3('Email',acc1.id);
            Case case6=ServiceTestFactory.getCase4('Email',acc1.id);
            Case case7=ServiceTestFactory.getCase5('Email',acc1.id);
            //  case1.OwnerId =AccTeam.UserId;
            //  case2.OwnerId=group1.Id;
            //  System.AssertEquals(case1.OwnerId,AccTeam.UserId);
            //  System.AssertEquals(case2.OwnerId,group1.id);
            
            
            
        }
        Catch(Exception e)
        {
            system.debug('error is '+ e.getCause()+'--- '+e.getLineNumber()+'--'+e.getMessage());
        }
    }
    @isTest
    static void teststart2()
    {   
        
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
            
            Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
            Account acc2=TestFactory.getAccount('TestAccount10' , 'SME', '521181', True);
            Account acc3=TestFactory.getAccount('TestAccount33' , 'SME', '521191', True);
            User user1=TestFactory.getUser('Test', 'Test', 'GMT', 'eu_ES', 'ISO-8859-1', 'en_US',
                                           'Test'  + '@sdkksdhfhdsjhf.com', 'Test' + '@asjgdgsad.com');
            User user2=TestFactory.getUser('Test2', 'Test2', 'GMT', 'eu_ES', 'ISO-8859-1', 'en_US',
                                           'Test2'  + '@sdkksdhfhdsjhf2.com', 'Test2' + '@asjgdgsad2.com');
            User user3=TestFactory.getUser('Test33', 'Test33', 'GMT', 'eu_ES', 'ISO-8859-1', 'en_US',
                                           'Test33'  + '@sdkksdhfhdsjhf2.com', 'Test33' + '@asjgdgsad2.com');
            AccountTeamMember accTeam=TestFactory.getAccountTeamMember(Acc1.id,user1.Id,'Service Resource');
            AccountTeamMember acc1Team=TestFactory.getAccountTeamMember(Acc2.Id,user2.Id,'Sales Rep');
            AccountTeamMember acc3Team=TestFactory.getAccountTeamMember(Acc3.id,user3.Id,'Service Resource');
            Case case1=ServiceTestFactory.getCase('Claim','Email',null);
            
          //  ServiceTestFactory.newCaseHistory(case1);
            //case3.AccountId=Acc3.Id;
            List<Case> caselist= new List<Case>();
            for(Case cc:[Select id,origin,AccountId from case])
            {
                cc.AccountId=Acc3.Id;
                Caselist.add(cc);
                
            }
            update Caselist;
            
        	CCEC__c ccec1 = ServiceTestFactory.getCCEC(case1.id);
            CCEC_Remark__c ccecremark = ServiceTestFactory.getCCECRemarkWithCCEC('testing', ccec1.Id,'CSA');
        	Test.startTest();
            // Send_Complaint_CCEC_Records.calloutMethod(case1.id,false);
			
           // Send_Complaint_CCEC_Records.calloutMethod(case1.id,false);
            Test.stopTest();
            Group group1=TestFactory.getGroup('test group', 'Queue');
            // QueuesObject queue=TestFactory.getQueuesObject(group1.id, 'Case');
            //Case case5 = TestFactory.getCase(null,'Pick Up','Email',null);
            //Case case6 = TestFactory.getCase(case5.CaseNumber,'Pending Pickup','Email',null);         
            Case case2=ServiceTestFactory.getCase('Claim','Email',null);
            Case case4=ServiceTestFactory.getCase2('Email',null);
            Case case5=ServiceTestFactory.getCase3('Email',acc1.id);
            Case case6=ServiceTestFactory.getCase4('Email',acc1.id);
            Case case7=ServiceTestFactory.getCase5('Email',acc1.id);
            //  case1.OwnerId =AccTeam.UserId;
            //  case2.OwnerId=group1.Id;
            //  System.AssertEquals(case1.OwnerId,AccTeam.UserId);
            //  System.AssertEquals(case2.OwnerId,group1.id);
            
            
            
        }
        Catch(Exception e)
        {
            system.debug('error is '+ e.getCause()+'--- '+e.getLineNumber()+'--'+e.getMessage());
        }
    }
}