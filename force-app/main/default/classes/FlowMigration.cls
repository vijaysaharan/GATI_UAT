public class FlowMigration {
    
    /*public static boolean updateTaskandApprovalCheck = true;

//updateTaskandApproval(Flow)
public static void updateTaskandApproval(List<case> newMap){
list<case> listToUpdate = new List<Case>();
for(Case c : newMap){
if(c.OwnerId != System.UserInfo.getUserId() && c.Status != 'Closed' && (c.Type == 'ADD Extension' || c.Type == 'Bill back of Expenses' || c.Type == 'Appointment Delivery' ) ){
Case ca = new Case(Id = c.Id);
ca.Case_Owner__c = c.OwnerId;
listToUpdate.add(ca); 
}
}
if(!listToUpdate.isEmpty() && listToUpdate.size()>0){
update listToUpdate;
}
}*/
    /*
//autoPopulatingContactInAccount(Process Builder)
public static void autoPopulatingContactInAccount(Map<Id,Case> oldMap, Map<Id,Case> newMap) {
// fetching contacts
Set<Id> contactIdSet = new Set<Id>();
for (Case c : newMap.values()) {
if(c.ContactId != null){
contactIdSet.add(c.ContactId);
}
}

Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id , MailingStreet from Contact where id in :contactIdSet]);

// insert case
if(oldMap == null){
Set<Id> accountIdSet = new Set<Id>();
for (Case c : newMap.values()) {
if(c.AccountId != null && c.Pickup_Address1__c == null && c.Type == 'Pick Up' && contactMap.containsKey(c.ContactId) && contactMap.get(c.ContactId).MailingStreet == null){
accountIdSet.add(c.AccountId);
}
}

if(!accountIdSet.isEmpty()){
Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, BillingStreet, BillingCity from Account where id in :accountIdSet]);
for (Case c : newMap.values()) {
if(c.AccountId != null && accountMap.containsKey(c.AccountId)){
c.Pickup_Address1__c = accountMap.get(c.AccountId).BillingStreet;
c.Pickup_City__c = accountMap.get(c.AccountId).BillingCity;
}
}
}
}
// update case
else{
Set<Id> accountIdSet = new Set<Id>();
for (Case c : newMap.values()) {
if(c.AccountId != null && (c.AccountId != oldMap.get(c.Id).AccountId || c.Pickup_Address1__c == null) && c.Type == 'Pick Up' && contactMap.containsKey(c.ContactId) && contactMap.get(c.ContactId).MailingStreet == null){
accountIdSet.add(c.AccountId);
}
}

if(!accountIdSet.isEmpty()){
Map<Id, Account> accountMap = new Map<Id, Account>([Select Id, BillingStreet, BillingCity from Account where id in :accountIdSet]);
for (Case c : newMap.values()) {
if(c.AccountId != null && accountMap.containsKey(c.AccountId)){
c.Pickup_Address1__c = accountMap.get(c.AccountId).BillingStreet;
c.Pickup_City__c = accountMap.get(c.AccountId).BillingCity;
}
}
}
}
}*/
    
    //ccec creation for complaint/query(Flow)
    public static void ccecCreation(Map<Id, Case> newMap) {
        Map<Id, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById();
        Map<Id, Case> complaintCases = new Map<Id, Case>();
        /*Map<Id, Case> queryCases = new Map<Id, Case>(); 
List<CCEC__c> ccecList = new List<CCEC__c>();

for (Case c : newMap.values()) {
if (rt_map.get(c.recordTypeID).getName().containsIgnoreCase('Complaint')) {
complaintCases.put(c.Id, c);
}

if (rt_map.get(c.recordTypeID).getName().containsIgnoreCase('Query')) {
queryCases.put(c.Id, c);
}
}*/
        
        // Call Send_Complaint_CCEC_RecordsQueueable class
        List<String> caseIds = new List<String>();
        for (Case c : complaintCases.values()) {
            caseIds.add(c.Id);
        }
        
        Send_Complaint_CCEC_RecordsQueueable idQueue = new Send_Complaint_CCEC_RecordsQueueable(caseIds);
        // Enqueue the queueable job
        System.enqueueJob(idQueue);
        
        /*for (Case c : complaintCases.values()) {
if (c.Type == 'Pending Pickup' || c.Type == 'Delayed Connection' || c.Type == 'Partial Delivery' || c.Type == 'Claims' || c.Type == 'Undelivered') {
CCEC__c ccec = new CCEC__c();
ccec.Auto_CCEC_Creation__c = true;
ccec.Auto_CCEC_Flag__c = true;
ccec.Instruction__c = 'fillinstruction';
ccec.CCEC_OF__c = 'CCECOF';
ccec.CCEC_OU_Assignment_Logic__c = c.CCEC_Action_OU__c;
ccec.Case__c = c.Id;
ccec.Status__c = 'OP';
ccecList.add(ccec);
}
else if (c.Type == 'Invoicing and Others') {
CCEC__c ccec = new CCEC__c();
ccec.Auto_CCEC_Creation__c = true;
ccec.Auto_CCEC_Flag__c = true;
ccec.Instruction__c = 'fillinstructions2';
ccec.CCEC_OF__c = 'CCECOF';
ccec.CCEC_OU_Assignment_Logic__c = c.CCEC_Action_OU__c;
ccec.Case__c = c.Id;
ccec.Status__c = 'OP';
ccecList.add(ccec);
}
}
for (Case c : queryCases.values()) {
if (c.Type == 'DELIVERY REQUESTED BEFORE ADD' || c.Type == 'REBOOKING WITHOUT INFORMATION' || c.Type == 'VARIANCE IN ADD') {
CCEC__c ccec = new CCEC__c();
ccec.Auto_CCEC_Creation__c = true;
ccec.Auto_CCEC_Flag__c = true;
ccec.Instruction__c = 'fillinstructions3';
ccec.CCEC_OF__c = 'CCECOF';
ccec.CCEC_OU_Assignment_Logic__c = c.CCEC_Action_OU__c;
ccec.Case__c = c.Id;
ccec.Status__c = 'OP';
ccecList.add(ccec);
}
}

if (!ccecList.isEmpty()) {
insert ccecList;
}*/
    }
    
}