trigger CreateEvent_Trigger on Customer_Connect__c (after insert, after update, after delete) {
    List<Customer_Connect__c> newList = Trigger.new;
    List<Customer_Connect__c> oldList = Trigger.old;
    Map<Id,Customer_Connect__c> newMap = Trigger.newMap;
    Map<Id,Customer_Connect__c> oldMap = Trigger.oldMap;
    
    
    if(Trigger.isAfter && Trigger.isInsert){
       CreateEventHandler.insertEventHelper(newList);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        CreateEventHandler.updateHelper(newList,oldMap);
        List<Customer_Connect__c> ccList = new List<Customer_Connect__c>();
        for(Customer_Connect__c cc : Trigger.New){
            if(Trigger.oldMap.get(cc.Id).Check_In_Time__c != cc.Check_In_Time__c && cc.Customer_Code__c != null){
                ccList.add(cc);
            }
        }
        if(ccList != null && ccList.size()>0){
            CreateEventHandler.updateCustomer360(ccList);
        }
    }
    
    if(Trigger.isAfter && Trigger.isDelete){
        CreateEventHandler.deleteEventHelper(oldList);
    }
    
}