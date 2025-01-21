public class DeleteServiceAllocationJob implements Queueable, Database.AllowsCallouts {
    private Map<String, String> customerCodeToStaffCode;
    private Map<String, String> customerCodeToCompanyCode;
    
    public DeleteServiceAllocationJob(Map<String, String> customerCodeToStaffCode, Map<String, String> customerCodeToCompanyCode) {
        this.customerCodeToStaffCode = customerCodeToStaffCode;
        this.customerCodeToCompanyCode = customerCodeToCompanyCode;
    }
    
    public void execute(QueueableContext context) {
        String authorizationToken = generateAuthorizationToken();
        for (String cusCode : customerCodeToStaffCode.keySet()) {
            GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
            input.customerCode = cusCode;
            input.staffCode = customerCodeToStaffCode.get(cusCode);
            input.companyCode = customerCodeToCompanyCode.get(cusCode);
            input.action = 'Delete-CS-Mapping';
            input.authorizationHeader = authorizationToken;
            GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
        }
    }

    private static String generateAuthorizationToken(){
        Map<String, String> payload = new Map<String, String>();
        payload.put('login', label.MDMAuthorizationUserName);
        payload.put('password', label.MDMAuthorizationPassword);
        HttpRequest request = new Httprequest();
        request.setMethod('POST');
        request.setEndpoint(MDMSetting__mdt.getInstance('Authorization_Token').EndPoint__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(payload));        
        Http http = new Http();
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String tokenType = (String) responseMap.get('tokenType');
            String accessToken = (String) responseMap.get('accessToken');
            return (tokenType + ' ' + accessToken);
        }
        return null;
    }
}
