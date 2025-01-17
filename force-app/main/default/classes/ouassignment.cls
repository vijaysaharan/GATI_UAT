public with sharing class ouassignment {
    @AuraEnabled(cacheable=true)
    public static list<Organization_Master__c> getorgmaster(string searchKey) {
        string searchKeyword = '%' + searchKey + '%';
		
       // create contact list to store search result 
        List<Organization_Master__c> orgmasterlst = new List<Organization_Master__c>();
        List<Organization_Master__c> orgmasterlstrecords = new List<Organization_Master__c>();
        orgmasterlst= [Select id,Name
        From Organization_Master__c
        WHERE name LIKE : searchKeyword];
	   // query contact records
        for(Organization_Master__c org : orgmasterlst){
            orgmasterlstrecords.add(org);
            System.debug('orgmasterlstrecords----' + orgmasterlstrecords);
        }
        
         if(orgmasterlstrecords.size() == 0){
            throw new AuraHandledException('No Record Found..'); 
         }
         
        return orgmasterlstrecords;
    }

    
}