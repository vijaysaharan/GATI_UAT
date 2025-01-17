trigger MISHistoryTrigger on MIS__c (after update) {
    List<MIS_History__c> Childs = new List<MIS_History__c>();

    for(MIS__c a : trigger.new)
    {
       if(a.Date_Time_of_Email_Sent__c != trigger.oldMap.get(a.Id).Date_Time_of_Email_Sent__c) {
       MIS__c oldRecord = Trigger.oldMap.get(a.Id);
       MIS_History__c Child = new MIS_History__c ();
       Child.MIS__c = oldRecord.id;
       Child.Emails__c = oldRecord.Email_Id_1__c+','+oldRecord.Email_Id2__c+','+oldRecord.Email_Id3__c+','+oldRecord.Email_Id4__c+','+oldRecord.Email_Id5__c+','+oldRecord.Email_Id6__c; 
	   Child.Date_Time_of_Email_Sent__c = oldRecord.Date_Time_of_Email_Sent__c;
       Childs.add(Child);    
        }
    }

    insert Childs;

}