trigger IntegrationLogTrigger on Integration_Log__c (before insert, before update) {
    List<Integration_Log__c> integrationLogs = Trigger.new;
    for(Integration_Log__c il : integrationLogs){
        String inbondjson='';
        String outboundjson='';
        If(!Test.isRunningTest() && il.Component_Name__c != 'All_Cargo_Lead_Integration' && il.Inbound_JSON__c != null && il.Inbound_JSON__c != ''){
         	inbondjson = il.Inbound_JSON__c.replace('/','');
            il.Json_For_Gems__c = inbondjson.replace('\'','');   
        }
        if(!Test.isRunningTest() && il.Component_Name__c != 'All_Cargo_Lead_Integration' && il.Outbound_JSON__c != null && il.Outbound_JSON__c != ''){
         	outboundjson = il.Outbound_JSON__c.replace('/','');
            il.Outbound_Json_for_Gems__c = outboundjson.replace('\'','');   
        }
    }
}