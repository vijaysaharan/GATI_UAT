public with sharing class BeatPlaningDashboard {
    // @AuraEnabled
    // public static Map<String,Map<String,Object>> getAccountData(){
    //     try {
    //         Date contractConsiderationDate = System.today() - Integer.valueOf(System.Label.BP_Contract_Consideration);
    //         String contractRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
    //         List<Account> contractsAccountsToprocess = [SELECT id,Name,Monthly_Spend_on_Logistic__c,OwnerId,ParentId,Owner.Name,
    //                                             CreatedDate,Customer_Category__c,Zone_Name__c,
    //                                             (SELECT id,Visit_Status__c,Visit_Start_Date__c 
    //                                             FROM Customer_Connect__r
    //                                             ORDER BY CreatedDate DESC 
    //                                             LIMIT 1) 
    //                                             FROM Account 
    //                                             WHERE (OwnerId IN : getRoleSubordinateUsers(System.UserInfo.getUserId()) 
    //                                             OR OwnerId = : System.UserInfo.getUserId())
    //                                             AND Contract_end_date__c >= :contractConsiderationDate
    //                                             AND RecordTypeId = :contractRecordTypeId
    //         ];

    //         Map<String,Map<String,Object>> accountsToReturn = new Map<String,Map<String,Object>>();

    //         Set<String> contractAccountOwners = new Set<String>();
    //         Set<Id> rejectedAccountIds = new Set<Id>();

    //         if ( contractsAccountsToprocess != null && contractsAccountsToprocess.size() > 0 ) {
    //             for (Account accountToProcess : contractsAccountsToprocess) {
    //                 String key = String.valueOf(accountToProcess.OwnerId) + String.valueOf(accountToProcess.Id);
    //                 contractAccountOwners.add(key);
    //                 Map<String,Object> objectToAdd = getObjectToReturn(accountToProcess);
    //                 if(objectToAdd != null)
    //                     accountsToReturn.put(accountToProcess.Id,objectToAdd);
    //             }

    //             String retailRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail').getRecordTypeId();
    //             String customerCodeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Code').getRecordTypeId();
    //             List<Account> childAccountsToprocess = [SELECT id,Name,Monthly_Spend_on_Logistic__c,ParentId,OwnerId,Owner.Name,
    //                                             CreatedDate,Customer_Category__c,Zone_Name__c,
    //                                             (SELECT id,Visit_Status__c,Visit_Start_Date__c 
    //                                             FROM Customer_Connect__r
    //                                             ORDER BY CreatedDate DESC 
    //                                             LIMIT 1) 
    //                                             FROM Account 
    //                                             WHERE ParentId IN: contractsAccountsToprocess 
    //                                             AND ( recordTypeId = :retailRecordTypeId 
    //                                             OR recordTypeId =:customerCodeRecordTypeId )
    //             ];

    //             if (childAccountsToprocess!= null && childAccountsToprocess.size() > 0) {
    //                 for (Account accountToProcess : childAccountsToprocess) {
    //                     String key = String.valueOf(accountToProcess.OwnerId) + String.valueOf(accountToProcess.ParentId);
    //                     if ( !contractAccountOwners.contains( key ) ) {
    //                         Map<String,Object> objectToAdd = getObjectToReturn(accountToProcess);
    //                         if(objectToAdd != null)
    //                             accountsToReturn.put(accountToProcess.Id,objectToAdd);
    //                     } else {
    //                         rejectedAccountIds.add(accountToProcess.Id);
    //                     }
    //                 }
    //             }
    //         }

    //         if(!accountsToReturn.isEmpty()){
    //             List<Account> visitedCustomerConnect = [SELECT ID ,(SELECT Id, Customer_Code__c, Visit_Date__c, Owner.Name, Customer_Code__r.ParentId
    //                                                                 FROM Customer_Connect__r ORDER BY Visit_Date__c ASC LIMIT 1)
    //                                                                 FROM Account
    //                                                                 WHERE Id IN :accountsToReturn.keyset()
    //                                                                 OR Id IN :rejectedAccountIds
                                                                    
    //             ];

    //             Map<String,Customer_Connect__c> accountToLastVisitDate = new Map<String,Customer_Connect__c>();
    //             if (visitedCustomerConnect != null && visitedCustomerConnect.size() > 0) {
    //                 for (Account customerConnectToProcess : visitedCustomerConnect) {
    //                     if (customerConnectToProcess.Customer_Connect__r != null && customerConnectToProcess.Customer_Connect__r.size() > 0) {
    //                         if ( !rejectedAccountIds.contains(customerConnectToProcess.Customer_Connect__r[0].Customer_Code__c) ) {
    //                             accountToLastVisitDate.put(customerConnectToProcess.Customer_Connect__r[0].Customer_Code__c, customerConnectToProcess.Customer_Connect__r[0]);
    //                         } else {
    //                             accountToLastVisitDate.put(customerConnectToProcess.Customer_Connect__r[0].Customer_Code__r.ParentId, customerConnectToProcess.Customer_Connect__r[0]);
    //                         }
    //                     }
    //                 }
    //             }

    //             List<Account> surfaceCustomer360 = [SELECT ID,(SELECT LM_TD__c,MTD__c,Customer_Code__c,Customer_Code__r.ParentId
    //                                                         FROM Customer360__r 
    //                                                         WHERE Product__c = 'SUR EXPRESS'
    //                                                         ORDER BY CreatedDate ASC LIMIT 1)
    //                                                         FROM Account
    //                                                         WHERE (ID IN :accountsToReturn.keyset()
    //                                                         OR ID IN :rejectedAccountIds)
    //             ];

    //             List<Account> airCustomer360 = [SELECT ID,(SELECT LM_TD__c,MTD__c,Customer_Code__c,Customer_Code__r.ParentId
    //                                                     FROM Customer360__r 
    //                                                     WHERE Product__c = 'AIR EXPRESS'
    //                                                     ORDER BY CreatedDate ASC LIMIT 1)
    //                                                     FROM Account
    //                                                     WHERE (ID IN :accountsToReturn.keyset()
    //                                                     OR ID IN :rejectedAccountIds)
    //             ];

    //             Map<String,Customer360__c> accountToSurfaceCustomer360 = new Map<String,Customer360__c>();
    //             if (surfaceCustomer360 != null && surfaceCustomer360.size() > 0) {
    //                 for (Account customer360ToProcess : surfaceCustomer360) {
    //                     if (customer360ToProcess.Customer360__r != null && customer360ToProcess.Customer360__r.size() > 0){
    //                         if (!rejectedAccountIds.contains(customer360ToProcess.Customer360__r[0].Customer_Code__c)) {
    //                             accountToSurfaceCustomer360.put(customer360ToProcess.Customer360__r[0].Customer_Code__c, customer360ToProcess.Customer360__r[0]);
    //                         } else {
    //                             accountToSurfaceCustomer360.put(customer360ToProcess.Customer360__r[0].Customer_Code__r.ParentId, customer360ToProcess.Customer360__r[0]);
    //                         }
    //                     }
    //                 }
    //             }

    //             Map<String,Customer360__c> accountToAirCustomer360 = new Map<String,Customer360__c>();
    //             if (airCustomer360 != null && airCustomer360.size() > 0) {
    //                 for (Account customer360ToProcess : airCustomer360) {
    //                     if (customer360ToProcess.Customer360__r != null && customer360ToProcess.Customer360__r.size() > 0){
    //                         if (!rejectedAccountIds.contains(customer360ToProcess.Customer360__r[0].Customer_Code__c)) {
    //                             accountToAirCustomer360.put(customer360ToProcess.Customer360__r[0].Customer_Code__c, customer360ToProcess.Customer360__r[0]);
    //                         } else {
    //                             accountToAirCustomer360.put(customer360ToProcess.Customer360__r[0].Customer_Code__r.ParentId, customer360ToProcess.Customer360__r[0]);
    //                         }
    //                     }
    //                 }
    //             }

    //             for (String accountId : accountsToReturn.keySet()) {
    //                 if ( accountToLastVisitDate.containsKey(accountId) ) {
    //                     accountsToReturn.get(accountId).put('lastVisitedDate', String.valueOf(accountToLastVisitDate.get(accountId).Visit_Date__c));
    //                     accountsToReturn.get(accountId).put('lastVisitedBy', String.valueOf(accountToLastVisitDate.get(accountId).Owner.Name));
    //                     accountsToReturn.get(accountId).put('DaysSince', daysDiff( ((Account)accountsToReturn.get(accountId).get('account')).Monthly_Spend_on_Logistic__c , accountToLastVisitDate.get(accountId).Visit_Date__c) );
    //                 } else {
    //                     accountsToReturn.get(accountId).put('lastVisitedDate', 'Not Visited Yet!');
    //                     accountsToReturn.get(accountId).put('lastVisitedBy', 'Not Visited Yet!');
    //                 }

    //                 if ( accountToAirCustomer360.containsKey(accountId) ||  accountToSurfaceCustomer360.containsKey(accountId) ) {
    //                     Decimal airMTD =  accountToAirCustomer360.get(accountId)?.MTD__c == null ? 0 : accountToAirCustomer360.get(accountId)?.MTD__c;
    //                     Decimal surfaceMTD = accountToSurfaceCustomer360.get(accountId)?.MTD__c == null ? 0 : accountToSurfaceCustomer360.get(accountId)?.MTD__c;
    //                     Decimal airLM_TD = accountToAirCustomer360.get(accountId)?.LM_TD__c == null ? 0 : accountToAirCustomer360.get(accountId)?.LM_TD__c;
    //                     Decimal surfaceLM_TD = accountToSurfaceCustomer360.get(accountId)?.LM_TD__c == null ? 0 : accountToSurfaceCustomer360.get(accountId)?.LM_TD__c;
    //                     accountsToReturn.get(accountId).put('LMTD', airLM_TD+surfaceLM_TD);
    //                     accountsToReturn.get(accountId).put('MTD', surfaceMTD+airMTD);
    //                 } else {
    //                     accountsToReturn.get(accountId).put('LMTD', 0);
    //                     accountsToReturn.get(accountId).put('MTD', 0);
    //                 }
    //             }
    //         }

            

    //         return accountsToReturn;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
    
    @AuraEnabled
    public static Map<String,Map<String,Object>> getAccountData() {
        Date contractConsiderationDate = System.today() - Integer.valueOf(System.Label.BP_Contract_Consideration);
        String contractRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
        String customerCodeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Code').getRecordTypeId();
        List<Account> contractsAndCustomerCodeAccountsToprocess = [SELECT id,Name,Monthly_Spend_on_Logistic__c,OwnerId,ParentId,Owner.Name,
                                            CreatedDate,Customer_Category__c,Zone_Name__c,RecordTypeId,Owner.Manager.Name,
                                            (SELECT id,Visit_Status__c,Visit_Start_Date__c,Visit_Date__c,
                                            Owner.Name,OwnerId
                                            FROM Customer_Connect__r
                                            WHERE Visit_Start_Date__c != NULL
                                            ORDER BY Visit_Start_Date__c DESC 
                                            LIMIT 1) 
                                            FROM Account 
                                            WHERE (OwnerId IN : getRoleSubordinateUsers(System.UserInfo.getUserId()) 
                                            OR OwnerId = : System.UserInfo.getUserId())
                                            AND ((Contract_end_date__c >= :contractConsiderationDate AND RecordTypeId = :contractRecordTypeId)
                                                OR ( RecordTypeId = :customerCodeRecordTypeId AND Parent.Contract_end_date__c >= :contractConsiderationDate)
                                            )
                                            ORDER BY PARENTID NULLS FIRST
        ];

        Map<String,Map<String,Object>> accountsToReturn = new Map<String,Map<String,Object>>();
        if (contractsAndCustomerCodeAccountsToprocess != null && contractsAndCustomerCodeAccountsToprocess.size() > 0) {
            Set<String> contractAccountOwners = new Set<String>();
            for (Account accountToProcess : contractsAndCustomerCodeAccountsToprocess) {
                if (accountToProcess.RecordTypeId == contractRecordTypeId) {
                    String key = String.valueOf(accountToProcess.OwnerId) + String.valueOf(accountToProcess.Id);
                    Map<String,Object> objectToAdd = getObjectToReturn(accountToProcess);
                    if(objectToAdd != null){
                        accountsToReturn.put(accountToProcess.Id,objectToAdd);
                        contractAccountOwners.add(key);
                    }
                } else {
                    String key = String.valueOf(accountToProcess.OwnerId) + String.valueOf(accountToProcess.ParentId);
                    if ( !contractAccountOwners.contains( key ) ) {
                        Map<String,Object> objectToAdd = getObjectToReturn(accountToProcess);
                        if(objectToAdd != null)
                            accountsToReturn.put(accountToProcess.Id,objectToAdd);
                    } else {
                        Integer daysDiff;
                        if(accountToProcess.Customer_Connect__r != null && accountToProcess.Customer_Connect__r.size() > 0){
                            Customer_Connect__c latestCustomerConnect = accountToProcess.Customer_Connect__r[0];
                            daysDiff =  latestCustomerConnect?.Visit_Start_Date__c?.date()?.daysBetween(System.today());
                        } else {
                            daysDiff =  accountToProcess.CreatedDate.date().daysBetween(System.today());
                        }
                        if (!getConsidration( ((Account)accountsToReturn?.get(accountToProcess.ParentId)?.get('account'))?.Monthly_Spend_on_Logistic__c , daysDiff )){
                            accountsToReturn.remove(accountToProcess.ParentId);
                        }
                        else if ((accountToProcess.Customer_Connect__r != null && accountToProcess?.Customer_Connect__r?.size() > 0) && ((accountsToReturn.get(accountToProcess.ParentId)?.get('lastVisitedDate') == 'Not Visited Yet!') 
                        || (((Date)accountsToReturn?.get(accountToProcess.ParentId)?.get('lastVisitedDate')) < accountToProcess?.Customer_Connect__r[0]?.Visit_Date__c))) {
                            accountsToReturn.get(accountToProcess.ParentId)?.put('lastVisitedDate', accountToProcess.Customer_Connect__r[0].Visit_Date__c);
                            accountsToReturn.get(accountToProcess.ParentId)?.put('lastVisitedBy', String.valueOf(accountToProcess?.Customer_Connect__r[0]?.Owner.Name));
                            accountsToReturn.get(accountToProcess.ParentId)?.put('DaysSince', daysDiff(  ((Account)accountsToReturn?.get(accountToProcess.ParentId)?.get('account'))?.Monthly_Spend_on_Logistic__c , accountToProcess?.Customer_Connect__r[0]?.Visit_Date__c) );
                        }
                    }
                }
            }
        }

        return accountsToReturn;
    }

    @AuraEnabled
    public static Map<String,Object> get360Data(String accountId){
        try {
            Map<String,Object> mapToReturn = new Map<String,Object>();
            String contractRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
            String customerCodeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Code').getRecordTypeId();
            List<Account> surfaceCustomer360 = [SELECT ID,RecordTypeId,(SELECT LM_TD__c,MTD__c,Customer_Code__c,Customer_Code__r.ParentId,LYSM_TD__c
                                                            FROM Customer360__r 
                                                            WHERE Product__c = 'SUR EXPRESS'
                                                            ORDER BY CreatedDate ASC LIMIT 1)
                                                            FROM Account
                                                            WHERE (ID = :accountId AND RecordTypeId = :contractRecordTypeId)
                                                            OR (ParentId = :accountId AND RecordTypeId = :customerCodeRecordTypeId)
            ];

            List<Account> airCustomer360 = [SELECT ID,RecordTypeId,(SELECT LM_TD__c,MTD__c,Customer_Code__c,Customer_Code__r.ParentId,LYSM_TD__c
                                                    FROM Customer360__r 
                                                    WHERE Product__c = 'AIR EXPRESS'
                                                    ORDER BY CreatedDate ASC LIMIT 1)
                                                    FROM Account
                                                    WHERE (ID = :accountId AND RecordTypeId = :contractRecordTypeId)
                                                    OR (ParentId = :accountId AND RecordTypeId = :customerCodeRecordTypeId)
            ];

            Map<String,Customer360__c> accountToSurfaceCustomer360 = new Map<String,Customer360__c>();
            if (surfaceCustomer360 != null && surfaceCustomer360.size() > 0) {
                for (Account customer360ToProcess : surfaceCustomer360) {
                    if (customer360ToProcess.Customer360__r != null && customer360ToProcess.Customer360__r.size() > 0){
                        if ( customer360ToProcess.RecordTypeId == contractRecordTypeId ) {
                            accountToSurfaceCustomer360.put(customer360ToProcess.Customer360__r[0].Customer_Code__c, customer360ToProcess.Customer360__r[0]);
                        } else {
                            accountToSurfaceCustomer360.put(customer360ToProcess.Customer360__r[0].Customer_Code__r.ParentId, customer360ToProcess.Customer360__r[0]);
                        }
                    }
                }
            }

            Map<String,Customer360__c> accountToAirCustomer360 = new Map<String,Customer360__c>();
            if (airCustomer360 != null && airCustomer360.size() > 0) {
                for (Account customer360ToProcess : airCustomer360) {
                    if (customer360ToProcess.Customer360__r != null && customer360ToProcess.Customer360__r.size() > 0){
                        if ( customer360ToProcess.RecordTypeId == contractRecordTypeId ) {
                            accountToAirCustomer360.put(customer360ToProcess.Customer360__r[0].Customer_Code__c, customer360ToProcess.Customer360__r[0]);
                        } else {
                            accountToAirCustomer360.put(customer360ToProcess.Customer360__r[0].Customer_Code__r.ParentId, customer360ToProcess.Customer360__r[0]);
                        }
                    }
                }
            }

            if ( accountToAirCustomer360.containsKey(accountId) ||  accountToSurfaceCustomer360.containsKey(accountId) ) {
                Decimal airMTD =  accountToAirCustomer360.get(accountId)?.MTD__c == null ? 0 : accountToAirCustomer360.get(accountId)?.MTD__c;
                Decimal surfaceMTD = accountToSurfaceCustomer360.get(accountId)?.MTD__c == null ? 0 : accountToSurfaceCustomer360.get(accountId)?.MTD__c;
                Decimal airLM_TD = accountToAirCustomer360.get(accountId)?.LM_TD__c == null ? 0 : accountToAirCustomer360.get(accountId)?.LM_TD__c;
                Decimal surfaceLM_TD = accountToSurfaceCustomer360.get(accountId)?.LM_TD__c == null ? 0 : accountToSurfaceCustomer360.get(accountId)?.LM_TD__c;
                Decimal surfaceLYSM_TD = accountToSurfaceCustomer360.get(accountId)?.LYSM_TD__c == null ? 0 : accountToSurfaceCustomer360.get(accountId)?.LYSM_TD__c;
                Decimal airLYSM_TD = accountToSurfaceCustomer360.get(accountId)?.LYSM_TD__c == null ? 0 : accountToSurfaceCustomer360.get(accountId)?.LYSM_TD__c;
                mapToReturn.put('LMTD', airLM_TD+surfaceLM_TD);
                mapToReturn.put('MTD', surfaceMTD+airMTD);
                mapToReturn.put('LYSMTD', airLYSM_TD+surfaceLYSM_TD);
            } else {
                mapToReturn.put('LMTD', 0);
                mapToReturn.put('MTD', 0);
                mapToReturn.put('LYSMTD', 0);
            }
            return mapToReturn;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String,Object> getObjectToReturn(Account accountToProcess) {
        Map<String,Object> objectToAdd;
        if(accountToProcess.Customer_Connect__r != null && accountToProcess.Customer_Connect__r.size() > 0){
            Customer_Connect__c latestCustomerConnect = accountToProcess.Customer_Connect__r[0];
            Integer daysDiff =  latestCustomerConnect?.Visit_Start_Date__c?.date()?.daysBetween(System.today());
            if (getConsidration(accountToProcess.Monthly_Spend_on_Logistic__c, daysDiff)) {
                objectToAdd = createObject(accountToProcess);
            }
        } else{
            Integer daysDiff =  accountToProcess.CreatedDate.date().daysBetween(System.today());
            if (getConsidration(accountToProcess.Monthly_Spend_on_Logistic__c,daysDiff)){
                objectToAdd = createObject(accountToProcess);
            }
        }

        return objectToAdd; 
    }

    private static Map<String,Object> createObject(Account accountToProcess) {
        Map<String,Object> objectToAdd = new Map<String,Object>();
        objectToAdd.put('Name', accountToProcess.Name);
        objectToAdd.put('account', accountToProcess);
        objectToAdd.put('Id', accountToProcess.Id);
        objectToAdd.put('GatiPotential', accountToProcess.Monthly_Spend_on_Logistic__c);
        if ( accountToProcess.Customer_Connect__r != null && accountToProcess.Customer_Connect__r.size() > 0 ) {
           objectToAdd.put('lastVisitedDate', accountToProcess.Customer_Connect__r[0].Visit_Date__c);
           objectToAdd.put('lastVisitedBy', String.valueOf(accountToProcess.Customer_Connect__r[0].Owner.Name));
           objectToAdd.put('DaysSince', daysDiff( accountToProcess.Monthly_Spend_on_Logistic__c , accountToProcess.Customer_Connect__r[0].Visit_Date__c) );
        } else {
           objectToAdd.put('lastVisitedDate', 'Not Visited Yet!');
           objectToAdd.put('lastVisitedBy', 'Not Visited Yet!');
           objectToAdd.put('DaysSince', daysDiff( accountToProcess.Monthly_Spend_on_Logistic__c,accountToProcess.CreatedDate.date()));
        }
        return objectToAdd;
    }

    private static Integer daysDiff(String potential, Date dateToConsider) {
        switch on potential {
            when 'Above 15 Lakh' {
                return dateToConsider.daysBetween(System.today()) - 15;
            }
            when 'Above 5 Lakh' {
                return dateToConsider.daysBetween(System.today()) - 30;
            }
            when 'Less Than and Equal To 5 Lakh' {
                return dateToConsider.daysBetween(System.today()) - 60;
            }
            when else {
                return null; 
            }
        }
    }

    private static Boolean getConsidration(String potential, Integer daysDiff) {
        if ( potential == 'Less Than and Equal To 5 Lakh' && daysDiff != null && daysDiff > 60 ) {
            return true;
        } else if ( potential == 'Above 5 Lakh' && daysDiff != null && daysDiff > 30 ) {
            return true;
        } else if ( potential == 'Above 15 Lakh' && daysDiff != null && daysDiff > 15 ) {
            return true;
        } else {
            return false;
        }
    }

    public static Set<ID> getRoleSubordinateUsers(Id userId) {
        Id roleId = [SELECT UserRoleId From User Where Id = :userId].UserRoleId;
        Set<Id> allSubRoleIds = getAllSubRoleIds(New Set<ID>{roleId});
        Map<Id, User> users = new Map<Id, User>([SELECT Id, Name From User Where UserRoleId IN :allSubRoleIds]);
        return users.keySet();
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
}