@isTest
private class TestMCM_EmailSchedular {

    @istest static void schedule(){
        Test.startTest();
        MCM_EmailSchedule obj = new MCM_EmailSchedule();
        String sch = '0 0 0 5 * ? *';
        String jobID = system.schedule('MCM Email Schedule for 5th of Every Month', sch, obj);
        Test.stopTest();
    }
}