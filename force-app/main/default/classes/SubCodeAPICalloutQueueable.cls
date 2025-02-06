public with sharing class SubCodeAPICalloutQueueable implements Queueable, Database.AllowsCallouts {
    private Id newAccountId;

    public SubCodeAPICalloutQueueable(Id newAccountId) {
        this.newAccountId = newAccountId;
    }

    public void execute(QueueableContext context) {
        try {
            List<GatiMDMUtil.ActionOutput> apiResult = new List<GatiMDMUtil.ActionOutput>();
            Account newAccount = [SELECT Id, ParentId FROM Account WHERE Id = :newAccountId];

            String authorization = generateAuthorizationToken();
            
            GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
            input.action = 'Sub-Code-Creation';
            input.authorizationHeader = authorization;
            input.account = newAccount;

            apiResult = GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
            System.debug('API Response: ' + apiResult);
            IntegrationResponse__e iResponse = new IntegrationResponse__e();
            iResponse.StatusCode__c = apiResult[0].subCodeCreationStatusCode;
            EventBus.publish(iResponse);
            if(apiResult[0].subCodeCreationStatusCode != 200){
                delete newAccount;
            }
        }catch (Exception e) {
            System.debug('API Callout Error: ' + e.getMessage());
        }
    }

    private static String generateAuthorizationToken() {
        try {
            Map<String, String> payload = new Map<String, String>();
            payload.put('login', label.MDMAuthorizationUserName);
            payload.put('password', label.MDMAuthorizationPassword);
            
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint(MDMSetting__mdt.getInstance('Authorization_Token').EndPoint__c);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(payload));

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return responseMap.get('tokenType') + ' ' + responseMap.get('accessToken');
            }
        }catch (Exception e) {
            System.debug('Authorization Token Error: ' + e.getMessage());
        }
        return null;
    }
}