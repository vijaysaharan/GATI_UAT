public class CaseCountForCustomerDashboard {
    public static String getAccessToken(String clientId, String clientSecret, String username, String password, String endPoint){
        Map<String, String> headers = new Map<String,String>();
        Map<String, Object> authResponse = new Map<String, Object>();
            headers.put('Content-Type','application/x-www-form-urlencoded');
            String authEndpoint = endPoint+'/services/oauth2/token?grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+username+'&password='+password;
            HttpRequest request = new HttpRequest();
        	HttpResponse response = new HttpResponse();
         	Http http = new Http();
            request.setMethod('POST');
        	System.debug('authEndpoint'+authEndpoint);
            request.setEndpoint(authEndpoint);
            response = http.send(request);
            String responseBody = response.getBody();
            authResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            return String.valueOf(authResponse.get('access_token'));
     }
    
    public static String makeGraphQL(Id AccountId, Date StartDate, Date EndDate, Boolean IsClosed){
        String sDate = String.valueOf(StartDate).subString(0,10);
        String eDate = String.valueOf(EndDate).subString(0,10);
        Map<String, Object> queryClose = new Map<String, Object>{
            'query' =>  'query getThisMonthClosed { uiapi{ query{ Case( where : { ClosedDate : {DAY_ONLY : {value : {lte : "'+eDate+'"}}} ClosedDate : {DAY_ONLY : {value : {gte : "'+sDate+'"}}} IsClosed : {eq : '+IsClosed+'} or : [ { AccountId : {eq : "'+AccountId+'"} }, { Account : {ParentId : {eq : "'+AccountId+'"}} } ] } ){ totalCount } } }}'
                };
        if(!IsClosed){
              queryClose.put('query','query getThisMonthClosed { uiapi{ query{ Case( where : { CreatedDate : {DAY_ONLY : {value : {lte : "'+eDate+'"}}} CreatedDate : {DAY_ONLY : {value : {gte : "'+sDate+'"}}} IsClosed : {eq : '+IsClosed+'} or : [ { AccountId : {eq : "'+AccountId+'"} }, { Account : {ParentId : {eq : "'+AccountId+'"}} } ] } ){ totalCount } } }}');           
        }
        System.debug('queryClose'+queryClose);
        return JSON.serialize(queryClose);
    }
    @InvocableMethod(label='Get Case Count From GraphQL')
    public static List<Integer> makeCallout(List<InputWrapper> inputVar){
        /*
        List<CustomerDashboardMetadata__mdt> dashboardAuth = [SELECT Id, DeveloperName, ClientId__c, ClientSecret__c, 
                                                              Username__c, Password__c, Endpoint__c
                                                              FROM CustomerDashboardMetadata__mdt
                                                              WHERE DeveloperName = 'Customer_Dashboard'
                                                             ];*/
        Integer closeCount = 0;
        if(inputVar != null && inputVar.size()>0){
            String access_token = inputVar[0].token;
            if(Test.isRunningTest()){
                List<CustomerDashboardMetadata__mdt> dashboardAuth = [SELECT Id, DeveloperName, ClientId__c, ClientSecret__c, 
                                                              Username__c, Password__c, Endpoint__c
                                                              FROM CustomerDashboardMetadata__mdt
                                                              WHERE DeveloperName = 'Customer_Dashboard'
                                                             ];
                String token = getAccessToken(dashboardAuth[0].ClientId__c,dashboardAuth[0].ClientSecret__c,dashboardAuth[0].Username__c,dashboardAuth[0].Password__c,dashboardAuth[0].Endpoint__c);
            }
            HTTP httpRange = new HTTP();
            HTTPRequest requestCloseCount = new HTTPRequest();
            requestCloseCount.setEndpoint(inputVar[0].Endpoint+'/services/data/v59.0/graphql');
            requestCloseCount.setMethod('POST'); 
            requestCloseCount.setHeader('Content-Type', 'application/json');
            requestCloseCount.setHeader('Authorization', 'Bearer '+access_token);
            requestCloseCount.setBody(makeGraphQL(inputVar[0].accountId,inputVar[0].startDate,inputVar[0].endDate,inputVar[0].isClosed));
            HTTPResponse responseCloseCount =httpRange.send(requestCloseCount);
            if(responseCloseCount.getStatusCode() == 200){
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseCloseCount.getBody());
                Map<String, Object> uiapi = (Map<String, Object>) jsonResponse.get('data');
                if(uiapi != null){
                    Map<String, Object> queries = (Map<String, Object>) uiapi.get('uiapi');
                    Map<String, Object> caseInfo = (Map<String, Object>) queries.get('query');
                    Map<String, Object> cases = (Map<String, Object>) caseInfo.get('Case');
                    closeCount = (Integer) cases.get('totalCount');
                    System.debug('closeCount => '+closeCount);
                }
            }
        }
        return new List<Integer>{closeCount};
    }
    
    public class InputWrapper{
        @InvocableVariable
        public Id accountId;
        @InvocableVariable
        public Date startDate;
        @InvocableVariable
        public Date endDate;
        @InvocableVariable
        public Boolean isClosed;
        @InvocableVariable
        public String token;
        @InvocableVariable
        public String Endpoint;
    }

}