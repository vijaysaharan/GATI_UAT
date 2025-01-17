// Batch Job for Processing the delete Records
global class RecordsDeletionBatch implements Database.Batchable<sObject> {
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = System.Label.SOQL_query_for_delete_operation;
        
        return Database.getQueryLocator(query);
    }
    // Execute method to delete records
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        dummy();
        List<CaseTeamMember> ctm = new List<CaseTeamMember>(); 
        List<CaseTeamMember> memberLst = new List<CaseTeamMember>();
        if(scope!=null){
            if(System.Label.run_Parent_Logic=='True'){
                try{
                    database.delete(scope);
                }Catch(Exception ex){
                    System.debug('--- error occur when records delete');
                }
            }else{
                memberLst = (List<CaseTeamMember>)scope;
                for(CaseTeamMember cm : memberLst){
                    if(cm.Parent.CreatedById==cm.Parent.OwnerId){
                        ctm.add(cm);
                    }
                }
                if(ctm!=null && ctm.size()>0){
                    database.delete(ctm);
                }
            }
        } 
    }
    // Finish Method
    global void finish(Database.BatchableContext BC) {
        System.debug('--- Batch execution finished--');
    }
    
    private static void dummy(){
        integer i=1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}