public class TargetOwnerAssignTriggerHandler {
    public static void targetOwnerAssign(List<Sales_KRA__c> newList){
        Set<String> staffCoeds = new Set<String>();
        Map<String,Id> mapOfUser = new Map<String,Id>();
        for(Sales_KRA__c sk : newList){
            if(sk.Staff_Code__c!=null){
                staffCoeds.add(sk.Staff_Code__c);
            }
        }
        if(staffCoeds != null && staffCoeds.size() > 0){
            List<User> userList = [SELECT Id,Staff_Code__c FROM User WHERE Staff_Code__c IN:staffCoeds];
            if(!userList.isEmpty() && userList.size()>0){
                for(User usr : userList){
                    if(!mapOfUser.containsKey(usr.Staff_Code__c)){
                        mapOfUser.put(usr.Staff_Code__c,usr.Id);
                    }
                }
            }
        }
        for(Sales_KRA__c targetOwner : newList){
            if(mapOfUser.containsKey(targetOwner.Staff_Code__c)){
                targetOwner.KAM_KAE__c = mapOfUser.get(targetOwner.Staff_Code__c);
            	targetOwner.OwnerId = mapOfUser.get(targetOwner.Staff_Code__c);
            }
        }
    }    
}