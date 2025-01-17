public class AmazonS3FileRetriever implements Queueable, Database.AllowsCallouts {
	private String fileName;

    public AmazonS3FileRetriever(String fileName) {
        this.fileName = fileName;
    }
    
    public void execute(QueueableContext context) {
        if (!String.isBlank(fileName)) {
            String url = 'callout:AmazonS3Recieve/customer-retention-salesforce';
            HttpRequest req  = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setEndpoint(url + '/' + fileName);
            req.setMethod('GET');
            Http http = new Http();
            if(!Test.isRunningTest()){
                res = http.send(req);   
            }
            if(res.getStatusCode() == 200 || Test.isRunningTest()) {
                blob VersionData = res.getBodyasblob();
                if(VersionData != null){
                    AmazonS3BlobProcessBatch blobProcess = new AmazonS3BlobProcessBatch(VersionData);
                    Database.executeBatch(blobProcess,1);
                }
            }
        }
    }
}