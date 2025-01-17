public class AutoCloseExceptionBtach implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query='';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}