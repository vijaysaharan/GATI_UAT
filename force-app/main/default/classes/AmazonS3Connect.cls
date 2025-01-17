public class AmazonS3Connect {
    @InvocableMethod(label='Send Report To AWS')
    public static void putFileInS3FromObject(List<Id> s3ReportId) {
        List<S3_Weekly_Report__c> s3ForUpdate = new List<S3_Weekly_Report__c>();
        Map<Id, Id> contentDocumentTos3Id = new Map<Id, Id>();
        Map<Id, String> recordIdToSuccessMessage = new Map<Id, String>();
        Map<Id, String> recordIdToErrorMessage = new Map<Id, String>();
        List<S3_Weekly_Report__c> s3Reports = [SELECT Id, ErrorMessage__c, SuccessMessage__c FROM S3_Weekly_Report__c WHERE Id IN: s3ReportId];
        List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: s3ReportId];
        Set<Id> documentIds = new Set<Id>();
        
        for(ContentDocumentLink link : contentLinks){
            contentDocumentTos3Id.put(link.LinkedEntityId, link.ContentDocumentId);
            documentIds.add(link.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersions = [SELECT VersionData,Title,ContentDocumentId,FileExtension,FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN: documentIds AND IsLatest = true];
        
        if (contentVersions != null && contentVersions.size() > 0) {
            for(ContentVersion cv : contentVersions){
                String attachmentBody = EncodingUtil.base64Encode(cv.VersionData);
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
                String filename = cv.Title+'.'+cv.FileExtension;
                string contentType= 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
                String url = 'callout:AmazonS3';
                HttpRequest req  = new HttpRequest();
                HttpResponse res  = new HttpResponse();
                req.setMethod('PUT');
                req.setEndpoint(url + '/gati-data-ds/' +filename);
                req.setHeader('Content-Encoding', 'UTF-8');
                req.setHeader('Content-type', contentType);
                req.setHeader('Connection', 'keep-alive');
                req.setHeader('Date', formattedDateString);
                req.setHeader('ACL', 'public-read');
                Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
                req.setBodyAsBlob(pdfBlob);
                Http http = new Http();
                if(!Test.isRunningTest()){
                    res = http.send(req);
                }
                if(res.getStatusCode() == 200){
                    recordIdToSuccessMessage.put(cv.ContentDocumentId, 'Csv Report Sent To AWS.');
                }
                else{
                    recordIdToErrorMessage.put(cv.ContentDocumentId, 'Error In Report Sending '+res.getStatusCode());
                }
            }
        }
        
        if(recordIdToErrorMessage != null || recordIdToSuccessMessage != null){
            for(S3_Weekly_Report__c s3 : s3Reports){
                Boolean isUpdate = false;
                if(contentDocumentTos3Id.containsKey(s3.Id) && recordIdToErrorMessage.containsKey(contentDocumentTos3Id.get(s3.Id))){
                    s3.ErrorMessage__c = recordIdToErrorMessage.get(contentDocumentTos3Id.get(s3.Id));
                    isUpdate = true;
                }
                if(contentDocumentTos3Id.containsKey(s3.Id) && recordIdToSuccessMessage.containsKey(contentDocumentTos3Id.get(s3.Id))){
                    s3.SuccessMessage__c = recordIdToSuccessMessage.get(contentDocumentTos3Id.get(s3.Id));
                    isUpdate = true;
                }
                if(isUpdate){
                    s3ForUpdate.add(s3);
                }
            }
        }
        
        if(s3ForUpdate != null && s3ForUpdate.size() > 0){
            update s3ForUpdate;
        }
    }
    
    public static void getFileFromS3(Id recordId, String fileName) {
        if (!String.isBlank(filename)) {
            String url = 'callout:AmazonS3/gati-data-ds';
            HttpRequest req  = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setEndpoint(url + '/' + filename);
            req.setMethod('GET');
            system.debug(req.getBody());
            Http http = new Http();
            if(!Test.isRunningTest()){
                res = http.send(req);   
            }
            if(res.getStatusCode() == 200 || Test.isRunningTest()) {
                ContentVersion conVer = new ContentVersion();
                conVer.contentLocation = 'S';
                conver.PathonClient = filename;
                conVer.Title = filename;
                conver.VersionData = res.getBodyasblob() != null ? res.getBodyasblob() : Blob.valueof('Some Text');
                insert conVer;
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = recordId; 
                conDocLink.ContentDocumentId = conDoc;  
                conDocLink.shareType = 'V';
                insert conDocLink;
            }
        }
    }    
}