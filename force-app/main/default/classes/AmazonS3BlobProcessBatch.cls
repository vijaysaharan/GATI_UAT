global class AmazonS3BlobProcessBatch implements Database.batchable<Blob>, database.stateful {
    public Blob blobDetail;
    public String allData;
    
    global AmazonS3BlobProcessBatch(Blob blobData){
        blobDetail = blobData;
    }
    
    global Iterable<Blob> start(Database.BatchableContext bc){
        return new List<Blob>{blobDetail};
    }
    
    global void execute(database.BatchableContext bc, List<Blob> blobData){
        allData = UpdateChurnOutputAmazonS3.blobToString(blobData[0], 'ISO-8859-1');
    }
    
    global void finish(database.BatchableContext bc) {
        UpdateChurnOutputAmazonS3 b = new UpdateChurnOutputAmazonS3(allData);
		Database.executeBatch(b,200);
    }
}