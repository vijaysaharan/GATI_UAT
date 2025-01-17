public without sharing class RoleHierarchyUtility {
    @AuraEnabled
    public static List<User> getRoleSubordinateUsers(Id userId, List<String> zoneList, Boolean isSalesDashBoard, Boolean isSalesDashboardUser) {
        List<User> users = new List<User>();
        Id roleId = [SELECT UserRoleId FROM User WHERE Id = :userId].UserRoleId;
        Set<Id> allSubRoleIds = getAllSubRoleIds(New Set<ID>{roleId});
        if(isSalesDashBoard){
            Set<String> userIds = new Set<String>();
            Date sDate = System.today().month() >= 4 ? Date.newInstance(System.today().year(), 4, 1) : Date.newInstance(System.today().year() - 1, 4, 1);
            Date eDate = System.today().month() >= 4 ? Date.newInstance(System.today().year() + 1, 3, 31) : Date.newInstance(System.today().year(), 3, 31);
            
            List<SalesDashboardUser__c> salesUser = [SELECT UserList__c 
                                                     FROM SalesDashboardUser__c 
                                                     WHERE StartDate__c >=: sDate 
                                                     AND EndDate__c <=: eDate
                                                     LIMIT 1
                                                    ];

            if(salesUser != null && salesUser.size() > 0){
                for(String us : salesUser[0].UserList__c.split(',')){
                    userIds.add(us);   
                }
            }

            if(userIds != null && userIds.size()>0 && isSalesDashboardUser){
                users = [SELECT Id, Name, Zone__c , IsActive
                         FROM User 
                         WHERE (Id IN: userIds AND UserRoleId IN: allSubRoleIds) OR Id =: userId                     
                        ];
            }
            else if(userIds != null && userIds.size()>0 && !isSalesDashboardUser){
                users = [SELECT Id, Name, Zone__c , IsActive
                         FROM User 
                         WHERE (Id IN: userIds AND UserRoleId IN: allSubRoleIds) OR Id =: userId
                        ];
            }                            
        }
        else{
            users = [SELECT Id, Name, Zone__c 
                     FROM User 
                     WHERE (UserRoleId IN: allSubRoleIds OR Id =: userId) 
                     AND Zone__c IN: zoneList 
                     AND IsActive = true 
                     ORDER BY Name
                    ];
        }
        return users;
    }
    
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        for(UserRole userRole : [SELECT Id FROM UserRole WHERE ParentRoleId IN: roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }       
        return currentRoleIds;   
    }
    
    @AuraEnabled
    public static List<Note> getNotesDetails(List<Id> contractId){
        List<Note> notesList = new List<Note>();
        if(contractId != null && contractId.size()>0){
            notesList = [SELECT Id, ParentId, Body, Title FROM Note WHERE ParentId IN: contractId WITH SECURITY_ENFORCED];
        }
        return notesList;
    }
    
    @AuraEnabled
    public static Boolean upsertNotes(List<Note> notesData){
        try{
            if(Note.sObjectType.getDescribe().isUpdateable() && Note.sObjectType.getDescribe().isCreateable()){
                upsert notesData;
                return true;
            }
            return false;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}