public without sharing class Claim_Registration_OutboundAPI implements Queueable, Database.AllowsCallouts {
    public List<String> case1id;
    
    public Claim_Registration_OutboundAPI(List<String> caseIds){
        this.case1id = caseIds;
    }
    
    @InvocableMethod
    public static void calloutMethod(list<String> case1id){
        Claim_Registration_OutboundAPI claimRegistration = new Claim_Registration_OutboundAPI(case1id);
        System.enqueueJob(claimRegistration);
    }
    
    public void execute(QueueableContext context){
        List<Integration_Log__c> integrationLogs = new List<Integration_Log__c>();
        Map<Id,List<Subwrapper>> caseIdToSubwrapperList = new Map<Id,List<Subwrapper>>(); 
        
        Map<Id,Case> caseIdToMap = new Map<Id,Case>([SELECT  Id, Pre_Checks__c,Claim_Vaue__c,Direct_Debit__c,LastModifiedBy.Staff_Code__c,
                            LastModifiedById,Company_of__c, Assured_Delivery_Date__c, Intimation_Time__c,Error_message__c,  
                            sync_flag__c, Booking_OU__r.REF_Code__c, CaseNumber, Claim_Registered_By__c, 
                            Survey_Requirement__c, Address__c, Remarks_If_any__c, DEPS_Info__c, CreatedBy.staff_code__c, 
                            crn__c,Case_Name__c, POD_Type__c, Docket_Number__c, Customer_Name__c, CS_Remarks__c, 
                            No_of_Packages_Delivered__c, No_Of_Packages_Booked__c, Actual_Weight_Booked__c, Origin, 
                            Actual_Weight_Delivered__c, Invoice_Date__c, Booking_OU__r.Name, Claim_Submitted_Date__c,
                            Contents_as_per_invoice__c, Consignor_Name__c, Consignee_Name__c, OBN_In_Favour_Of__c, Booking_Date__c, 
                            Delivery_OU__r.Name, Remarks_give_on_POD__c, Nature_of_Loss__c, Net_Loss_Amount__c, CreatedDate, 
                            Insurer_Name__c, Decl_Cargo_value__c, Loss_Description__c, LastModifiedDate, Actual_delivery_Date__c, Customer_Email__c, Mobile__c,
                            Claim_Mobile_Number__c,Email_Id__c, Insurance_policy_No__c,  Invoice_Number__c, Insurance_policy_expiry_Date__c 
                            FROM Case 
                            WHERE Id IN: case1id
                            ]);
        /*Updation Related To Attachment*/
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId,LinkedEntityId,ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.LatestPublishedVersion.PathOnClient FROM ContentDocumentLink WHERE LinkedEntityId = :case1id];
        if(contentDocumentLinks != null && contentDocumentLinks.size()>0){
            for(ContentDocumentLink cd : contentDocumentLinks){
                Id caseId = cd.LinkedEntityId;
                Subwrapper attObj = new Subwrapper();
                attObj.Body=EncodingUtil.base64Encode(cd.ContentDocument.LatestPublishedVersion.VersionData);
                String Namecomponent = caseIdToMap.get(caseId).Docket_Number__c+'_'+caseIdToMap.get(caseId).CaseNumber+'_'+cd.ContentDocument.LatestPublishedVersion.PathOnClient;
                attObj.Name=Namecomponent;
                
                if(caseIdToSubwrapperList.containsKey(caseId)){
                    caseIdToSubwrapperList.get(caseId).add(attObj);
                }
                else{
                    caseIdToSubwrapperList.put(caseId,new List<Subwrapper>{attObj});
                }
            }
        }
        /*
        List<ContentVersion> contentVersions = [SELECT Id,VersionData,Title,PathOnClient,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdToCaseId.keySet()];
        if(contentVersions != null && contentVersions.size()>0){
            for(ContentVersion cv : contentVersions){
                if(contentDocumentIdToCaseId.containsKey(cv.ContentDocumentId)){
                    Id caseId = contentDocumentIdToCaseId.get(cv.ContentDocumentId);
                    Subwrapper attObj = new Subwrapper();
                    blob vdata=cv.VersionData;
                    string base64value = EncodingUtil.base64Encode(vdata);
                    attObj.Body=base64value;
                    String Namecomponent = caseIdToMap.get(caseId).Docket_Number__c+'_'+caseIdToMap.get(caseId).CaseNumber+'_'+cv.PathOnClient;
                    attObj.Name=Namecomponent;

                    if(caseIdToSubwrapperList.containsKey(caseId)){
                        caseIdToSubwrapperList.get(caseId).add(attObj);
                    }
                    else{
                        caseIdToSubwrapperList.put(caseId,new List<Subwrapper>{attObj});
                    }
                }
            }
        }*/

        for(Case case1 : caseIdToMap.values()){
            ClaimRegWrapper regBody = new ClaimRegWrapper();
            try{
                regBody.docketNo =case1.Docket_Number__c;
                if(case1.OBN_In_Favour_Of__c=='S'){
                    regBody.customerName = case1.Consignor_Name__c;
                }
                else if(case1.OBN_In_Favour_Of__c=='R'){
                    regBody.customerName = case1.Consignee_Name__c;
                }
                else{
                    regBody.customerName = case1.Customer_Name__c;
                }
                
                if(case1.Case_Name__c==null){
                    regBody.caseName='';
                }
                else{
                    regBody.caseName = case1.Case_Name__c;
                }
                
                if(string.valueof(case1.No_of_Packages_Delivered__c) == null){
                    regBody.packagesDelivered='';
                }
                else{
                    regBody.packagesDelivered = string.valueof(case1.No_of_Packages_Delivered__c);
                }
                
                if(string.valueof(case1.No_Of_Packages_Booked__c) == null){
                    regBody.packagesBooked='';
                }
                else{
                    regBody.packagesBooked = string.valueof(case1.No_Of_Packages_Booked__c);
                }
                
                if(string.valueof(case1.Actual_Weight_Booked__c) == null){
                    regBody.actualWeightBooked='';
                }
                else{
                    regBody.actualWeightBooked = string.valueof(case1.Actual_Weight_Booked__c);
                }
                
                if(string.valueof(case1.Actual_Weight_Delivered__c) == null){
                    regBody.actualWeightDelivered='';
                }
                else{
                    regBody.actualWeightDelivered = string.valueof(case1.Actual_Weight_Delivered__c);
                }
                
                if(string.valueof(case1.Invoice_Number__c) == null){
                    regBody.invoiceNo='';
                }
                else{
                    regBody.invoiceNo = string.valueof(case1.Invoice_Number__c);
                }
                
                if(case1.Invoice_Date__c==null){
                    regBody.invoiceDate='';
                }
                else{
                    regBody.invoiceDate = case1.Invoice_Date__c.format('dd-MM-yyyy HH:mm:ss');
                }
                
                if(case1.Booking_Date__c==null){
                    regBody.bookingDate='';
                }
                else{   
                    datetime booktemp =DateTime.newInstance(case1.Booking_Date__c.year(),case1.Booking_Date__c.month(),case1.Booking_Date__c.day());
                    regBody.bookingDate =booktemp.format('dd-MM-yyyy HH:mm:ss');
                }
                
                if(case1.Booking_OU__r.Name==null){
                    regBody.bookingStation='';
                }
                else{
                    regBody.bookingStation = case1.Booking_OU__r.Name;
                }
                
                if(case1.Contents_as_per_invoice__c==null){
                    regBody.invoiceContents='';
                }
                else{
                    regBody.invoiceContents = case1.Contents_as_per_invoice__c;
                }
                
                if(case1.Remarks_give_on_POD__c==null){
                    regBody.podRemarks='';
                }
                else{
                    regBody.podRemarks = case1.Remarks_give_on_POD__c;
                }
                
                if(case1.Delivery_OU__r.Name==null){
                    regBody.deliveryStation='';
                }
                else{
                    regBody.deliveryStation = case1.Delivery_OU__r.Name;
                }
                
                if(case1.Booking_OU__r.REF_Code__c==null){
                    regBody.ouCode='';
                }
                else{
                    regBody.ouCode = case1.Booking_OU__r.REF_Code__c;
                }
                
                if(case1.POD_Type__c==null){
                    regBody.podType='';
                }
                else{
                    regBody.podType = case1.POD_Type__c;
                }
                
                if(case1.Actual_delivery_Date__c == null){
                    regBody.actualDeliveryDate='';
                }
                else{
                    datetime acttemp =DateTime.newInstance(case1.Actual_delivery_Date__c.year(),case1.Actual_delivery_Date__c.month(),case1.Actual_delivery_Date__c.day());
                    regBody.actualDeliveryDate =acttemp.format('dd-MM-yyyy HH:mm:ss');
                }
                
                if(case1.Assured_Delivery_Date__c==null){
                    regBody.actualDeliveryDate='';
                }
                else{
                    datetime assuredtemp =DateTime.newInstance(case1.Assured_Delivery_Date__c.year(),case1.Assured_Delivery_Date__c.month(),case1.Assured_Delivery_Date__c.day());
                    regBody.assuredDeliveryDate =assuredtemp.format('dd-MM-yyyy HH:mm:ss');
                }
                
                if(string.valueof(case1.Decl_Cargo_value__c)==null){
                    regBody.declaredCargoValue='';
                }
                else{
                    regBody.declaredCargoValue = string.valueof(case1.Decl_Cargo_value__c);
                }
                
                if(case1.Customer_Email__c==null){
                    regBody.emailId='';
                }
                else{
                    regBody.emailId = case1.Customer_Email__c;
                }
                
                if(string.valueof(case1.Mobile__c)==null){
                    regBody.mobileNo='';
                }
                else{
                    regBody.mobileNo = string.valueof(case1.Mobile__c);
                }
                
                if(string.valueof(case1.Insurance_policy_No__c)==null){
                    regBody.insurancePolicyNo='';
                }
                else{
                    regBody.insurancePolicyNo = case1.Insurance_policy_No__c;
                }
                
                if(case1.Insurer_Name__c==null){
                    regBody.insurerName='';
                }
                else{
                    regBody.insurerName = case1.Insurer_Name__c;
                }
                
                if(case1.Insurance_policy_expiry_Date__c==null){
                    regBody.insuranceExpiryDate='';
                }
                else{
                    regBody.insuranceExpiryDate = case1.Insurance_policy_expiry_Date__c.format('dd-MM-yyyy HH:mm:ss');
                }
                
                if(case1.Survey_Requirement__c==null){
                    regBody.surveyRequirement='';
                }
                else{
                    regBody.surveyRequirement = case1.Survey_Requirement__c;
                }
                
                if(string.valueof(case1.Claim_Vaue__c)==null){
                    regBody.claimValue='';
                }
                else{
                    regBody.claimValue = string.valueof(case1.Claim_Vaue__c);
                }
                
                if(string.valueof(case1.Net_Loss_Amount__c)==null){
                    regBody.netLossAmount='';
                }
                else{
                    regBody.netLossAmount = string.valueof(case1.Net_Loss_Amount__c);
                }
                
                if(case1.Loss_Description__c==null){
                    regBody.lossDescription='';
                }
                else{
                    regBody.lossDescription = case1.Loss_Description__c;
                }
                
                regBody.obnInFavourOf = case1.OBN_In_Favour_Of__c;
                
                if(case1.Address__c==null){
                    regBody.adddress='';
                }
                else{
                    regBody.adddress = case1.Address__c;
                }
                
                if(case1.Remarks_If_any__c==null){
                    regBody.remarks='';
                }
                else{
                    regBody.remarks = case1.Remarks_If_any__c;
                }
                
                if(case1.CS_Remarks__c==null){
                    regBody.csRemarks='';
                }
                else{
                    regBody.csRemarks = case1.CS_Remarks__c;
                }
                
                if(case1.Pre_Checks__c==true){
                    regBody.csCheck='Yes';
                }
                else{
                    regBody.csCheck = 'No';
                }
                
                if(regBody.csCheck=='Yes'){
                    regBody.ClaimAcceptance='Y';
                }
                else{
                    regBody.ClaimAcceptance='N';
                }
                
                if(case1.Direct_Debit__c==null){
                    regBody.directDebit='';
                }
                else{
                    regBody.directDebit = case1.Direct_Debit__c;
                }
                
                if(case1.DEPS_Info__c==null){
                    regBody.depsInfo='';
                }
                else{
                    regBody.depsInfo = case1.DEPS_Info__c;
                }
                
                if(case1.Intimation_Time__c==null){
                    regBody.intimationTime='';
                }
                else{
                    regBody.intimationTime = case1.Intimation_Time__c;
                }
                
                if(case1.CreatedDate==null){
                    regBody.claimSubmittedDate='';
                }
                else{
                    regbody.claimSubmittedDate = case1.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                
                if(case1.Origin==null){
                    regBody.source='';
                }
                else{
                    regbody.source = case1.Origin;
                }
                
                if(case1.CreatedDate==null){
                    regBody.claimCreatedDate='';
                }
                else{
                    regBody.claimCreatedDate = case1.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                
                if(case1.Origin=='Web'||case1.Origin=='WhatsApp'||case1.Origin=='Email'||case1.Origin=='Portal API'||case1.Origin=='Portal'||case1.Origin=='Simply360'){
                    regBody.claimCreatedBy='Customer';
                }
                else{
                    regBody.claimCreatedBy = case1.CreatedBy.staff_code__c;
                }
                
                if(case1.CreatedBy.staff_code__c==null){
                    regBody.claimCreatedBy='';
                }
                else{
                    regBody.claimCreatedBy = case1.CreatedBy.staff_code__c;
                }
                
                if(case1.CaseNumber==null){
                    regBody.crn='';
                }
                else{
                    regBody.crn = case1.CaseNumber;
                }
                
                if(case1.Nature_of_Loss__c==null){
                    regBody.natureofLoss='';
                }
                else{
                    regBody.natureofLoss = case1.Nature_of_Loss__c;
                }
                
                if(case1.LastModifiedDate==null){
                    regBody.lastModifiedDate='';
                }
                else{
                    regBody.lastModifiedDate = case1.LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                
                if(case1.lastModifiedBy==null){
                    regBody.lastModifiedBy='';
                }
                else{
                    regBody.lastModifiedBy = case1.LastModifiedBy.staff_code__c;
                }
                
                regBody.companyof = case1.Company_of__c;
                
                if(case1.Claim_Registered_By__c==null){
                    regBody.claimRegBy='';
                }
                else{
                    regBody.claimRegBy = case1.Claim_Registered_By__c;
                }
                
                //Attachment
                if(case1.Pre_Checks__c==true && caseIdToSubwrapperList.containsKey(case1.Id)){
                    regBody.attachments.addAll(caseIdToSubwrapperList.get(case1.Id));
                    /*
                    List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :case1id];
                    Set<Id> documentIds = new Set<Id>();
                    for (ContentDocumentLink cdl : cdls){
                        documentIds.add(cdl.ContentDocumentId);
                    }
                    
                    List<ContentVersion> documents = [Select Id,VersionData,Title,PathOnClient FROM ContentVersion WHERE ContentDocumentId IN :documentIds];
                    List<String> vsds = new List<String>();
                    for (ContentVersion vsd : documents.get(case1.Id)){
                        Subwrapper attObj = new Subwrapper();
                        blob vdata=vsd.VersionData;
                        string base64value = EncodingUtil.base64Encode(vdata);
                        attObj.Body=base64value;
                        String Namecomponent = case1.Docket_Number__c+'_'+case1.CaseNumber+'_'+vsd.PathOnClient;
                        attObj.Name=Namecomponent;
                        regBody.attachments.add(attObj);
                    }
                    */
                }
                
                //Attachment
                Http http = new Http();              
                HttpRequest reg1 = new HttpRequest();
                String AuthParams = API_credential__mdt.getInstance('claim_registration').Other_Auth_Parameter__c;
                String[] AuthParamsSplitted = AuthParams.split('\\|');
                for (String Authpar:AuthParamsSplitted){
                    String[] nameValue= Authpar.split('\\:');
                    reg1.setHeader(nameValue[0], nameValue[1]);                   
                }
                reg1.setHeader('Content-Type','application/json');
                reg1.setHeader('accept','application/json');
                reg1.setEndpoint(API_credential__mdt.getInstance('claim_registration').Endpoint__c);
                reg1.setBody(JSON.serialize(regBody));
                reg1.setMethod('POST');
                reg1.setTimeout(50000);
                
                HttpResponse result= http.send(reg1);
                String errormsg1;
                
                if(result.getStatusCode()==200){
                    ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                    try{
                        errormsg1=responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='Claim_Registration_OutboundAPI log';
                        ic.Error_Message__c=errormsg1;
                        ic.IsIntegration__c=true;
                        ic.CaseNumber__c=case1.CaseNumber;
                        ic.eRecordID__c = case1.id;
                        ic.eObject__c = 'Case';
                        ic.Inbound_JSON__c=result.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(regBody);
                        integrationLogs.add(ic);
                    }
                    catch(Exception e){} 
                }
                else{
                    
                    ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                    
                    errormsg1=responseObj.sErrMsg;
                    Integration_Log__c ic = new Integration_Log__c();
                    ic.Component_Name__c='Claim_Registration_OutboundAPI log';
                    ic.Error_Message__c=errormsg1;
                    ic.IsIntegration__c=true;
                    ic.CaseNumber__c=case1.CaseNumber;
                    ic.eRecordID__c = case1.id;
                    ic.eObject__c = 'Case';
                    ic.Inbound_JSON__c=result.getBody();
                    ic.Outbound_JSON__c=JSON.serialize(regBody);
                    integrationLogs.add(ic);
                }  
            }
            catch(Exception e){
                Integration_Log__c ic = new Integration_Log__c();
                ic.Component_Name__c='Claim_Registration_OutboundAPI log';
                ic.Error_Message__c=e.getMessage();
                ic.IsIntegration__c=true;
                ic.CaseNumber__c=case1.CaseNumber;
                ic.eRecordID__c = case1.id;
                ic.eObject__c = 'Case';
                ic.Inbound_JSON__c=JSON.serialize(regBody);
                ic.Outbound_JSON__c=JSON.serialize(regBody);
                integrationLogs.add(ic);
            }
        }
        
        if(integrationLogs != null && integrationLogs.size()>0){
            insert integrationLogs;
        }
    }
    
    public class ClaimRegWrapper{
        public string docketNo{get;set;}
        public string customerName{get;set;}
        public String packagesDelivered{get;set;}
        public String packagesBooked{get;set;}
        public String actualWeightDelivered{get;set;}
        public String actualWeightBooked{get;set;}
        public String invoiceNo{get;set;}
        public string invoiceDate{get;set;}
        public String bookingDate{get;set;}
        public string bookingStation{get;set;}
        public string invoiceContents{get;set;}
        public string deliveryStation{get;set;}
        public string ouCode{get;set;}
        public string podType{get;set;}
        public string podRemarks{get;set;}
        public string actualDeliveryDate{get;set;}
        public string declaredCargoValue{get;set;}
        public string riskCoverage{get;set;}
        public string emailId{get;set;}
        public string mobileNo{get;set;}
        public string insurancePolicyNo{get;set;}
        public string insurerName{get;set;}
        public string insuranceExpiryDate{get;set;}
        public string surveyRequirement{get;set;}
        public string claimValue{get;set;}
        public string netLossAmount{get;set;}
        public string lossDescription{get;set;}
        public string obnInFavourOf{get;set;}
        public string adddress{get;set;}
        public string remarks{get;set;}
        public string csRemarks{get;set;}
        public string csCheck{get;set;}
        public string directDebit{get;set;}
        public string depsInfo{get;set;}
        public string intimationTime{get;set;}
        public string claimSubmittedDate{get;set;}
        public string source{get;set;}
        public string claimCreatedDate{get;set;}
        public String claimCreatedBy{get;set;}
        public String crn{get;set;}
        
        public String claimAcceptance{get;set;}
        public string caseName{get;set;}
        public string natureOfLoss{get;set;}
        
        public String claimRegBy{get;set;}
        public String companyOf{get;set;}
        public String lastModifiedBy{get;set;}
        public string lastModifiedDate{get;set;}
        public string assuredDeliveryDate{get;set;}
        Public list<Subwrapper> attachments = new list<Subwrapper>();
        
    }
    public class Subwrapper{
        String Body{get;set;}
        String Name{get;set;}   
    }    
    public class ResponseWrapper{
        public String requid;    //GS21003
        public String result;    //successful
        public String sErrMsg;    // 
    }
}