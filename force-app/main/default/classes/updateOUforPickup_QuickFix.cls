global class updateOUforPickup_QuickFix implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String query = 'SELECT Status,createddate,Id,PickUp_OU__c, Pick_Up_Pincode__r.Parent__c FROM Case WHERE PickUp_OU__c = null AND Type = \'Pick Up\' AND Pick_Up_Pincode__c != null AND Status !=\'Closed\'';
        return Database.getQueryLocator(query);		
    }
    global void execute(Database.BatchableContext bc, List<Case> caselist){
        // process each batch of records
		for(Case cd: caselist)
		{
			cd.PickUp_OU__c = cd.Pick_Up_Pincode__r.Parent__c;
		}
        try {
            // Update the Account Record
            update caselist;
         
        } catch(Exception e) {
            System.debug(e);
        }		
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}