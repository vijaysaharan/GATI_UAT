public class CustomerConnectUpdateCheckIn {
    @AuraEnabled
    Public static void updateCheckInTime(String recordId){
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Id = recordId;
        cc.Check_In_Time__c = System.now();
        update cc;
    }
    @AuraEnabled
    public static Map<String,Decimal> getRevenueDetailsOfAccount(Id accId){
        Map<String,Decimal> returnDetails = new Map<String,Decimal>();
        String monthYear = System.now().format('MMMM').substring(0,3).toUpperCase()+'-'+System.now().year();
        //String monthYear = 'APR-2022';
        List<Account> currentAccount = [SELECT Id,RecordType.Name 
                                        FROM Account
                                        WHERE Id =: accId
                                       ];
        System.debug('currentAccount[0].RecordType.Name'+currentAccount[0].RecordType.Name);
        if(currentAccount != null && currentAccount.size()>0 && currentAccount[0].RecordType.Name == 'Contract'){
            List<Account> allChildAccounts = [SELECT Id
                                              FROM Account
                                              WHERE ParentId =:currentAccount[0].Id
                                             ];
            if(allChildAccounts != null && allChildAccounts.size()>0){
                List<Customer360__c> customer360Data = [SELECT Id,Net_Biz__c,Product__c
                                                        FROM Customer360__c
                                                        WHERE Customer_Code__c IN: allChildAccounts
                                                        AND MonthYear__c =: monthYear
                                                       ];
                if(customer360Data != null && customer360Data.size()>0){
                    returnDetails = calculateAirAndSurface(customer360Data);
                }
            }
        }else if(currentAccount != null && currentAccount.size()>0 && currentAccount[0].RecordType.Name != 'Contract'){
            List<Customer360__c> customer360Data = [SELECT Id,Net_Biz__c,Product__c
                                                    FROM Customer360__c
                                                    WHERE Customer_Code__c =: currentAccount[0].Id
                                                    AND MonthYear__c =: monthYear
                                                   ];
            if(customer360Data != null && customer360Data.size()>0){
                returnDetails = calculateAirAndSurface(customer360Data);
            }
        }
        return returnDetails;
    }    
    private static Map<String,Decimal> calculateAirAndSurface(List<Customer360__c> customerDetails){
        Map<String,Decimal> returnCalculations = new Map<String,Decimal>();
        Decimal airTotal = 0;
        Decimal surfaceTotal = 0;
        if(customerDetails != null && customerDetails.size()>0){
            for(Customer360__c cus : customerDetails){
                if(cus.Product__c == 'SUR EXPRESS'){
                    surfaceTotal += cus.Net_Biz__c;
                }
                else if(cus.Product__c == 'AIR EXPRESS'){
                    airTotal += cus.Net_Biz__c;
                }
            }
        }
        returnCalculations.put('AIR EXPRESS',airTotal);
        returnCalculations.put('SUR EXPRESS',surfaceTotal);
        return returnCalculations;
    }
    @AuraEnabled
    public static Account getAccountDetails(Id accId){
        List<Account> accountDetailsToReturn = [SELECT Id, Customer_Category__c FROM Account WHERE Id = :accId];
        if(accountDetailsToReturn != null && accountDetailsToReturn.size()>0){
            return accountDetailsToReturn[0];
        }
        else{
            return null;
        }
    } 
}