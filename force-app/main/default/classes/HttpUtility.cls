public class HttpUtility {
    public static HttpResponse sendRequest(String method,String endpoint,String body,Map<String,String> headerMap){
        HttpRequest request = new HttpRequest();
        if(!headerMap.isEmpty()){
            for(String eachHeaderParam :headerMap.keySet()){
                request.setHeader(eachHeaderParam,headerMap.get(eachHeaderParam));
            }
        }
        request.setMethod(method);
        request.setEndpoint(endpoint);
        request.setBody(body);
        Http http = new Http();
        System.debug('Request>>'+request);
        HttpResponse response = new HttpResponse();
        response = http.send(request); 
        System.debug('Response>>'+response);
        return response;
    }
    public static String  getGatiAuthToken(){
        Integration_Utilities__mdt integrationUtil = Integration_Utilities__mdt.getInstance(Constants.GATI_AUTHORIZATION_URL);
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Content-Type',integrationUtil.Content_Type__c);
        String endpointUrl = integrationUtil.EndpointURL__c+'?grant_type='+integrationUtil.Grant_Type__c+'&client_id='+integrationUtil.Client_Id__c+'&client_secret='+integrationUtil.Client_Secret__c;
        HttpResponse response = HttpUtility.sendRequest(integrationUtil.Method__c,endpointUrl,'' ,headerMap);
        System.debug('Auth Response:-'+response.getBody());
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        return (String)responseMap.get('access_token');
        
        
    }
    public class Authorization{
        public string ClientId;
        public string ClientKey;
    } 
    
    
}