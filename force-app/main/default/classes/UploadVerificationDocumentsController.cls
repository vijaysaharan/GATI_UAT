public with sharing class UploadVerificationDocumentsController {
    @AuraEnabled
    public static Boolean updateOpportunityDetails(String fileData, String fileName, String opportunityId, String documentNumber, String fileType){
        try {
            Boolean isSuccess = false;
            List<Opportunity> opportunityDetails = [SELECT Id,AccountId, PAN_Card_Document__c, PanNumber__c, GSTIN_Documents__c, GSTNumber__c FROM Opportunity WHERE Id = :opportunityId];
            if(opportunityDetails != null && opportunityDetails.size() > 0){
                String formattedFileName = opportunityDetails[0].AccountId+'-'+fileName;
                Boolean isSent = sendFileToAWS(fileData,formattedFileName);
                if(isSent && fileType == 'PAN'){
                    opportunityDetails[0].PAN_Card_Document__c = true;
                    opportunityDetails[0].PanNumber__c = documentNumber;
                    isSuccess = true;
                }
                else if(isSent && fileType == 'GSTIN'){
                    opportunityDetails[0].GSTIN_Documents__c = true;
                    opportunityDetails[0].GSTNumber__c = documentNumber;
                    isSuccess = true;
                }

                if(isSuccess){
                    update opportunityDetails;
                }
            }
            return isSuccess;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean sendFileToAWS(String fileData, String fileName){
        try {
            Boolean isSuccess = false;
            String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
            string contentType= 'application/zip';
            String url = 'callout:AmazonVerificationDocument';
            HttpRequest req  = new HttpRequest();
            HttpResponse res  = new HttpResponse();
            req.setMethod('PUT');
            //req.setEndpoint(url + '/dev-mdmgati-stg/Customer-Dev-Identifier-S3-Bucket/' +filename);
            req.setEndpoint(url + '/prod-mdmgati-stg/Customer-Prod-Identifier-S3-Bucket/' +filename);
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', contentType);
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Date', formattedDateString);
            req.setHeader('ACL', 'public-read');
            Blob pdfBlob = EncodingUtil.base64Decode(fileData);
            req.setBodyAsBlob(pdfBlob);
            Http http = new Http();
            if(!Test.isRunningTest()){
                System.debug('Request '+req);
                //sendZipFile(fileData, fileName);
                res = http.send(req);
                isSuccess = true;
            }
            if(res.getStatusCode() == 200 || Test.isRunningTest()){
                isSuccess = true;
            }
            return isSuccess;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}