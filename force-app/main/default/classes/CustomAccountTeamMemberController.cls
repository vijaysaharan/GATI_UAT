public class CustomAccountTeamMemberController {
    public CustomAccountTeamMemberController(ApexPages.StandardController stdController) {
        // this.acct = (Quote)stdController.getRecord();
    }
    /* for import data into sobject and insert data from csv file  */ 
    @AuraEnabled
    public static string insertData(String strfromle){
        System.debug('strfromle'+strfromle);
        String returnresponse ='';
        try{
            String userProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            
            // Check if the user's profile is 'Sales'
            if (userProfile == 'Business Credit Sales Profile' || userProfile == 'Business Retail Sales Profile' || userProfile == 'Business Sales/Service Profile'||
                userProfile == 'UCL Sales Team' || userProfile == 'National Sales Profile' || userProfile == 'National Inside Sales Profile') {
                    // Throw an error message
                    throw new AuraHandledException('You are not an Authorised Person to Add Account Team Member !!');
                }
            Set<Id> setAccounts = new Set<Id>();
            Set<String> setAccountsCode = new Set<String>();
            Set<String> setUsername = new Set<String>();
            Map<String,String> mapAccountCodeUsername = new Map<String,String>();
            Map<ID,String> mapAccountIdUsername = new Map<ID,String>();
            Map<String,ID> mapUserIdUsername = new Map<String,ID>();
            Map<Id,Id> mapAccountIdUserId = new Map<Id,Id>();
            // Map<Id,Id> mapAccountIdUserId = new Map<Id,Id>();
            List<AccountTeamMember> insertLstAccountTeamMember = new List<AccountTeamMember>();
            
            // List<Account> AccoutnListtoInsert = new List<Account>();
            system.debug('strfromle = ' + strfromle);
            List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strfromle, List<fieldWrapper>.class);
            system.debug('datalist = ' + datalist);
            system.debug('datalistSize = ' + datalist.size());
            if(datalist != null && datalist.size() > 0){
                for(fieldWrapper wrapper: datalist){
                    setAccountsCode.add(String.valueOf(wrapper.CustomerCode));
                    setUsername.add(wrapper.Username.toLowerCase());
                    mapAccountCodeUsername.put(String.valueOf(wrapper.CustomerCode),wrapper.Username.toLowerCase());         
                }
                system.debug('setAccountsCode = ' + setAccountsCode);
                system.debug('setUsername = ' + setUsername);
                system.debug('mapAccountCodeUsername = ' + mapAccountCodeUsername);
                
                if(setAccountsCode !=null && setAccountsCode.size() > 0){
                    List<Account> lstAccount = [Select Id,GATI_Customer_Code__c from Account where GATI_Customer_Code__c IN :setAccountsCode];
                    if(lstAccount != null && lstAccount.size() > 0){
                        for(Account eachAcc:lstAccount){
                            setAccounts.add(eachAcc.Id);
                            mapAccountIdUsername.put(eachAcc.Id,mapAccountCodeUsername.get(eachAcc.GATI_Customer_Code__c));
                        }
                    }
                    
                    system.debug('mapAccountIdUsername = ' + mapAccountIdUsername);
                    //  system.debug('mapAccountIdUsername values = ' + mapAccountIdUsername.values());
                    
                    if(setUsername !=null && setUsername.size() > 0){
                        List<User> lstUser = [Select Id,Username from User where Username IN :setUsername];
                        system.debug('lstUser = ' + lstUser);
                        if(lstUser != null && lstUser.size() > 0){
                            for(User eachUser:lstUser){
                                mapUserIdUsername.put(eachUser.Username.toLowerCase(),eachUser.id);
                                // mapAccountIdUserId.put(eachUser.Id,mapAccountIdUsername.get(eachUser.Username));
                            }
                        }
                        
                        
                    }
                    
                    system.debug('mapUserIdUsername = ' + mapUserIdUsername);                
                    for(Id accountId: mapAccountIdUsername.keyset()){
                        mapAccountIdUserId.put(accountId,mapUserIdUsername.get(mapAccountIdUsername.get(accountId)));
                    }
                }
                
                system.debug('setAccounts = ' + setAccounts);
                system.debug('mapAccountIdUserId = ' + mapAccountIdUserId);
                if(setAccounts !=null && setAccounts.size() > 0){
                    List<AccountTeamMember> lstAccountTeamMember = [Select Id from AccountTeamMember where TeamMemberRole = 'Service Resource' AND AccountId IN :setAccounts];
                    if(lstAccountTeamMember != null && lstAccountTeamMember.size() > 0){
                        Delete lstAccountTeamMember;
                    }
                    
                    for(Id eachAccountId:setAccounts){
                        AccountTeamMember eachAccountMember = new AccountTeamMember();
                        eachAccountMember.AccountId = eachAccountId;
                        eachAccountMember.UserId = mapAccountIdUserId.get(eachAccountId);
                        eachAccountMember.TeamMemberRole = 'Service Resource';
                        eachAccountMember.CaseAccessLevel = 'Edit';
                        eachAccountMember.AccountAccessLevel = 'Read';
                        eachAccountMember.OpportunityAccessLevel = 'None';
                        insertLstAccountTeamMember.add(eachAccountMember);
                    }
                    system.debug('Account Team Member List = ' + insertLstAccountTeamMember);
                    if(insertLstAccountTeamMember != null && insertLstAccountTeamMember.size() > 0){
                        insert insertLstAccountTeamMember;
                    }
                    Integer batchSize = 20;
                    String query = 'Select Id,AccountId from Case where Status != \'Closed\' AND AccountId IN :setAccounts';
                    List<Account_Team_Member__mdt> accountTeamMember = new List<Account_Team_Member__mdt>([Select Batch_Size__c FROM Account_Team_Member__mdt where MasterLabel ='Account Team Member']);
                    if(accountTeamMember != null && accountTeamMember.size() > 0){batchSize = Integer.valueOf(accountTeamMember[0].Batch_Size__c);}
                    system.debug('accountTeamMember===>'+accountTeamMember);
                    system.debug('batchSize===>'+batchSize);
                    CustomAccountTeamMemberCaseUpdate batch = new CustomAccountTeamMemberCaseUpdate(query,mapAccountIdUserId,setAccounts);  
                    Database.executeBatch(batch, batchSize);
                    
                }else{
                    returnresponse = 'ERROR';
                }
            }
        returnresponse = 'SUCCESS';
        }catch(Exception ex){
			returnresponse = ex.getMessage()+ex.getLineNumber();
		}
        /*if(AccoutnListtoInsert.size() > 0){
try {
insert AccoutnListtoInsert;
returnresponse = 'SUCCESS';
}
catch(Exception ex){
returnresponse = 'ERROR';
}
}*/
        return returnresponse;
    }
    
    public class fieldWrapper{        
        // public String AccountId;        
        // public String UserId; 
        public Decimal CustomerCode;        
        public String Username; 
        // public String phone;
        
    } 
    
}