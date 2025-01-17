@isTest
public class ParseJsonUtilTest {
	@TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Test';
        insert a;
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'Test';
        insert c;
    }
    
    @isTest
    static void parseJsonTest(){
        List<Contact> contactList = Database.query(JSONTemplate__mdt.getInstance('Example_Contact_Template').Query__c);
        for(Contact con : contactList){
            String key = 'Example_Contact_Template'+con.AccountId;
            if(ParseJsonUtil.MetaDataToSobjects.containskey(key)){
                ParseJsonUtil.MetaDataToSobjects.get(key).add(con);
            }else{
                ParseJsonUtil.MetaDataToSobjects.put(key, new List<Sobject>{con});   
            }
        }
        String recordId = [Select id from Account Limit 1].Id;
        ParseJsonUtil.MetaDataToSobjects.put('Example_Account_Template', Database.query(JSONTemplate__mdt.getInstance('Example_Account_Template').Query__c));
        ParseJsonUtil.MetaDataToVariable.put('Example_Account_Template0xyz', 'TEST DATA');
        ParseJsonUtil.parseJson('Example_Account_Template',false);
    }
}