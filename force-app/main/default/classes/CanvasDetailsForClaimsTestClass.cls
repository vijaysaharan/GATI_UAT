@isTest
public class CanvasDetailsForClaimsTestClass {
    @istest static void testCanvas(){
        Contact c = TestFactory.getContact('TestName', 'test@gmail.com');
        Case cs = ServiceTestFactory.getCase10('CRM',c.id);
        test.startTest();  
        CanvasDetailsForClaims.getData(cs.id,'EditLOF','Case');
        Test.StopTest();
    }
}