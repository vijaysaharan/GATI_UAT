public with sharing class FilterBigDataStaticController {
    @AuraEnabled
    public static void getDataInRange(Date toDate, Date fromDate){
        try {
            GetAllAccountIdBatch g = new GetAllAccountIdBatch();
            g.isfilter = true;
            g.fromDate = fromDate;
            g.toDate = toDate;
            Database.executeBatch(g,2000);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean getCsvFlag(){
        List<AsyncApexJob> b = [select id from AsyncApexJob  where (Status = 'Processing' OR Status = 'Holding' OR Status = 'Preparing' OR Status = 'Queued') and (ApexClass.Name = 'CreateCsvFromFilter' OR  ApexClass.Name = 'ProcessCsvByList')];
        if(b.isEmpty()){
            return true;
        }else{
            return false;
        }
    }
}