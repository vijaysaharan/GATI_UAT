@isTest
public class CreateBigObjectControllerTest implements HttpCalloutMock{
	
     public HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals('callout:ApexMDAPI1/services/data/v22.0/query/?q=SELECT+id+from+contact', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"requid":"GS21002","product":"2""customerCode":,result":"successful","status":{"desc":"NA"}, "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
        res.setStatusCode(200);
        return res;
    }

    @isTest 
    public static void listOfSobjectTest(){
        Test.startTest();
        CreateBigObjectController.listOfSobject();
        Test.stopTest(); 
    }
    
    @isTest
    public static void getFieldsTest(){
        Test.startTest();
        CreateBigObjectController.getFields('Account');
        Test.stopTest();
    }
    
    @isTest
    public static void createBigObjectTest(){
        String s = '[{"labelName":"Account ID","apiName":"AccountId","sortDirection":"DESC","lengthOfField":0,"indexed":true,"bigApiName":"AccountID__c","bigLableName":"Account ID"},{"labelName":"Owner Expiration Notice","apiName":"OwnerExpirationNotice","sortDirection":"DESC","lengthOfField":0,"indexed":true,"bigApiName":"OwnerExpirationNotice__c","bigLableName":"Owner Expiration Notice"},{"labelName":"Billing Zip/Postal Code","apiName":"BillingPostalCode","sortDirection":"DESC","lengthOfField":0,"indexed":true,"bigApiName":"BillingZipPostalCode__c","bigLableName":"Billing Zip/Postal Code"},{"labelName":"Billing Longitude","apiName":"BillingLongitude","sortDirection":"DESC","lengthOfField":0,"indexed":true,"bigApiName":"BillingLongitude__c","bigLableName":"Billing Longitude"},{"labelName":"Shipping Street","apiName":"ShippingStreet","sortDirection":"DESC","lengthOfField":0,"indexed":true,"bigApiName":"ShippingStreet__c","bigLableName":"Shipping Street"},{"labelName":"Activated Date","apiName":"ActivatedDate","sortDirection":"DESC","lengthOfField":0,"indexed":false,"bigApiName":"ActivatedDate__c","bigLableName":"Activated Date"},{"labelName":"Description","apiName":"Description","sortDirection":"DESC","lengthOfField":0,"indexed":false,"bigApiName":"Description__c","bigLableName":"Description"},{"labelName":"Deleted","apiName":"IsDeleted","sortDirection":"DESC","lengthOfField":0,"indexed":false,"bigApiName":"Deleted__c","bigLableName":"Deleted"}]';
        Test.startTest();
        CreateBigObjectController.createBigObject('{"labelName":"Contract","developerName":"Contract"}',s,'Dummy');
        Test.stopTest();
    }
    
}