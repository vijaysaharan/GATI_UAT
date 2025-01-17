public class GATILeadCalloutService implements Queueable, Database.AllowsCallouts {
    public static String operation = '';
    public static Integer index = 0;
    public List<String> leadList = new List<String>();
    public String method = 'PATCH';
    
    public GATILeadCalloutService(String method, List<String> leadList) {
        this.method = method;
        this.leadList = leadList;
    }
    
    public void execute(QueueableContext context){
        if(leadList.size() > index ){
            requestBinding(leadList[index],method);
            index++;
        }
        if(index < leadList.size()){
            //index is less than leadList size
            System.enqueueJob(this);
        }
    }
    
    public static void requestBinding(String leadRecordId,String method){
        try{
            operation = method;
            Integration_Utilities__mdt integrationUtil = Integration_Utilities__mdt.getInstance(Constants.LEAD_PUSH);
            Map<String,Integration_Mapping_Table__mdt> cfsmagSfdcMap = UtilityLead.getIntegrationMappingFields(Constants.LEAD_PUSH);
            String filterCondition = ' WHERE Id = \''+leadRecordId+'\'';
            if(!cfsmagSfdcMap.isEmpty()){
                Set<String> fieldSet = new Set<String>();
                String url = '';
                if(operation == Constants.PATCH){
                    fieldSet.add(Constants.External_ID);
                }
                System.debug('cfsmagSfdcMap.size()>>'+cfsmagSfdcMap.size());
                for(Integration_Mapping_Table__mdt eachIntegrationRecord : cfsmagSfdcMap.values()){
                    if(eachIntegrationRecord.SFDC_Object_Api_Name__c == 'Lead'){
                        fieldSet.add(eachIntegrationRecord.SFDC_Field_Api_Name__c);
                    }
                }
                Lead leadRecord = (Lead)UtilityLead.getSobjectRecords('Lead',fieldSet,filterCondition)[0]; 
                System.debug('leadRecord>>'+leadRecord);
                if(operation == Constants.POST){
                    url = '/services/data/v58.0/sobjects/Lead/';
                }
                else if(operation == Constants.PATCH){
                    url = '/services/data/v58.0/sobjects/Lead/'+leadRecord.ExternalID__c; 
                }
                
                String jsonStructure ='{"compositeRequest":[{"method":"'+operation+'","url":"'+url+'","referenceId":"refLead1","body":'+UtilityLead.prepareJSONStructure(Constants.LEAD_PUSH,cfsmagSfdcMap,leadRecord)+'}]}' ;
                System.debug('jsonStructureREQUESTJSON>>'+jsonStructure);
                Map<String,String> headerMap = new Map<String,String>();
                headerMap.put('Authorization','Bearer '+HttpUtility.getGatiAuthToken());
                headerMap.put('Content-Type',integrationUtil.Content_Type__c);
                HttpResponse response = HttpUtility.sendRequest(Constants.POST,integrationUtil.EndpointURL__c ,jsonStructure,headerMap);
                System.debug('responseFROMALLCARGO>>'+response.getBody()); 
                Integration_Log__c integrationLog = New Integration_Log__c();
                integrationLog.eObject__c = 'Lead';
                integrationLog.Component_Name__c = 'All_Cargo_Lead_Integration';
                integrationLog.eRecordID__c  = leadRecordId;
                integrationLog.Inbound_JSON__c = jsonStructure;
                integrationLog.IsIntegration__c = true; 
                Lead leadInstance = new Lead();                    
                leadInstance.Id = leadRecordId;
                if(operation == Constants.POST || operation == Constants.PATCh){
                    Map<String,Object> deserializeUntypedMap= (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    List<Object> compositeResponseList = (List<Object>)deserializeUntypedMap.get('compositeResponse');
                    Map<String,Object> responseMap= (Map<String,Object>)compositeResponseList[0];
                    Integer httpStatusCode = Integer.valueOf(responseMap.get('httpStatusCode'));
                    Map<String,Object> bodyMap = new Map<String,Object>();
                    if(httpStatusCode == 200 ||httpStatusCode ==201 || httpStatusCode ==204)
                    {
                        bodyMap = (Map<String,Object>)responseMap.get('body');
                        if(operation == Constants.POST){
                            System.debug('Id>>'+bodyMap.get('id'));
                            leadInstance.ExternalID__c = (String)bodyMap.get('id');   
                        }
                        integrationLog.Error_Message__c = null;
                        leadInstance.Lead_Creation_Status__c = Constants.SUCCESS; 
                    }
                    else{
                        List<Object> errorList = (List<Object>)responseMap.get('body');
                        String errorMessage = '';
                        String status = '';
                        if(errorList!=null && errorList.size()>0)
                        {
                            for(Object eachError : errorList){
                                Map<String,Object> errorMap = (Map<String,Object>)eachError;
                                errorMessage += (String)errorMap.get('message')+';';
                                status += (String)errorMap.get('errorCode'); 
                            }
                            integrationLog.Error_Message__c = errorMessage.removeEnd(';');
                            leadInstance.Lead_Creation_Status__c = Constants.ERROR; 
                        }
                    }
                }
                UPDATE leadInstance; 
                INSERT integrationLog;
            }
        }
        catch(Exception ex){
            System.debug('Exception Occured>>'+ex);
        }
    }
    public static void exceptionTagMapping(Map<String, Object> dataToSerialize,String tagName,String fieldAPIName,sObject sObjectRecord){
        if(tagName == Constants.LEAD_STATUS){
            dataToSerialize.put(Constants.LEAD_STATUS,setStatusMapping(String.valueOf(sObjectRecord.get(fieldAPIName))));              
        }
        else if(tagName == Constants.EXTERNAL_ID && operation == Constants.PATCH){
            dataToSerialize.put('Id',sObjectRecord.get('ExternalID__c')); 
        }
        
    }
    public static String setStatusMapping(String status){
        if(!String.isBlank(status)){
            if(Constants.LEAD_WORKING_STATUS.contains(status)){
                return Constants.WORKING;
            }
            else {
                return Constants.STATUS_MAP.get(status); 
            }
            
        }
        return null;        
    }
    
}
// Company Code Company Product