public with sharing class Disturbanceontroller {
    @AuraEnabled
	public static List<Disturbance__c> getC(Id recordId) {
        Case c =[Select Booking_OU__c,
                 CCEC_Action_OU__c,
                 Complaint_Actionable_OU__c,
                 Delivery_OU__c,
                 PickUp_OU__c,
                 Stock_OU__c
                From Case Where Id=:recordId];
        
   return [SELECT Name, Affected_OU__r.Name
                               FROM Disturbance__c Where To_Date__c>=Today and From_Date__c <= Today And
                               (Affected_OU__c=:c.Booking_OU__c OR 
                                Affected_OU__c=:c.CCEC_Action_OU__c OR 
                                Affected_OU__c=:c.Complaint_Actionable_OU__c OR 
                                Affected_OU__c=: c.Delivery_OU__c OR 
                                Affected_OU__c=:c.PickUp_OU__c OR 
                                Affected_OU__c=:c.Stock_OU__c)];
}
    
}