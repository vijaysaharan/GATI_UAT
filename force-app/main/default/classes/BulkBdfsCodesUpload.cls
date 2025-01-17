public with sharing class BulkBdfsCodesUpload {
    @AuraEnabled    
    public static Map<String,String> CsvDataHandler(String csvDataList) {
        Map<String,String> returnMap = New Map<String,String>();
        List<csvWrapper> dataWrapper = new List<csvWrapper>();
        String lineBreak = '\n';
        String successHeader = 'CustomerCode,BDFSCode,Message\n';
        String successData = '';
        String errorHeader = 'CustomerCode,BDFSCode,Message\n';
        String errorData = '';
        returnMap.put('successHeader',successHeader);
        returnMap.put('errorHeader',errorHeader);

        try {
            Map<String,String> customerCodeToBdfsCode = new Map<String, String>();
            Set<String> accountCustomerCodes = new Set<String>();
            Set<String> bdfsCodes = new Set<String>();
            Map<String, Contact> bfdsCodeToContact = new Map<String, Contact>();
            List<Account> accountsToUpdate = new List<Account>();
            Map<String, String> customerCodeToResult = new Map<String, String>();

            dataWrapper = (List<csvWrapper>) JSON.deserialize(
                csvDataList, List<csvWrapper>.class
            );
            for (csvWrapper csv : dataWrapper){
                if(csv.CustomerCode != null && csv.BDFSCode != null){
                    customerCodeToBdfsCode.put(csv.CustomerCode,csv.BDFSCode);
                    accountCustomerCodes.add(csv.CustomerCode);
                    bdfsCodes.add(csv.BDFSCode);
                }
            }
            Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, GATI_Customer_Code__c, BDFS_Code__c, BDFS_Name__c 
                                                                FROM Account 
                                                                WHERE GATI_Customer_Code__c IN: accountCustomerCodes
                                                            ]);
            List<Contact> contactList = [SELECT Id, StaffCode__c, Name
                                         FROM Contact
                                         WHERE StaffCode__c IN: bdfsCodes
                                        ];
            if(contactList != null && contactList.size() > 0){
                for(Contact con : contactList){
                    bfdsCodeToContact.put(con.StaffCode__c,con);
                }
            }
            if(accountMap != null && accountMap.values().size() > 0){
                for(Account acc : accountMap.values()){
                    if(customerCodeToBdfsCode.containsKey(acc.GATI_Customer_Code__c) && ((customerCodeToBdfsCode.get(acc.GATI_Customer_Code__c) != null) || (customerCodeToBdfsCode.get(acc.GATI_Customer_Code__c) != '')) && bfdsCodeToContact.containsKey(customerCodeToBdfsCode.get(acc.GATI_Customer_Code__c))){
                        acc.BDFS_Code__c = customerCodeToBdfsCode.get(acc.GATI_Customer_Code__c);
                        acc.BDFS_Name__c = bfdsCodeToContact.get(customerCodeToBdfsCode.get(acc.GATI_Customer_Code__c)).Name;
                        accountsToUpdate.add(acc);
                    }
                }
            }
            if(accountsToUpdate != null && accountsToUpdate.size() > 0){
                List<Database.SaveResult> saveResults = Database.update(accountsToUpdate,false);
                if(saveResults != null && saveResults.size()>0){
                    for(Database.SaveResult sr : saveResults){
                        if(sr.isSuccess() && accountMap.containsKey(sr.getId())){
                            customerCodeToResult.put(accountMap.get(sr.getId()).GATI_Customer_Code__c,'Success');
                        }
                        else if(accountMap.containsKey(sr.getId())){
                            customerCodeToResult.put(accountMap.get(sr.getId()).GATI_Customer_Code__c,'Error');
                        }
                    }
                }
            }
            for(csvWrapper csv : dataWrapper){
                String baseString = csv.CustomerCode+','+csv.BDFSCode+',';
                if(customerCodeToResult.containsKey(csv.CustomerCode)){
                    baseString += customerCodeToResult.get(csv.CustomerCode);
                    if(customerCodeToResult.get(csv.CustomerCode) == 'Success'){
                        successData += baseString+'\n';
                    }
                    else{
                        errorData += baseString+'\n';
                    }
                }
                else if(!bfdsCodeToContact.containsKey(csv.BDFSCode)){
                    errorData += baseString+'Error - Contact Not Exists\n';
                }
                else{
                    errorData += baseString+'Error - Some Other Error\n';
                }
            }
            if(successData != null && successData != ''){
                returnMap.put('successData',successData);
            }
            if(errorData != null && errorData != ''){
                returnMap.put('errorData',errorData);
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }    

    public class CsvWrapper{
        @AuraEnabled public String CustomerCode;
        @AuraEnabled public String BDFSCode;
    }
}