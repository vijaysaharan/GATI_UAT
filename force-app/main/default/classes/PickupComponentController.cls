public class PickupComponentController {
    @AuraEnabled
    public static Decimal getPickupDetails(String organizationId){
        System.debug('--- shipper pin code id--'+organizationId);
        Organization_Master__c org = [SELECT Id,Name,Location__c,Distance__c FROM Organization_Master__c WHERE Id=:organizationId limit 1];
        if(org!=null){
            return org.Distance__c;
        }else{return null;}
    }

}