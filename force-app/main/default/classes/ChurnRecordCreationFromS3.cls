global class ChurnRecordCreationFromS3 implements Schedulable {    
    global void execute(SchedulableContext sc) {
        String fileName = ('Churn_Output'+System.today()).substringBefore(' ')+'.csv';
        System.enqueueJob(new AmazonS3FileRetriever(fileName));
    }
}