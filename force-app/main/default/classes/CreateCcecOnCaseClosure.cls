public class CreateCcecOnCaseClosure {
    @InvocableMethod(label='Create CCEC on case closure' description='Create an open CCEC for case')
    public static void createCCECForCase(List<ID> caseIds) {
        System.debug(caseIds);
        createCcecFuture(caseIds);
    }
    
    @future
    public static void createCcecFuture(List<Id> caseId) {
        CCEC__c ccec = new CCEC__c();
        ccec.CCEC_Instructions__c = 'Arrange delivery and Share GA details';
        ccec.Case__c = caseId[0];
        ccec.Status__c = 'OP';
        insert ccec;
    }
    
}