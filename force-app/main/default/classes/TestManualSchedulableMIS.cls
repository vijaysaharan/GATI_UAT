@isTest
public class TestManualSchedulableMIS {
    @istest static void taskscheduleMIS(){
Test.startTest();
    String sc2 = '0 0 0 1 * ? *';
        ManualMIS sc1 = new ManualMIS();
String jobID=system.schedule('Task Creation', sc2, sc1);
     Test.StopTest();
    }

     @istest static void taskscheduleMIS1(){
        Test.startTest();
        ManualMIS.reviewmethod();
        Test.StopTest();
}
}