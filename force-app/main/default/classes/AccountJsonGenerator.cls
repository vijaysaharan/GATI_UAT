public class AccountJsonGenerator {
    /*public static void generateJSONFormatDataWithArray(List<Account> account){
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();     
        jsGen.writeFieldName('Account');
        jsGen.writeStartArray();
        
        for(Account acct : [SELECT Id, Name, OwnerId, Controlling_OU__c, Associated_OU__c From Account WHERE Id IN:account AND Name != '' AND OwnerId!=null AND Controlling_OU__c !=null AND Associated_OU__c !=null]){
            jsGen.writeStartObject();
            jsGen.writeStringField('Name', acct.Name);
            jsGen.writeStringField('Owner', acct.OwnerId);
            jsGen.writeStringField('OU', acct.Controlling_OU__c);
            jsGen.writeStringField('OU Code', acct.Associated_OU__c);
            jsGen.writeEndObject();
        }
        jsGen.writeEndArray();
        jsGen.writeEndObject();
        String jsonData = jsGen.getAsString();
        
        System.debug('json format Data==> ' + jsonData);
    }*/
    
    public static void generateJSONFormatDataWithoutArray(List<Account> account){
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();  
        
        for(Account acct : [SELECT Id, Name, OwnerId, Controlling_OU__c, Associated_OU__c From Account WHERE Id IN:account AND Name != '' AND OwnerId!=null AND Controlling_OU__c !=null AND Associated_OU__c !=null]){
            jsGen.writeStartObject();
            jsGen.writeStringField('Name', acct.Name);
            jsGen.writeStringField('Owner', acct.OwnerId);
            jsGen.writeStringField('OU', acct.Controlling_OU__c);
            jsGen.writeStringField('OU Code', acct.Associated_OU__c);
            jsGen.writeEndObject();
        }
        
        jsGen.writeEndObject();
        String jsonData = jsGen.getAsString();
        
        System.debug('json format Data==> ' + jsonData);
    }
}