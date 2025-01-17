public with sharing class visitViewerController {
    public class LocationWrapper{
        @AuraEnabled public string icon{get;set;}
        @AuraEnabled public string value{get;set;}
        @AuraEnabled public string title{get;set;}
        @AuraEnabled public string description{get;set;}
        @AuraEnabled public locationDetailWrapper location{get;set;} 
    }
    public class locationDetailWrapper{
        @AuraEnabled public string Latitude{get;set;}
        @AuraEnabled public string Longitude{get;set;}
        @AuraEnabled public string City{get;set;}
        @AuraEnabled public string Country{get;set;}
        @AuraEnabled public string PostalCode{get;set;}
        @AuraEnabled public string State{get;set;}
        @AuraEnabled public string Street{get;set;}
    }
    
    public class userListWrapper{
        @AuraEnabled public string userName{get;set;}
        @AuraEnabled public Id userId{get;set;}
    }

    @AuraEnabled
    public static List<LocationWrapper> getLocations(String whereClause,String userList) {
        String query = 'SELECT Id,Name,Check_In_Address__c,Visit_Date__c,Owner.Name,Customer_Code__r.Customer_Category__c, Check_In_Location__Latitude__s, Check_In_Location__Longitude__s, Check_In_Time__c FROM Customer_Connect__c';

        if(whereClause != ''){
            query = query + whereClause;
        }
        List<String> userIds = new List<String>();
        if(userList != ''){
            userIds = userList.split(';');
            query = query + ' And OwnerId IN : userIds';
        }
        
        System.debug(query);

        List<LocationWrapper> locationList = new List<LocationWrapper>();
        
        List<Customer_Connect__c> customerConnectList = new List<Customer_Connect__c>();
        customerConnectList = Database.query(query);

        for(Customer_Connect__c connect : customerConnectList){
            LocationWrapper centerL1 = new LocationWrapper();
            locationDetailWrapper cL1 = new locationDetailWrapper();
            centerL1.icon = 'utility:checkin';
            centerL1.value = connect.Id;
            centerL1.title = connect.Name + ': '+ connect.Owner.Name ;
            centerL1.description = connect.Check_In_Address__c;
            cL1.Latitude = String.valueOf(connect.Check_In_Location__Latitude__s);
            cL1.Longitude = String.valueOf(connect.Check_In_Location__Longitude__s);
            String geoCheckInAddress1 = '';
            if(connect.Check_In_Address__c != null){
                geoCheckInAddress1 = connect.Check_In_Address__c;
            }
            else{
                geoCheckInAddress1 = GoogleApiApex.parseJSONResponse(connect.Check_In_Location__Latitude__s,connect.Check_In_Location__Longitude__s);
            }
            List<String> locationStrings = geoCheckInAddress1.split(',');
            Integer sizeOflocationStrings = locationStrings.size();
            if(sizeOflocationStrings > 2){
                cL1.Street = locationStrings[2];
            }
            if(sizeOflocationStrings > 3){
                cL1.City = locationStrings[3];
            }
            cL1.Country = locationStrings[sizeOflocationStrings-1];
            if(sizeOflocationStrings >= 2){
                cL1.PostalCode = locationStrings[sizeOflocationStrings-2].substringAfterLast(' ');
                cL1.State = locationStrings[sizeOflocationStrings-2].substringBeforeLast(' ');
            }
            centerL1.location = cL1;
            locationList.add(centerL1);
        }
        System.debug(locationList);
        return locationList;
    }
    @AuraEnabled
    public static List<userListWrapper> getRoleSubordinateUsers() {
        List<userListWrapper> userReturnList = new List<userListWrapper>();
        Id userId = UserInfo.getUserId();
        Id roleId = [SELECT UserRoleId From User Where Id = :userId].UserRoleId;
        Set<Id> allSubRoleIds = getAllSubRoleIds(New Set<ID>{roleId});
        Map<Id, User> users = new Map<Id, User>([SELECT Id, Name From User Where UserRoleId IN :allSubRoleIds]);
        for(User u : users.values()){
            userListWrapper uData = new userListWrapper();
            uData.userName = u.Name;
            uData.userId = u.Id;
            userReturnList.add(uData);
        }
        return userReturnList;
    }
    
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        for(UserRole userRole :[SELECT Id from UserRole Where ParentRoleId IN :roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }        
        return currentRoleIds;   
    }
    
     @AuraEnabled
    public static List<String> getPicklistOptions(String objectName, String fieldName) {
        List<String> options = new List<String>();
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        
        Schema.DescribeFieldResult fieldDescribe = describeResult.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
        
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            options.add(picklistEntry.getValue());
        }
        
        return options;
    }
}