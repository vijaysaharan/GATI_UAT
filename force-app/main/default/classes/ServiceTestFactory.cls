@isTest
public class ServiceTestFactory {
    public static ContentVersion getContentVersion(String title , String pathOnClient , Blob versionData , Boolean isMajorVersion , String origin )
    {
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
    public static Case getCase0( String subject , String origin)
    {
        Case case1=new case();
        case1.Subject = subject;
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type= 'Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
        
        
    }
    
    public static Case getCase( String type, String origin, id accountId)
    {
        Case case1=new case();
        case1.Origin=origin;
        case1.AccountId=accountId;
        case1.Type=type;
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
        
        
    }
    
    public static Case getCase2(String origin, id accountId)
    {
        Case case1=new case();
        case1.Origin=origin;
        case1.AccountId=accountId;
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Pick Up';
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service Request').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
        
        
    }
    
    
    public static Case getCase3(String origin, id accountId)
    {
        Case case1=new case();
        case1.Origin=origin;
        case1.AccountId=accountId;
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Prospect Pickup';
        case1.Mobile__c='9923010657';
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
        
        
    }
     
    public static Case getCase4(String origin, id accountId)
    {
        Case case1=new case();
        case1.Origin=origin;
        case1.AccountId=accountId;
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Exception';        
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service Request').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
             
    }
    
         
    public static Case getCase5(String origin, id accountId)
    {
        Case case1=new case();
        case1.Origin=origin;
        case1.AccountId=accountId;
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Bill back of Expenses';
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service Request').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
             
    }
    
    public static Case getCase1(String origin)
    {
        Case case2=new Case();
        case2.Origin=origin;
        insert case2;
        return case2;
    }
       
    public static Case getCasePopulate(String type)
    {
        Case case1=new case();
        case1.Type=type;
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Undelivered';
        case1.Sub_Type__c= 'NON DELIVERED';
        case1.Status ='Open';
        case1.Complaint_Status__c ='O';
        case1.Reclassification__C =False;
        //case1.Open_CCEC__c=0;
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
        
        
    }
    public static CCEC__c getCCECINCASE(Id cid){
        CCEC__c ccObj =new CCEC__c();
        ccObj.Case__c= cid;
        ccObj.Status__c ='CL';
        ccObj.CCEC_Received_OU__c ='Test';
        insert ccObj;
        return ccObj;	 
    }
    public static Case caseClosePopulate(String type, Id caseId)
    {
        Case case1=new case();
        case1.Type=type;
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Undelivered';
        case1.Sub_Type__c= 'NON DELIVERED';
        case1.Status ='Closed';
        case1.Complaint_Status__c ='AC';
        case1.Reclassification__C =False;
        insert case1;
        return case1;
        
        
    }
    
    public static Case getCaseServiceRequestType(String type,String status){
        Case c =new Case();
        c.Type=type;
        c.Status=status;
        c.Docket_Number__c='104655898';
        c.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        insert c;
        return c;
        
    }
    public static Case getCaseServiceRequestType2(String type,String status,String con1){
        Case c =new Case();
        c.Type=type;
        c.Status=status;
        c.ContactId = con1;
        c.Docket_Number__c='104655898';
        c.RecordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Claim').getRecordTypeId();
        insert c;
        return c;
        
    }
    public static CCEC__c getCCEC(Id cid){
        CCEC__c ccObj =new CCEC__c();
        ccObj.Case__c= cid;
        insert ccObj;
        return ccObj;	 
    }
    
    public static CCEC_Remark__c getCCECRemark(String openRemarks ){
        CCEC_Remark__c ccecObj=new  CCEC_Remark__c();
        ccecObj.Open_Remarks__c=openRemarks;
        insert ccecObj;
        return ccecObj;
    }    
    public static CCEC_Remark__c getCCECRemarkWithCCEC(String openRemarks,String CCECID,string comment ){
        CCEC_Remark__c ccecObj=new  CCEC_Remark__c();
        ccecObj.Open_Remarks__c=openRemarks;
        ccecObj.CCEC__c = CCECID;
        ccecObj.Comments_By__c = comment;
        insert ccecObj;
        return ccecObj;
    } 
    public static Case getCaseClaim(string accId, string invno, String docketno, String email, Long mobile, Long claimValue, datetime invoiceDate){
        Case c1 = new Case();
        c1.Type = 'Claim';
        c1.AccountId = accId;
        c1.Invoice_Number__c = invno;
       	c1.Docket_Number__c = docketno;
        c1.Email_Id__c = email;
        c1.Claim_Mobile_Number__c = mobile;
        c1.Claim_Vaue__c = claimValue;
        c1.Invoice_Date__c = invoiceDate;
        c1.Booking_Date__c = Date.today();
        c1.Actual_delivery_Date__c = Date.today();
        c1.Assured_Delivery_Date__c = Date.today();
        c1.OBN_In_Favour_Of__c = 'S';
        c1.Nature_of_Loss__c = 'D';
        c1.Loss_Description__c = 'No Comments';
        c1.Origin = 'Phone';
     //   c1.ContactId='abc';
        insert c1;
        return c1;
    }
     public static Case getCase7(String origin)
    {
        Case case1=new case();
        case1.Origin=origin;
        //case1.Account.Customer_Code__c=59851028.102;
        Organization_Master__c orgm = TestFactory.getOrganizationMasterextid('test','500003');//new Organization_Master__c(name ='500003');
        case1.Mobile__c='9090909090';
        case1.Shipper_Name__c='Manish';
        case1.Pickup_Address1__c='flat 101';
        case1.Pickup_Address2__c='RTC Coloy';
        case1.Pickup_Address3__c='Tirmulgirri';
        case1.Pick_Up_Pincode__r = orgm;
        case1.Pickup_City__c='Hyderabad';
        case1.Receiver_Pincode__c='500038';
        case1.Company_of__c='102';
        case1.Product__c='2';
        case1.Actual_Weight__c=100;
        case1.Volume__c=120;
        case1.Pickup_Date__c=datetime.now();
        case1.Type='Pick Up';
        //Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick Up').getRecordTypeId();
        //case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
             
    }
    public static Case getCase8(String origin)
    {
        Case case1=new case();
        case1.Origin=origin;
        //case1.Account.Customer_Code__c=59851028.102;
        Organization_Master__c orgm = TestFactory.getOrganizationMasterextid('test','500003');//new Organization_Master__c(name ='500003');
        case1.Mobile__c='9090909090';
        case1.Shipper_Name__c='Manish';
        case1.Pickup_Address1__c='flat 101';
        case1.Pickup_Address2__c='RTC Coloy';
        case1.Pickup_Address3__c='Tirmulgirri';
        case1.Pick_Up_Pincode__r = orgm;
        case1.Pickup_City__c='Hyderabad';
        case1.Receiver_Pincode__c='500038';
        case1.Company_of__c='102';
        case1.Product__c='2';
        case1.Actual_Weight__c=100;
        case1.Volume__c=120;
        case1.Pickup_Date__c=datetime.now();
        case1.Docket_Number__c='171834841';
        case1.Type = 'Invoicing and Others';
        case1.Sub_Type__c='COD DD LOST';
        //Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick Up').getRecordTypeId();
        //case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
             
    }
    public static Case getCase9(String origin)
    {
        Case case1=new case();
        case1.Origin=origin;
        //case1.Account.Customer_Code__c=59851028.102;
        Organization_Master__c orgm = TestFactory.getOrganizationMasterextid('test','500003');//new Organization_Master__c(name ='500003');
        case1.Mobile__c='9090909090';
        case1.Shipper_Name__c='Manish';
        case1.Pickup_Address1__c='flat 101';
        case1.Pickup_Address2__c='RTC Coloy';
        case1.Pickup_Address3__c='Tirmulgirri';
        case1.Pick_Up_Pincode__r = orgm;
        case1.Pickup_City__c='Hyderabad';
        case1.Receiver_Pincode__c='500038';
        case1.Company_of__c='102';
        case1.Product__c='2';
        case1.Actual_Weight__c=100;
        case1.Volume__c=120;
        case1.Pickup_Date__c=datetime.now();
        case1.Docket_Number__c='171834841';
        case1.Type = 'Exception';
        case1.Sub_Type__c='Likely to Fail';
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
             
    }
    
    public static Case getCase10(String origin,id con1)
    {
        Case case1=new case();
        case1.Origin=origin;
        //case1.Account.Customer_Code__c=59851028.102;
        Organization_Master__c orgm = TestFactory.getOrganizationMasterextid('test','500003');//new Organization_Master__c(name ='500003');
        case1.Mobile__c='9090909090';
        case1.Shipper_Name__c='Manish';
        case1.Pickup_Address1__c='flat 101';
        case1.Pickup_Address2__c='RTC Coloy';
        case1.Pickup_Address3__c='Tirmulgirri';
        case1.Pick_Up_Pincode__r = orgm;
        case1.Pickup_City__c='Hyderabad';
        case1.Receiver_Pincode__c='500038';
        case1.Company_of__c='102';
        case1.Product__c='2';
        case1.ContactId = con1;
        case1.Actual_Weight__c=100;
        case1.Volume__c=120;
        case1.Pickup_Date__c=datetime.now();
        case1.Docket_Number__c='171834841';
        case1.Type = 'Exception';
        case1.Sub_Type__c='Bad POD';
        //Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick Up').getRecordTypeId();
        //case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
             
    }
    
    public static Case getCase11(String origin,id con1)
    {
        Case case1=new case();
        case1.Origin=origin;
        //case1.Account.Customer_Code__c=59851028.102;
        Organization_Master__c orgm = TestFactory.getOrganizationMasterextid('test','500003');//new Organization_Master__c(name ='500003');
        case1.Mobile__c='9090909090';
        case1.Shipper_Name__c='Manish';
        case1.Pickup_Address1__c='flat 101';
        case1.Pickup_Address2__c='RTC Coloy';
        case1.Pickup_Address3__c='Tirmulgirri';
        case1.Pick_Up_Pincode__r = orgm;
        case1.Pickup_City__c='Hyderabad';
        case1.Receiver_Pincode__c='500038';
        case1.Company_of__c='102';
        case1.Product__c='2';
        case1.ContactId = con1;
        case1.Actual_Weight__c=100;
        case1.Volume__c=120;
        case1.Pickup_Date__c=datetime.now();
        case1.Docket_Number__c='171834841';  
        case1.Type = 'Invoicing and Others';
        case1.Sub_Type__c='COD DD LOST';
        //Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick Up').getRecordTypeId();
        //case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
        
    }
    public static Case getCase12(String origin,id con1)
    {
        Case case1=new case();
        case1.Origin=origin;
        //case1.Account.Customer_Code__c=59851028.102;
        Organization_Master__c orgm = TestFactory.getOrganizationMasterextid('test2','500038');//new Organization_Master__c(name ='500003');
        case1.Mobile__c='9090909090';
        case1.Shipper_Name__c='Manish';
        case1.Pickup_Address1__c='flat 101';
        case1.Pickup_Address2__c='RTC Coloy';
        case1.Pickup_Address3__c='Tirmulgirri';
        case1.Pick_Up_Pincode__r = orgm;
        case1.Pickup_City__c='Hyderabad';
        case1.Receiver_Pincode__c='500038';
        case1.Company_of__c='102';
        case1.Product__c='2';
        case1.ContactId = con1;
        case1.Actual_Weight__c=100;
        case1.Volume__c=120;
        case1.Pickup_Date__c=datetime.now();
        case1.Value__c='COD/DOD';
        case1.COD_Amt__c=555;
        case1.Docket_Number__c='171834841';  
        case1.Type = 'Invoicing and Others';
        case1.Sub_Type__c='COD DD LOST';
        //Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pick Up').getRecordTypeId();
        //case1.RecordTypeId=crecordtypeid;
        insert case1;
        return case1;
        
    }
    
    public static Ameyo_Voice_Blast_Detail__c getvbRecord(Case c1){
        Ameyo_Voice_Blast_Detail__c amvb = new Ameyo_Voice_Blast_Detail__c();
        amvb.Mobile_no__c = '9999999999';
        amvb.SF_ID__c = c1.id;
        amvb.Process__c = 'NDR';
        amvb.Reason__c = 'DELAYED';
        amvb.Reason_code__c = '24';
        insert amvb;
        return amvb;
    }
     public static Case getCaseClaim1( String origin,id con1 ){
        Case c1 = new Case();
          c1.ContactId = con1;
           c1.Origin=origin;
        c1.Type = 'Claim';
   
        c1.Claim_Reg_By__c = 'Magiel';
       	
        c1.Claim_Status__c = 'accept';
        c1.HO_Approval__c = 'approved';
        c1.Claim_Vaue__c = 1;
        c1.OBN_No__c = 78709;
        c1.Booking_Date__c = Date.today();
        c1.Actual_delivery_Date__c = Date.today();
        c1.Assured_Delivery_Date__c = Date.today();
        c1.OBN_In_Favour_Of__c = 'S';
        c1.Nature_of_Loss__c = 'D';
        c1.Loss_Description__c = 'No Comments';
         
          c1.Docket_Number__c = '145336142';
       	c1.Customer_Email__c = 'rishabh1561999';
        c1.Customer_Name__c = 'rishabh';
        c1.No_of_Packages_Delivered__c = 1;
        c1.No_Of_Packages_Booked__c = 1;
        c1.Actual_Weight_Delivered__c = 78709;
        
        
        c1.Actual_Weight_Booked__c = 1;
        c1.Invoice_Number__c = '1';
        c1.Invoice_Date__c = Date.today();
         
          
          c1.POD_Type__c = 'pod';
       	c1.Remarks_give_on_POD__c = 'Yes';
        c1.Decl_Cargo_value__c = 12344454;
        c1.Risk_Coverage__c = 'coverage';
        c1.Mobile__c = '1111111111';
        c1.CS_Remarks__c = 'Remarks';
         
          c1.CRN__c = '800658';
       	c1.Remarks_give_on_POD__c = 'Yes';
      
        
     //   c1.ContactId='abc';
        insert c1;
        return c1;
    }
    
}