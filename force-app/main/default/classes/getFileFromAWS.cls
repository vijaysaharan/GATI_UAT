public class getFileFromAWS{
    public static void getFileFromS3(Id oid, String fileName) {
        if (!String.isBlank(filename)) {
            String url = 'callout:AmazonVerificationDocument/dev-mdmgati-stg/Customer-Dev-Identifier-S3-Bucket';
            HttpRequest req  = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setEndpoint(url + '/' + filename);
            req.setMethod('GET');
            system.debug(req.getBody());
            Http http = new Http();
            res = http.send(req);
            System.debug(res.getStatusCode());
            system.debug(res.getBody());
            if (res.getStatusCode() == 404) {
                res = http.send(req);
                if(res.getStatusCode() == 200) {
                    ContentVersion conVer = new ContentVersion();
                    conVer.contentLocation = 'S';
                    conver.PathonClient = filename;
                    conVer.Title = filename.substringAfter('/');
                    conver.VersionData = res.getBodyasblob();
                    insert conVer;
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = oid; 
                    conDocLink.ContentDocumentId = conDoc;  
                    conDocLink.shareType = 'V';
                    insert conDocLink;
                }
            }
            if(res.getStatusCode() == 200) {
                ContentVersion conVer = new ContentVersion();
                conVer.contentLocation = 'S';
                conver.PathonClient = filename;
                conVer.Title = filename.substringAfter('/');
                conver.VersionData = res.getBodyasblob();
                insert conVer;
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = oid; 
                conDocLink.ContentDocumentId = conDoc;  
                conDocLink.shareType = 'V';
                insert conDocLink;
            }
        }
    }
}