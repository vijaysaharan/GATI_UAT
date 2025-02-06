@RestResource(urlMapping='/UpdateLOF/*')
global with sharing class LOFUpdate{    
    @HttpPost
    global static responseClass doPost(){
       	RestRequest req = RestContext.request;
        String reqBody = EncodingUtil.base64Decode(EncodingUtil.base64Encode(req.requestBody)).toString();
        try{
        	List<LOFUpdateWrapper> wc = new List<LOFUpdateWrapper>();
            wc = (List<LOFUpdateWrapper>)JSON.deserialize(reqBody, List<LOFUpdateWrapper>.class);
           	list<LOFProducts> prdList = new List<LOFProducts>();
            Map<string,PriceBookEntry> keyVSProduct= new Map<string,PriceBookEntry>();
            for(LOFUpdateWrapper i:wc){
                if(i.products!=null){ 
                    for(LOFProducts p: i.products){
                        p.quoteNumber = i.LofNo + i.LOFAmendmentversion+i.OpportunityId;
                    }
                    prdList.addAll(i.products);
                }
            }

            List<string> frmEDC = new List<string>();
            List<string> toEDC = new List<string>();
            List<string> family = new List<string>();
            list<Quote> qobj = new List<Quote>();
            list<Account> aobj = new list<Account>();
            list<Opportunity> optyobj = new list<Opportunity>();
            list<Contact> conobj = new list<Contact>();
            list<QuoteLineItem> qlobj = new list<QuoteLineItem>();
            for(LOFUpdateWrapper wcinst: wc){
                Quote qinst = new Quote(Name=(wcinst.LofNo + wcinst.LOFAmendmentversion));
                Account ainst = new Account(id = wcinst.AccountId);//[select Name from Account where Id=:wcinst.AccountId];
                Opportunity oinst = new Opportunity(Id=wcinst.OpportunityId);// [select Name from Opportunity where Id=:wcinst.OpportunityId];
                Contact cinst = new Contact(Gati_Con_eid__c=wcinst.EmailAddress+wcinst.AccountId);//[select name from contact where LastName = :wcinst.AuthorizedSignatory];
                QuoteLineItem qlinst;
                If( wcinst.LofNo + wcinst.LOFAmendmentversion!= null){
                               qinst.Name =  (String)wcinst.LofNo+' Version '+String.valueOf(wcinst.LOFAmendmentversion);
                }
                If( wcinst.OpportunityId!= null){
                               qinst.OpportunityId = wcinst.OpportunityId;
                }
                If( wcinst.LofNo+wcinst.LOFAmendmentversion!= null){
                               qinst.CMSquoteNumber__c = wcinst.LofNo+wcinst.LOFAmendmentversion+qinst.OpportunityId;                   
                 }
                If( Decimal.valueOf(wcinst.LOFAmendmentversion)!= null){
                               qinst.AmendedVersion__c = Decimal.valueOf(wcinst.LOFAmendmentversion);
                }
                If( wcinst.LOFDate!= null){
                               qinst.LOF_Date__c = wcinst.LOFDate;
                }
                If( wcinst.LOFAmendmentDate!= null){
                               qinst.LOF_Amendment_Date__c = wcinst.LOFAmendmentDate;
                }
                If( wcinst.LOFValidityDate!= null){
                               qinst.LOF_Validity_Date__c = wcinst.LOFValidityDate;
                }
                If( wcinst.LOFValidityDate!= null){
                               qinst.Test_LOF_number__c = wcinst.LofNo;
                }                
                If( wcinst.CustomerName!= null){
                               ainst.Name = wcinst.CustomerName;
                }
                If( wcinst.ContractType!= null){
                               ainst.Contract_type__c = wcinst.ContractType;
                }
                If( wcinst.RiskCoveredBy!= null){
                               ainst.Risk_Covered_By__c = wcinst.RiskCoveredBy;
                }
                If( wcinst.PANNo!= null){
                               ainst.PANNumber__c = wcinst.PANNo;
                }
                If( wcinst.creditLimitAmount!= null){
                               ainst.Credit_Amount__c = wcinst.creditLimitAmount;
                }
                If( wcinst.Creditperiod!= null){
                               ainst.Credit_Period__c = wcinst.Creditperiod;
                }
                If( wcinst.BillingOn!= null){
                               ainst.Billing_On__c = wcinst.BillingOn;
                }
                If( wcinst.BillingFrequency!= null){
                               ainst.Billing_Frequency__c = wcinst.BillingFrequency;
                }
                If( wcinst.Billingday1!= null){
                               ainst.Billing_Day1__c = wcinst.Billingday1;
                }
                If( wcinst.Billingday2!= null){
                               ainst.Billing_Day2__c = wcinst.Billingday2;
                }
                If( wcinst.Billingday3!= null){
                               ainst.Billing_Day3__c = wcinst.Billingday3;
                }
                If( wcinst.Billingday4!= null){
                               ainst.Billing_Day4__c = wcinst.Billingday4;
                }
                If( wcinst.Billingday5!= null){
                               ainst.Billing_Day5__c = wcinst.Billingday5;
                }
                If( wcinst.FreeStorageDays!= null){
                               ainst.Free_storage_days__c = wcinst.FreeStorageDays;
                }
                If( wcinst.OUCode!= null){
                    Organization_Master__c orgM = new Organization_Master__c(REF_Code__c=wcinst.OUCode);
                               ainst.Associated_OU__r = orgM ;
                }
                If( wcinst.LOFContractStatus!= null){
                               ainst.Contract_Status__c = wcinst.LOFContractStatus;
                    			qinst.LOF_Status__c= wcinst.LOFContractStatus;
                }
                If( wcinst.ContractMobileNumber!= null){
                               ainst.Mobile__c = wcinst.ContractMobileNumber;
                }
                If( wcinst.RegisteredUnderAct!= null){
                               cinst.Registered_Under_Act__c = wcinst.RegisteredUnderAct;
                }
                If( wcinst.AccountId!= null){
                               cinst.AccountId = wcinst.AccountId;
                }
                If( wcinst.RegistedOfficeAddress1!= null){
                               cinst.Registered_Office_Address1__c = wcinst.RegistedOfficeAddress1;
                }
                If( wcinst.RegistedOfficeAddress2!= null){
                               cinst.Registered_Office_Address2__c = wcinst.RegistedOfficeAddress2;
                }
                If( wcinst.InStateOf!= null){
                               cinst.In_state_of__c = wcinst.InStateOf;
                }
                If( wcinst.AuthorizedSignatory!= null){
                               cinst.LastName = wcinst.AuthorizedSignatory;
                }
                If( String.valueof(wcinst.TelephoneNumber)!= null){
                               cinst.Phone = String.valueof(wcinst.TelephoneNumber);
                }
                If( String.valueof(wcinst.MobileNumber)!= null){
                               cinst.MobilePhone = String.valueof(wcinst.MobileNumber);
                }
                If( wcinst.EmailAddress!= null){
                               cinst.Email = wcinst.EmailAddress;
                }
                If( wcinst.Designation!= null){
                               ainst.Designation__c = wcinst.Designation;
                }
                If( wcinst.ContractValidity!= null){
                               ainst.Contract_Validity__c = wcinst.ContractValidity;
                }
                If( wcinst.ContractStartDate!= null){
                               ainst.ContractStartDate__c = wcinst.ContractStartDate;
                }
                If( wcinst.Creditperiod!= null){				
                    ainst.Credit_Period__c = wcinst.Creditperiod;
                }
                If( wcinst.creditLimitAmount!= null){
                               ainst.Credit_Amount__c = wcinst.creditLimitAmount;
                }
                If( String.valueof(wcinst.pincode)!= null){
                               ainst.BillingPostalCode = String.valueof(wcinst.pincode);
                }
                If( wcinst.status!= null){
                               //qinst.Status = wcinst.status==''?'Draft':wcinst.status;
                }
                If( wcinst.approval_staff_code!= null){
                               qinst.Approver_Staff_Code__c = wcinst.approval_staff_code;
                }
                If( wcinst.approved_date!= null){
                               qinst.Approved_Date__c = wcinst.approved_date;
                }
                If( wcinst.rejected_date!= null){
                               qinst.Rejected_Date__c = wcinst.rejected_date;
                }
                If( wcinst.submitted_date!= null){
                               qinst.Submitted_Date__c = wcinst.submitted_date;
                }
                If( wcinst.last_approval_staff_code!= null){
                               qinst.Last_Approver__c = wcinst.last_approval_staff_code;
                }
                If( wcinst.CustomerBusinesPotential!= null){
                               oinst.Amount_Business_potentital__c = wcinst.CustomerBusinesPotential;
                }
                If( wcinst.CommitedGatiPotentail!= null){
                               oinst.Commited_Gati_Potentail__c = wcinst.CommitedGatiPotentail;
                }
                If( wcinst.Credit_limit_Aprvl_stf_code!= null){
                               ainst.Credit_limit_approval_Staff_code__c = wcinst.Credit_limit_Aprvl_stf_code;
                }
                If( wcinst.Credit_limit_Aprvl_stf_name!= null){
                               ainst.Credit_limit_approval_Staff_name__c = wcinst.Credit_limit_Aprvl_stf_name;
                }
                If( wcinst.Credit_limit_Aprvl_dt!= null){
                               ainst.Credit_limit_approval_Date__c = wcinst.Credit_limit_Aprvl_dt;
                }
                If( wcinst.Credit_period_Aprvl_stf_code!= null){
                               ainst.Credit_period_approval_Staff_code__c = wcinst.Credit_period_Aprvl_stf_code;
                }
                If( wcinst.Credit_period_Aprvl_stf_name!= null){
                               ainst.Credit_period_approval_Staff_name__c = wcinst.Credit_period_Aprvl_stf_name;
                }
                If( wcinst.Credit_period_Aprvl_dt!= null){
                               ainst.Credit_period_approval_Date__c = wcinst.Credit_period_Aprvl_dt;
                }
                If( wcinst.CreditScore!= null){
                               ainst.Credit_Score__c = wcinst.CreditScore;
                }
                If( wcinst.oldCreditScore!= null){
                               ainst.Old_Credit_Score__c = wcinst.oldCreditScore;
                }
                If( wcinst.oldCreditLimitAmount!= null){
                               ainst.Old_Credit_Limit_Amount__c = wcinst.oldCreditLimitAmount;
                }
                If( wcinst.oldCreditperiod!= null){
                               ainst.Old_Credit_Period__c = wcinst.oldCreditperiod;
                }
                If( wcinst.Created_by!= null){
                               qinst.CMS_Created_By__c = wcinst.Created_by;
                }
                If( wcinst.Created_date!= null){
                               qinst.CMS_Created_Date__c =datetime.valueof(wcinst.Created_date);
                }
                If( wcinst.last_updated_by!= null){
                               qinst.CMS_Last_Updated_By__c = wcinst.last_updated_by;
                }
                If( wcinst.last_updated_date!= null){
                               qinst.CMS_Last_Updated_Date__c = datetime.valueof(wcinst.last_updated_date);
                }               
                If( wcinst.PCSD_date!= null){
                               ainst.Physical_contract_copy_start_date__c= wcinst.PCSD_date;
                }
                If( wcinst.PCD_date!= null){
                               ainst.Physical_contract_copy_end_date__c= wcinst.PCD_date;
                }
                If( wcinst.dcr_status!= null){
                               ainst.DCR_Status__c= wcinst.dcr_status;
                }
                If( wcinst.isContractApprovedVersion!= null){
                               ainst.Is_Contract_approved_version__c= wcinst.isContractApprovedVersion;
                }
                If( wcinst.contractActivationDate!= null){
                               ainst.Contract_Activation_Date__c= wcinst.contractActivationDate;
                }
                If( wcinst.contractExtensionDate!= null){
                               ainst.Extension_Date__c= wcinst.contractExtensionDate;
                }
                If( wcinst.contractTerminationDate!= null){
                               ainst.Termination_Date__c= wcinst.contractTerminationDate;
                }
                If( wcinst.contractEndDate!= null){
                               ainst.Contract_end_date__c= wcinst.contractEndDate;
                }
                If( wcinst.contractRenewDate!= null){
                               ainst.Renew_Date__c= wcinst.contractRenewDate;
                }
                If( wcinst.dph_type!= null){
                               ainst.DPH_Type__c= wcinst.dph_type;
                }
                If( wcinst.atf_type!= null){
                               ainst.ATF_Type__c= wcinst.atf_type;
                }
                If( wcinst.ess2applicability_flag!= null){
                               ainst.ess2applicability_flag__c= wcinst.ess2applicability_flag;
                }
                If( wcinst.customerType!= null){
                               ainst.Customer_Category__c= wcinst.customerType;
                }
                If( wcinst.atf_index!= null){
                               ainst.ATF_Index__c= wcinst.atf_index;
                }
                If( wcinst.dieselPrice!= null){
                               ainst.Diesel_Price__c= wcinst.dieselPrice;
                }
                /*for(LOFProducts qli: wcinst.products){
                    qlinst = new QuoteLineItem();
                    qlinst.From_EDC__c = qli.frmLane;
                    qlinst.To_EDC__c = qli.toLane;
                    qlinst.UnitPrice = qli.RevenuePerMonth;
                    qlinst.Quantity = qli.VolumePerMonth;
                    qlinst.Quote = qinst;
                    qlobj.add(qlinst);
                }*/
                qobj.add(qinst);
                aobj.add(ainst);
                optyobj.add(oinst);
                if(wcinst.EmailAddress!='' || wcinst.EmailAddress!=null)
                {	conobj.add(cinst);
                }
            }
            system.debug(qobj);
            try{
                upsert qobj CMSquoteNumber__c;
                
                for(LOFProducts prd: prdList){
                    frmEDC.add(prd.frmLane);
                    toEDC.add(prd.toLane);
                    family.add(prd.productFamily);
                    
                }
                List<PriceBookEntry> productlist = [Select id,Product2ID,Product2.From_EDC__r.name,Product2.To_EDC__r.name, Product2.Family from PricebookEntry where Product2.Family in :family OR Product2.From_EDC__r.name in :frmEDC OR Product2.To_EDC__r.name in :toEDC]; 
            	
                if(productlist.size()>0)
                {
                   	for(PriceBookEntry ppname: productlist)
                   	{
                      	String key= ppname.Product2.From_EDC__r.name + '' + ppname.Product2.To_EDC__r.name + '' + (ppname.Product2.Family).toUpperCase();
                    	keyVSProduct.put(key,ppname);
                   	}
                    for(LOFProducts prd: prdList){
                        String key= prd.frmLane + '' + prd.toLane + '' +  (prd.productFamily).toUpperCase();
                        QuoteLineItem qlnst = new QuoteLineItem();
                        Quote qtemp = new Quote(CMSquoteNumber__c = prd.quoteNumber);                       
                        qlnst.Quote = qtemp;
                        qlnst.PricebookEntryId = keyVSProduct.get(key).id;
                        qlnst.Product2Id = keyVSProduct.get(key).Product2ID;                        
                        qlnst.UnitPrice = prd.RevenuePerMonth;
                        qlnst.Quantity = prd.VolumePerMonth;
                        qlobj.add(qlnst);
                    }                    
                    upsert qlobj;
                }
                
                update aobj;
                update optyobj;
                if (conobj.size()>0)
                {
	                upsert conobj Gati_Con_eid__c;
                }
            }
            catch(Exception e){
                responseClass res = new responseClass();
                res.result = 'DB Error';
                res.message = e.getMessage();
                return res;
            }
            
            responseClass res = new responseClass();
            res.result = 'success';
            res.message = 'Success';
            return res;
        }
        catch(Exception e){
            responseClass res = new responseClass();
            res.result = 'Error';
            res.message = e.getMessage();
            system.debug(e.getMessage() +e.getLineNumber()+e.getCause());
            return res;
        }
    }
    
    global class ResponseClass{
        string result{get;set;}
        string message{get;set;}
    }
    
    public class LOFUpdateWrapper {
        //string OpportunityId;
        public List<LOFProducts> products{get;set;} //
        string AccountId{get;set;} //*
        string OpportunityId{get;set;} //*
        string LofNo{get;set;} //*
        date LOFDate{get;set;} //*
        date LOFValidityDate{get;set;} //*
        string LOFAmendmentversion{get;set;} //*
        date LOFAmendmentDate{get;set;} //*
        string CustomerName{get;set;} //*
        string LOFContractStatus{get;set;} //*
        string ContractType{get;set;} //*
        string RiskCoveredBy{get;set;} //*
        Integer CustomerBusinesPotential{get;set;} //*
        Integer CommitedGatiPotentail{get;set;} //*
        string PANNo{get;set;} //*
        String BillingOn{get;set;} //*
        string BillingFrequency{get;set;} //*
        decimal Billingday1{get;set;} //*
        decimal Billingday2{get;set;} //*
        decimal Billingday3{get;set;} //*
        decimal Billingday4{get;set;} //*
        decimal Billingday5{get;set;} //*
        decimal FreeStorageDays{get;set;} //*
        Long MobileNumber{get;set;} //*
        String OUCode{get;set;} //*
        Integer pincode{get;set;} //*
        string RegisteredUnderAct{get;set;} //*
        string RegistedOfficeAddress1{get;set;} //--
        string RegistedOfficeAddress2{get;set;} //--
        string InStateOf{get;set;} //*
        string AuthorizedSignatory{get;set;} //*
        Long TelephoneNumber; //*
        string ContractMobileNumber;
        string EmailAddress{get;set;} //*
        string Designation{get;set;} //*
        date ContractValidity{get;set;} //*
        date ContractStartDate{get;set;} //*
        String approval_staff_code{get;set;} //*
        String last_approval_staff_code{get;set;} //*
        String status{get;set;}	   //*
        date approved_date{get;set;} //*
        date submitted_date{get;set;} //*
        date rejected_date{get;set;} //*
        Integer CreditScore{get;set;} //*
        long creditLimitAmount{get;set;} //*
        Integer Creditperiod{get;set;} //*
        Integer oldCreditScore{get;set;} //*
        long oldCreditLimitAmount{get;set;} //*
        Integer oldCreditperiod{get;set;} //*
        STring Created_date{get;set;} //*
        string Created_by{get;set;} //*
        String last_updated_date{get;set;} //*
        string last_updated_by{get;set;} //*
        string Credit_limit_Aprvl_stf_code{get;set;} //*
        string Credit_limit_Aprvl_stf_name{get;set;} //*
		date Credit_limit_Aprvl_dt{get;set;} //*
		string Credit_period_Aprvl_stf_code{get;set;} //*
        string Credit_period_Aprvl_stf_name{get;set;} //*
		date Credit_period_Aprvl_dt{get;set;} //*
        date PCSD_date{get;set;}
        date PCD_Date{get;set;}
        string dcr_status{get;set;}
        boolean isContractApprovedVersion{get;set;}
        date contractActivationDate{get;set;}
        date contractExtensionDate{get;set;}
        date contractTerminationDate{get;set;}
        date contractEndDate{get;set;}
        date contractRenewDate{get;set;}
        string dph_type{get;set;}
        string atf_type{get;set;}
        string ess2applicability_flag{get;set;}
        string customerType{get;set;}
        Decimal atf_index{get;set;}
        Decimal dieselPrice{get;set;}
        public LOFUpdateWrapper(){
            products = new list<LOFProducts>();
        }
    }
    public class LOFProducts{
        public string toLane{get;set;}
        public string frmLane{get;set;}
        public string quoteNumber{get;set;}
        public Integer VolumePerMonth{get;set;}
        public Integer RevenuePerMonth{get;set;}
        public string productFamily{get;set;}
    }
}