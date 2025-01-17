public with sharing class EinsteinAPIService {

    public static  STRING OAUTH_END_POINT = 'https://api.einstein.ai/v2/oauth2/token';
	EinsteinAPIService()
    {
        OAUTH_END_POINT=API_credential__mdt.getInstance('Einstein').Endpoint__c;
    }
    private static String getAccessToken() {
       
  
        string email=API_credential__mdt.getInstance('Einstein').User_Name__c;
        
        StaticResource base64Content=[SELECT Id, Body FROM StaticResource where name='einstein_platform' limit 1];
        String keyContents = base64Content.body.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');
        
        // Get a new token
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; 
        // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = email;
        jwt.aud =  OAUTH_END_POINT;
        jwt.exp = '3600';
        String accesstoken = JWTBearerFlow.getAccessToken(OAUTH_END_POINT, jwt);
        return accesstoken;    
    }
    public static String imageOCR(String endPoint, String sample, String model, boolean isBase64, boolean isCard){
        String result = einsteinAPICall(endPoint, sample, model, isBase64, isCard);
        return result;
    }
    public static String predictImage(String endPoint, String sample, String model, boolean isBase64, boolean isCard){
        String result = einsteinAPICall(endPoint, sample, model, isBase64, isCard);
        return result;
    }
    public static String einsteinAPICall(String endPoint, String sample, String model, boolean isBase64, boolean isCard) {
        string contentType = HttpFormBuilder.GetContentType();
        String accesstoken = getAccessToken();
        
        //  Compose the form
        string form64 = '';
		
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('modelId', EncodingUtil.urlEncode(model, 'UTF-8'));
        form64 += HttpFormBuilder.WriteBoundary();
        if(isCard){
            form64 += HttpFormBuilder.WriteBodyParameter('task', EncodingUtil.urlEncode('contact', 'UTF-8'));
            form64 += HttpFormBuilder.WriteBoundary();
        }
        if(isBase64) {
            form64 += HttpFormBuilder.WriteBodyParameter('sampleBase64Content', sample);
        } else {
            form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', sample);
        }
        
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        string access_token = 'Bearer ' + accesstoken;
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization',access_token);
        httpRequest.setEndpoint(endPoint);

        Http http = new Http();
        try {
            HTTPResponse res = http.send(httpRequest);
            System.debug(System.LoggingLevel.DEBUG, ' Response From Einstein Platform API '+res.getBody());
            if (res.getStatusCode() == 200) {
                return res.getBody();
            }
        } catch(System.CalloutException e) {
            System.debug('ERROR:' + e);
            return e.getStackTraceString();
        }
        return null;
    }
}