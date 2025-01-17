@isTest
public class TestFactory {
    public static Account getAccount(String name, String customerCategory, String billingpostalcode , Boolean doInsert){
        Account a = new Account(name = name , Customer_Category__c = customerCategory , Billingpostalcode = billingpostalcode);
        if(doInsert)
        {
            a.GATI_Company_Code__c='102';
            
            insert a;
        }
        
        return a;
    }
    
    public static Account getAccount(String name, String customerCategory, String billingpostalcode , Boolean doInsert, Decimal customerCode){
        Account a = new Account(name = name , Customer_Category__c = customerCategory , Billingpostalcode = billingpostalcode, Customer_Code__c = customerCode);
        if(doInsert){
            a.GATI_Company_Code__c='102';            
            insert a;
        }        
        return a;
    }
    
    public static Account getAccount1(String name, String customerCategory, String billingpostalcode , Boolean doInsert, String cont){
        Account a = new Account(Customer_Code__c = 123456 ,name = name , Customer_Category__c = customerCategory , billingpostalcode = Billingpostalcode , Contract_Number__c = cont);
        
        a.Email__c='test@test.com';
        if(doInsert){            
            insert a;
        }        
        return a;
    }
    
    public static Account getAccount2(String name, String customerCategory, String billingpostalcode , Boolean doInsert, String cont){
        Account a = new Account(name = name , Customer_Category__c = customerCategory , billingpostalcode = Billingpostalcode , Contract_Number__c = cont);
        
        a.Email__c='test@test.com';        
        if(doInsert){            
            insert a;
        }        
        return a;
    }
    
    public static Sales_KRA__c getSalesKRA(String name, String month, String year, String remarks, Integer target){
        Sales_KRA__c salesKRA1 = new Sales_KRA__c();
        salesKRA1.Month__c = month;
        salesKRA1.Target__c = target;
        salesKRA1.Remarks__c = remarks;
        salesKRA1.Year__c = year;
        insert salesKRA1;
        return salesKRA1;
    }
    
    public static Targets__c getTargets(String name, Integer amount, id salesKRAId, id accountId){
        Targets__c target1 = new Targets__c();
        target1.Name = name;
        target1.Target_Amount__c = amount;
        target1.Sales_KRA__c = salesKRAId;
        target1.Account__c = accountId;
        insert target1;
        return target1;
    }
    
    public static list <Opportunity> getOpportunity(integer num, id accountId){
        list <opportunity> listtoAdd= new List <Opportunity>();
        for(integer i=0;i<num;i++){ 
            Opportunity op1 = new Opportunity();
            op1.Name='Test Opportunity'+''+string.valueof(i);
            op1.StageName = 'Qualified';
            op1.CloseDate=Date.today();
            op1.RFQ__c = True;
            op1.RFQ_Date__c = DateTime.now();
            op1.AccountId=accountId;
            op1.Loss_Reason__c = 'Revisit'; 
            listtoAdd.add(op1);
        }
        return listtoAdd;
    }
    
    
    public static ContentVersion getContentVersion(String title , String pathOnClient , Blob versionData , Boolean isMajorVersion , String origin){
        ContentVersion cv = new ContentVersion();
        cv.Title = title;
        cv.PathOnClient = pathOnClient;
        cv.VersionData = versionData;
        cv.IsMajorVersion = isMajorVersion;       
        cv.Origin = origin;
        Insert cv;        
        return cv;        
    }
    
    public static ContentDocumentLink getContentDocumentLink(Id linkedEntityId  , Id contentDocumentId , String shareType ){       
        ContentDocumentLink cdl = New ContentDocumentLink();        
        cdl.LinkedEntityId = linkedEntityId;
        cdl.ContentDocumentId = contentDocumentId;
        cdl.shareType = shareType;
        Insert cdl;        
        return cdl;        
    }
    
    public static Organization_Master__c getOrganizationMaster(String name){        
        Organization_Master__c o1 = new Organization_Master__c(Name=name);        
        insert o1;
        return o1;
    }
    
    public static Organization_Master__c getOrganizationMasterextid(String name,String refCode){        
        Organization_Master__c o1 = new Organization_Master__c(Name=name,REF_Code__c=refCode);        
        insert o1;
        return o1;
    }
    
    
    public static Product2 getProduct2(String name,String family,id fromEDCc,id toEDCc)
    {
        
        Product2 p1 = new Product2(Name=name,Family=family,From_EDC__c=fromEDCc,To_EDC__c=toEDCc);
        
        insert p1;
        return p1;
        
        
    }
    
    public static PricebookEntry getPricebookEntry(id pricebook2id,id product2id,Decimal unitprice,Boolean isActive)
    {
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=pricebook2id,product2id=product2id,unitprice=unitprice,isActive=isActive);
        
        insert pbe1;
        return pbe1;
        
        
    }
    
    
    
    public static User getUser(String lastname,String alias,String timeZoneSidKey,String localeSidKey,String emailEncodingKey,
                               String languageLocaleKey,String userName,String email)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user1=new User();
        user1.lastname=lastname;
        user1.Alias=alias;
        user1.TimeZoneSidKey=timeZoneSidKey;
        user1.LocaleSidKey=localeSidKey;
        user1.EmailEncodingKey=emailEncodingKey;
        user1.ProfileId= p.id;
        user1.LanguageLocaleKey=languageLocaleKey;
        user1.userName=userName;
        user1.email=email;
        insert user1;
        return user1;
    }   
    
    public static AccountTeamMember getAccountTeamMember(id accountId,id userId,String role)
    {
        AccountTeamMember accTeamMember= new AccountTeamMember();
        accTeamMember.AccountId=accountId;
        accTeamMember.UserId=userId;
        accTeamMember.TeamMemberRole=role;
        insert accTeamMember;
        return accTeamMember;
    }
    
    public static Group getGroup(String name,String type)
    {
        Group group1=new Group();
        group1.Name=name;
        group1.Type=type;
        insert group1;
        return group1;
    }
    
    public static QueuesObject getQueuesObject(id queueId,String sobjectType)
    {
        QueuesObject queue1 = new QueueSObject();
        queue1.QueueId=queueId;
        queue1.SobjectType=sobjectType;
        insert queue1;
        return queue1;
    }
    
    public static List<Account> getAccountsMCM(integer num,boolean b){
        
        List<Account> acclist = new List<Account>();
        Id crecordtypeid=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Contract').getRecordTypeId(); 
        
        for(integer i=0;i<num;i++)
        {
            acclist.add(new Account(Name='Account'+i,RecordTypeId=crecordtypeid,Customer_Category__c='KEA',BillingPostalCode='201005',MCM_Required__c=True));
        } 
        insert acclist;
        return acclist; 
    }
    
    public static Account getAccounts(String name, String customerCategory, String billingpostalcode ,String industry, Boolean doInsert)
    {
        Account a = new Account(name = name , Customer_Category__c = customerCategory , Billingpostalcode = billingpostalcode, Industry=industry);
        if(doInsert)
        {
            
            insert a;
        }
        
        return a;
    }
    public static Account insertAccount2(String name, string comp_code, date cEndDate, date extDate, Integer extNum, String billingpostalcode)
    {
        Account a1 = new Account();
        a1.Name = name;
        a1.GATI_Company_Code__c = comp_code;
        a1.Extension_Date__c = extDate;
        a1.ExtensionNumber__c = extNum;
        a1.Billingpostalcode = billingpostalcode;
        a1.Contract_end_date__c = cEndDate;
        a1.Contract_Status__c = 'Extended';
        a1.Remarks__c = 'Extended';
        
        insert a1;
        return a1;
    }
    public static Quote insertQuote(String contractNo, string name, String actionType, String outputType, String printFor, String companyId)
    {
        Quote q1 = new Quote();
        q1.Name = name;
        Account acc = insertAccount2(name,companyId,null,null,null,'101010');
        Opportunity opty = insertOpty2(name,date.today(),'Qualified',acc.id);
        q1.OpportunityId = opty.id;
        q1.actionType__c = actionType;
        q1.outputType__c = outputType;
        q1.PrintFor__c = printFor;
        q1.Test_LOF_number__c = contractNo;
        
        
        insert q1;
        return q1;
    }
    public static Opportunity insertOpty2(String name, date closeDate, String Stage, id AccId)
    {
        Opportunity op = new Opportunity();
        op.Name = name;
        op.CloseDate = closeDate;
        op.StageName = Stage;
        op.AccountId = AccId;
        opportunitylineitem lineItem = new opportunitylineitem();
        insert op;
        Organization_Master__c og = getOrgMasterhirrearchy();
        Product2 p = getProduct2('Test',null,og.Parent__r.Parent__c,og.Parent__r.Parent__c); 
        PricebookEntry pbe = getPricebookEntry(Test.getStandardPricebookId(),p.Id,70,True);
        lineItem.OpportunityId = op.id;
        lineItem.Quantity = 10;
        lineItem.TotalPrice = 1000;
        lineItem.PricebookEntryId = pbe.Id ;
        insert lineItem;
        return op;
    }

   
   public static Invoice__c getInvoice(String name, string Account, String eid){
        Invoice__c inv = new Invoice__c();
        inv.Name = name;
        inv.Customer_Code__c = Account;
        inv.Gati_Inv_eid__c = eid;
        insert inv;
        return inv;
    }
    public static MIS__c getMIS(String AccountId,Boolean misFlag, String misTriggerType, String misReportType, String misFieldlist, String misCompanyOf){
      MIS__c mis = new MIS__c();
        mis.Customer_Code__c = AccountId;
        //mis.Customer_Code__r.RecordTypeId = RecordType;
           //Account a = [Select id,RecordType.Name from Account where RecordType.Name = 'Customer_Code'];
        mis.Sender_Mail__c = 'test@gatikwe.com';
        mis.Manual_MIS__c = misFlag;
        mis.Trigger_Type__c = misTriggerType;
        mis.Rep_Type__c = misReportType;
        mis.Field_List__c = misFieldlist;
        mis.Company_Of__c = misCompanyOf;
        insert mis;
        return mis;
    }
    public static Account getAccounts1(String name,String customerCategory, String billingpostalcode ,String industry,date docketDate,Integer creditScore,Organization_Master__c o)
    {
        Account acc = new Account();
        acc.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Contract').getRecordTypeId();
        acc.name = name ;
        acc.Customer_Category__c = customerCategory ;
        acc.Billingpostalcode = billingpostalcode;
        acc.Industry=industry;
        acc.Docket_Date__c=docketDate;
        acc.Credit_Score__c=creditScore;
        acc.Associated_OU__c=o.id;
        // acc.Associated_OU__c=AssociatedOU;
        //acc.Associated_OU__r.parent__r.parent__r.parent__r=bdfs;
        
        
        
        insert acc;
        
        
        return acc;
    }
     public static Account getAccountCC(String name, String customerCategory, String billingpostalcode , Boolean doInsert
                                       
                                       
                                       
                                       )    
     {Account acc = new Account(name = name , Customer_Category__c = customerCategory , billingpostalcode = Billingpostalcode );

acc.RecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Code').getRecordTypeId();

       
       if(doInsert)
        {
            acc.GATI_Company_Code__c='102';
            system.debug(acc);
            insert acc;
        }
            
            
       
        return acc;
    }
    public static Organization_Master__c getOrgMaster(string name)
    {
        Organization_Master__c oc=new Organization_Master__c();
        oc.REF_Code__c=name;
        oc.RecordTypeId =Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('Zone').getRecordTypeId();
        
        insert oc;
        return oc;
    }
    public static Organization_Master__c getOrgMaster1(string name)
    {
        Organization_Master__c oc=new Organization_Master__c();
        oc.Name='name';
        insert oc;
        return oc;
    }
    public static User getUserRole(String lastname,String alias,String timeZoneSidKey,String localeSidKey,String emailEncodingKey,
                                String languageLocaleKey,String userName,String email,String role){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
                                    
          String roleId= '';
                                    
                                    if(role=='Retail'){
                                        roleId = [SELECT Id from userRole WHERE Name='BLR ZONAL RETAIL' limit 1].Id;
                                    }else if(role=='KEA'){
                                        roleId = [SELECT Id from userRole WHERE Name='NATIONAL KEA HEAD' limit 1].Id;
                                    }else if(role=='MSME'){
                                        roleId = [SELECT Id from userRole WHERE Name='BLR Zonal MSME' limit 1].Id;
                                    }else if(role=='Strategic'){
                                        roleId = [SELECT Id from userRole WHERE Name='BLR Zonal Strategic' limit 1].Id;
                                    }
        User user12=new User();
        user12.lastname=lastname;
        user12.Alias=alias;
        user12.TimeZoneSidKey=timeZoneSidKey;
        user12.LocaleSidKey=localeSidKey;
        user12.EmailEncodingKey=emailEncodingKey;
        user12.ProfileId=p.id;
        user12.LanguageLocaleKey=languageLocaleKey;
        system.debug(userName);
        user12.userName=userName;
        user12.email=email;
        user12.userRoleId =   roleId;                          
        user12.managerid=userinfo.getUserId();
        user12.Organi__c='CREDC';
       
        insert user12;
        return user12;
    }
    
    public static User getUser1(String lastname,String alias,String timeZoneSidKey,String localeSidKey,String emailEncodingKey,
                                String languageLocaleKey,String userName,String email)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user12=new User();
        user12.lastname=lastname;
        user12.Alias=alias;
        user12.TimeZoneSidKey=timeZoneSidKey;
        user12.LocaleSidKey=localeSidKey;
        user12.EmailEncodingKey=emailEncodingKey;
        user12.ProfileId=p.id;
        user12.LanguageLocaleKey=languageLocaleKey;
        system.debug(userName);
        user12.userName=userName;
        user12.email=email;
        user12.managerid=userinfo.getUserId();
        user12.Organi__c='CREDC';
        //  UserRole obj=new UserRole(Name= 'Zonal_BDFS'); 
        //insert obj;
        // user12.Userroleid=obj.id;
        insert user12;
        return user12;
    }  
    
    public static Org_Master_User__c getOrgMasterUser(string organizationUnit,string user){
        Org_Master_User__c omu=new Org_Master_User__c();
        omu.Organization_Unit__c=organizationUnit;
        omu.User__c=user;
        insert omu;
        return omu;
    }
    
    
    public static Lead getLead(String Emailid,String Name,String status,String pincode,String phone,String company){
        Lead l = new Lead();
        l.Email=Emailid;
        l.LastName =Name;
        l.Status =status;
        l.PostalCode =pincode;
        l.MobilePhone =phone;
        l.Company =company;
        l.Working_start_Date__c=system.today()-3;
        
        insert l;
        return l;
    } 
        
    public static Messaging.InboundEmail getEmail(String subject ,String name, String emailaddress){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject =subject;
        email.fromname = name;
        email.fromAddress = emailaddress;
        
        return email;
        
    }
    
    public static Messaging.InboundEmail.BinaryAttachment getAttachment(String body,String filename,String filetype){
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf(body);
        attachment.fileName = filename;
        attachment.mimeTypeSubType = filetype;
        return attachment;
        
    }
    
    public static Contact getContact(String name,String email){
        Contact con = new Contact();
        con.LastName= name;
        con.MobilePhone = '9898303000';
        con.Email= email;
        insert con;
        return con;
    }
    
    public static Opportunity insertOpty3(String name, date closeDate, String stage, id accId, Id userid){
        Opportunity op = new Opportunity();
        op.Name = name;
        op.CloseDate = closeDate;
        op.StageName = stage;
        op.AccountId = accId;
        op.Zonal_HEAD__c=userid;
        insert op;
        return op;
    }
    
    public static Account getAccountrecord(String name, String customerCategory, String billingpostalcode,boolean bod){
        Account acc = new Account();
        acc.Name =name;
        acc.BOD__c=bod;
        acc.Customer_Category__c=customerCategory;
        acc.BillingPostalCode=billingpostalcode;
        insert acc;
        return acc;        
    }
    
    public static Organization_Master__c getOrgMasterhirrearchy(){
        Organization_Master__c oc=new Organization_Master__c();
        oc.RecordTypeId =Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('Zone').getRecordTypeId();
        
        insert oc;
        
        Organization_Master__c o=new Organization_Master__c();
        o.RecordTypeId =Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('EDC').getRecordTypeId();
        
        o.Parent__c=oc.id;
        insert o;
        
        Organization_Master__c o1=new Organization_Master__c();
        o1.RecordTypeId =Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('GDW').getRecordTypeId();
        
        o1.Parent__c=o.id;
        insert o1;
        
        Organization_Master__c o2=new Organization_Master__c();
        o2.RecordTypeId =Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByDeveloperName().get('Operation_Unit').getRecordTypeId();
        
        o2.Parent__c=o1.id;
        insert o2;
        o2=[SELECT Name,Parent__c ,Parent__r.Parent__c From  Organization_Master__c Where Id=: o2.Id ];
        
        return o2;
    }
    
    public static Id getMarketMster(){
        Market_Master__c mm = new Market_Master__c();
		mm.Name = '3 PL LOGISTICS';
        mm.Market_Code__c = '1234556789';
        INSERT mm;
        return mm.Id;
    }
    
    public static Lead getLead12(String Name){
        Lead l = new Lead();
        l.Email='abc@gmail.com';
        l.LastName ='Test';
        l.Status ='New';
        l.PostalCode ='500010';
        l.MobilePhone ='9989237816';
        l.Company ='abccoperation';
        l.Working_start_Date__c=date.today()-3;
        l.Status='Working';
        l.Lead_Data__c = 'Retail';
        l.Partner_Type__c = 'C2C';
        l.Market_type__c = TestFactory.getMarketMster();
        l.Monthly_Spent_on_express_Logistic__c='Above 5 Lakh';
        l.Payment_mode__c='Cash';
        User uu=TestFactory.getUser1('BDFS','zBDFS','America/Los_Angeles','en_US','UTF-8','en_US','test.bdfshead1@gati.com','standarduser1@testorg.com');
        
        l.OwnerId=uu.id;
        insert l;
        return l;
        
    }
    
    public static Lead getLeads(String Name){
        Lead l = new Lead();
        l.Email='abc@gmail.com';
        l.LastName ='Test';
        l.Status ='New';
        l.PostalCode ='500010';
        l.MobilePhone =Math.floor(Math.random() * 9000000000L) + 1000000000L+'';
        system.debug(l.MobilePhone);
        l.LeadSource='Website';
        l.Company ='abccoperation';
        l.Working_start_Date__c=date.today()-3;
        l.Status='Working';
        l.Monthly_Spent_on_express_Logistic__c='Above 5 Lakh';
        l.Payment_mode__c='credit';
        
        User uu=TestFactory.getUser1('BDFS','zBDFS','America/Los_Angeles','en_US','UTF-8','en_US','test.bdfshead1'+math.random()+name+'@gati.com','standarduser1@testorg.com');
        l.OwnerId=uu.id;
        insert l;
        return l;
        
    }
    
}