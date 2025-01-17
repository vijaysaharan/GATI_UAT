/*
@ClassName : Contract_Management_Sys_LOF
@Author : Alfio D@Wipro
@Purpose: This class is used to create LOF in CMS system using data from CRM
*/


public with sharing class Contract_Management_Sys_LOF {
    @AuraEnabled
    public static void payHistoryData(String optyId){
        LOFpayload reqBody = new LOFpayload();
        Opportunity opty = 
            [SELECT Account.Risk_Covered_By__c,
             (Select Product2.Family,
              Product2.From_EDC__r.Name,
              UnitPrice,
              Product2.To_EDC__r.Name from OpportunityLineItems),
             Account.Associated_OU__r.Name,
             Account.Controlling_OU__c,
             //Account.Contract_Number__c,
             Account.GATI_Company_Code__c,
             AccountId,
             Commited_Gati_Potentail__c,
             Payment_mode__c,
             Account.PANNumber__c,
             Account.Name,
             Account.Customer_Category__c,
             Account.Contract_type__c,
             Account.Customer_Type__c,             
             Gati_Company_Code__c,
             Type,
             Amount_Business_potentital__c,
             RFQ__c, 
             RFQ_Date__c,
             /************added new****************/
             Account.Industry,
             Account.GATI_Customer_Code__c,
             Owner.Email,
             Account.BillingCity,
             Account.GSTNumber__c,
             Account.Market_Type__r.Market_Type__c,
             Account.Market_Type__r.Market_Code__c,
             Account.Market_Type__r.Name,
             Account.Credit_Amount__c,
             Account.Nature_of_business__c,
             Account.Registration_Status__c,
             Account.Mobile__c,
             Account.BillingPostalCode,
             Account.BillingStreet,
             Account.BillingState,
             Account.Phone,
             Account.Credit_Days__c,
             (SELECT Contact.Name,Contact.Email From OpportunityContactRoles Where IsPrimary=true),   
             /**************************end*****************/          
             Amount from Opportunity
             where ID=:optyId];
        String staffCode = [SELECT Staff_Code__c FROM User WHERE Id = :UserInfo.getUserId()].Staff_Code__c;
        
        reqBody.customerName=opty.Account.Name;
        reqBody.customerCode =opty.Account.GATI_Customer_Code__c;
        reqBody.contractType=opty.Account.Contract_type__c; //Opty Payment mode
        reqBody.controllingOu=opty.Account.Associated_OU__r.Name; // OU Code in Opty*
        reqBody.billingOu=opty.Account.Associated_OU__r.Name; // OU Code in Opty
        //reqBody.riskCoverdBy=opty.Account.Risk_Covered_By__c; 
        reqBody.rfq=opty.RFQ__c?'Y':'N';//opty.RFQ__c; //To be clarified  Clarification
        reqBody.rfqlaunchdate=opty.RFQ__c?opty.RFQ_Date__c:null;
        reqBody.customerType=opty.Account.Customer_Type__c;//Type in Opty*
        reqBody.customerCategory=opty.Account.Customer_Category__c; 
        reqBody.customerbusinespotential=(Integer)opty.Amount_Business_potentital__c; // Amount (Business potentital) in Opty*
        reqBody.commitedGatiPotentail=(Integer)opty.Commited_Gati_Potentail__c;
        reqBody.panNo=opty.Account.PANNumber__c; // PANNumber in Account
        reqBody.accountId = opty.Account.Id;
        reqBody.bdStaffCode=staffCode; // User Staff code
        reqBody.opprortunityId=opty.Id; // Oppty Id
        reqBody.companyId=Integer.valueOf(opty.Account.GATI_Company_Code__c);
        /*****************************************new changes*************************************/
        if(!opty.OpportunityContactRoles.IsEmpty()){
            reqBody.contact_person_name = opty.OpportunityContactRoles[0].Contact.Name;
            reqBody.emailid = opty.OpportunityContactRoles[0]. Contact.Email;
        }
        reqBody.custIndustry = opty.Account.Industry;
        reqBody.assignedseemail = opty.Owner.Email;
        reqBody.city = opty.Account.BillingCity;
        reqBody.gstin = opty.Account.GSTNumber__c;
        if(opty.Account.Market_Type__r!=null){
            reqBody.marketType = opty.Account.Market_Type__r.Market_Type__c;
            reqBody.marketCode = opty.Account.Market_Type__r.Market_Code__c;
            reqBody.marketname = opty.Account.Market_Type__r.Name;
        }
        reqBody.shorttermcreditamt = opty.Account.Credit_Amount__c==null?0:opty.Account.Credit_Amount__c;
        reqBody.nature_of_business = opty.Account.Nature_of_business__c;
        reqBody.nature_of_business = opty.Account.Registration_Status__c;
        reqBody.mobileno = opty.Account.Mobile__c;
        reqBody.ou_code = opty.Account.Associated_OU__r.Name;
        reqBody.pincode = opty.Account.BillingPostalCode;
        reqBody.address1 = opty.Account.BillingStreet;
        reqBody.address2 = opty.Account.BillingStreet;
        reqBody.state = opty.Account.BillingState;
        reqBody.phoneno = opty.Account.Phone;
        reqBody.shorttermcreditdays = opty.Account.Credit_Days__c;
        reqBody.cust_type_kyc = 'Firm';
        /***************************************************************/
        for(OpportunityLineItem oli:opty.OpportunityLineItems){
            LineItems li = new LineItems();
            li.laneMaxBusiness = (Integer)oli.UnitPrice;
            li.toLane = oli.Product2.To_EDC__r.Name;
            li.frmLane = oli.Product2.From_EDC__r.Name;
            li.productGroup = oli.Product2.Family;
            reqBody.lineDtls.add(li);
        }
        system.debug(reqBody.rfqlaunchdate);
        
        Http http = new Http();              
        HttpRequest req1 = new HttpRequest();
        String authParams = API_credential__mdt.getInstance('Create_LOF_in_CMS').Other_Auth_Parameter__c;
        String[] authParamsSplitted = authParams.split('\\|');
        
        for (String authpar:authParamsSplitted){
            String[] nameValue= authpar.split('\\:');
            req1.setHeader(nameValue[0], nameValue[1]);                   
        }
        
        req1.setHeader('Content-Type','application/json');
        req1.setHeader('accept','application/json');
        req1.setTimeout(10000);
        req1.setEndpoint(API_credential__mdt.getInstance('Create_LOF_in_CMS').Endpoint__c);
        req1.setBody(JSON.serialize(reqBody));
        System.debug('JSON.serialize(reqBody) => '+JSON.serialize(reqBody));
        req1.setMethod('POST');
        System.debug('reqBody'+reqBody);
        try{
            HttpResponse res1 = http.send(req1);
            System.debug('res1.getBody()=='+res1.getBody());
            if(res1.getStatusCode() == 200) {    
                //root = (Root)JSON.deserialize(res1.getbody(),Root.class); 
                Map<String, Object> lofResponse = (Map <String, Object>)JSON.deserializeUntyped(res1.getbody());
                String resultStatus = (String)lofResponse.get('result');
                if(resultStatus =='failed'){
                    throw new AuraHandledException('Error : '+(String)lofResponse.get('sErrMsg'));
                }
                List<Object> quoteResponse = (List<Object>)lofResponse.get('response');
                try{
                    for (Object quoteRes:quoteResponse){
                        Map<String, Object> quoteResMap = (Map<String, Object>)quoteRes;
                        Quote quoteInst = new Quote();
                        quoteInst.Name= (String)quoteResMap.get('lofNo')+' Version '+String.valueOf(quoteResMap.get('lofAmendmentVersion'));
                        quoteInst.Test_LOF_number__c =(String)quoteResMap.get('lofNo');
                        quoteInst.CMSquoteNumber__c = (String)quoteResMap.get('lofNo')+String.valueOf(quoteResMap.get('lofAmendmentVersion'))+optyId;
                        //quoteInst.ExpirationDate=date.parse((String)quoteResMap.get('lofValidityDate'));
                        quoteInst.OpportunityId=opty.Id;//
                        insert quoteInst;
                    }
                }
                catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
            }
            else{
                throw new AuraHandledException('Error fetching details');
            }
        }
        catch(MyException e){
            System.debug(e.getMessage());
        }
        
    }
    
    public class LineItems{
        public decimal laneMaxBusiness;
        public string toLane;
        public string frmLane;
        public string locType;
        public string productGroup;
        public LineItems(){
            locType='EDC';
        }
    }
    public class LOFpayload{
        public string customerName {get;set;}
        public String customerCode {get;set;}
        public string customerGroupId {get;set;}
        public string loContractStatus {get;set;}
        public string contractType {get;set;}
        public string controllingOu {get;set;}
        public string billingOu {get;set;}
        public string riskCoverdBy {get;set;}
        public string contractSubType {get;set;}
        public string customerType {get;set;}
        public string customerCategory {get;set;}
        public string rfq {get;set;}
        public datetime rfqlaunchdate {get;set;}
        public Integer customerbusinespotential {get;set;}
        public Integer commitedGatiPotentail {get;set;}
        public string panNo {get;set;}
        public String bdStaffCode {get;set;}
        public String opprortunityId {get;set;}
        public String accountId {get;set;}
        public integer companyId {get;set;}
        //public string customerFlag {get;set;}
        //public string contractNo {get;set;}
        //public string paymentMode {get;set;}
        //public Integer creditLimitAmount {get;set;}
        //public Integer creditPeriod {get;set;}
        //public string billingOn {get;set;}
        //public string billingRule {get;set;}
        //public string billingFrequency {get;set;}
        //public Integer billingday {get;set;}
        //public Integer freeStorageDays {get;set;}
        /*********************************added newly*******************/
        public String contact_person_name {get;set;}
        public String custIndustry {get;set;}
        public String assignedseemail {get;set;}
        public String city {get;set;}
        public String gstin {get;set;}
        public String marketType {get;set;}
        public String marketCode {get;set;}
        public String marketname {get;set;}
        public Decimal shorttermcreditamt {get;set;}
        public String cust_type_kyc {get;set;}
        public String nature_of_business {get;set;}
        public String Registration_status {get;set;}
        public String mobileno {get;set;}
        public String ou_code {get;set;}
        public String pincode {get;set;}
        public String address1 {get;set;}
        public String address2 {get;set;}
        public String state {get;set;}
        public String phoneno {get;set;}
        public String emailid {get;set;}
        public Decimal shorttermcreditdays {get;set;}
        /***************end********************************************/
        public List<LineItems> lineDtls{get;set;}
        public LOFpayload(){
            lineDtls = new List<LineItems>();
        }
    }
    public class MyException extends Exception{}
}