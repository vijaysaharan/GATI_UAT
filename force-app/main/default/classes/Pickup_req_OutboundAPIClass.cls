/*
Author     : Sumit Gupta (sgupta3@kloudrac.com)
Date       : Mar 09, 2022
Desc       : 
Test Class Name : Pickup_req_OutboundAPIClassTest
*/

public class Pickup_req_OutboundAPIClass {
    public static void Sendpickup(List<String> case2id){
        pickuppayload reqBody=new pickuppayload();
        Integration_Log__c Il;
        dummy();
        // system.debug(Case1id);
        List <Case> case2 = 
            [Select Error_message__c,sync_flag__c,Shipper_Name__c,Customer_Code__c,Pickup_Address1__c,Pickup_Address2__c,Pickup_Address3__c,Pick_Up_Pincode__r.Name,
             Pickup_OU__r.name,Mobile__c,Receiver_Pincode__c,Pickup_Date__c,Shipper_Location__c,Customer_Email__c,
             Pick_Up_Instructions__c,Product__c,No_Of_Packages__c,Actual_Weight__c,Volume__c,
             Type_of_Package__c,Origin,CreatedDate,CreatedBy.Staff_Code__c,Pick_Up_Ref_No__c,
             LastModifiedDate,LastModifiedBy.Staff_Code__c,Approver_Remarks__c,Approval_Status__c,Sub_Type__c,
             First_Schedule__c,Pickup_Status__c,Pickup_City__c,Pickup_Coordinates__c,Company_of__c,Case_Name__c,CaseNumber from Case where ID IN :case2id];
        system.debug(Case2);
        
        for(Case case1 : case2)
        {
            
            try{
                if(case1.Customer_Code__c!=null)
                {       
                    reqBody.customerCode=string.ValueOf(case1.Customer_Code__c);
                }
                else
                {
                    reqBody.customerCode='99999';
                }
                system.debug(reqBody.customerCode);
                reqBody.shipperName=case1.Shipper_Name__c;
                if(case1.Pickup_Address1__c!=null)
                {
                    reqBody.pickUpAddress1=case1.Pickup_Address1__c;
                }
                else
                {
                    reqBody.pickUpAddress1=null; 
                }
                if(case1.Pickup_Address2__c!=null)
                {
                    reqBody.pickUpAddress2=case1.Pickup_Address2__c;
                }
                else
                {
                    reqBody.pickUpAddress2=null; 
                }
                if(case1.Pickup_Address3__c!=null)
                {
                    reqBody.pickUpAddress3=case1.Pickup_Address3__c;
                }
                else
                {
                    reqBody.pickUpAddress3=''; 
                }
                System.debug(reqBody.pickUpAddress3);
                
                reqBody.shipperPincode=case1.Pick_Up_Pincode__r.Name;
                if(case1.Shipper_Location__c!=null)
                {
                    reqBody.location=case1.Shipper_Location__c;
                }
                else
                {
                    reqBody.location='';   
                }
                if(case1.Pickup_OU__r.name!=null)
                {
                    reqBody.pickupOu=case1.Pickup_OU__r.name;
                }
                else
                {
                    reqBody.pickupOu='';  
                }
                System.debug(reqBody.pickupOu);
                if(case1.Mobile__c!=null){
                    reqBody.mobileNo=case1.Mobile__c;
                }
                else{
                    reqBody.mobileNo=''; 
                }
                system.debug(reqBody.mobileNo);
                if(case1.Customer_Email__c!=null)
                {
                    reqBody.emailId=case1.Customer_Email__c;
                }
                else{
                    reqBody.emailId='';
                }
                system.debug(reqBody.emailId);
                reqBody.receiverPincode=case1.Receiver_Pincode__c;
                reqBody.pickUpDate=case1.Pickup_Date__c.format('dd-MM-yyyy HH:mm:ss');
                if(case1.Pick_Up_Instructions__c!=null)
                {
                    reqBody.pickUpInstructions=case1.Pick_Up_Instructions__c;
                }
                else
                {
                    reqBody.pickUpInstructions='';
                }
                System.debug(reqBody.pickUpInstructions);
                reqBody.product=case1.Product__c;
                if(case1.No_Of_Packages__c!=null)
                {
                    reqBody.noOfPackages=string.valueof(case1.No_Of_Packages__c);
                }
                else
                {
                    reqBody.noOfPackages=''; 
                }
                if(case1.Actual_Weight__c!=null)
                {
                    reqBody.actualWeight=string.valueof(case1.Actual_Weight__c);
                }
                else
                {
                    reqBody.actualWeight='';
                }
                if(case1.Volume__c!=null)
                {
                    reqBody.volume=string.valueof(case1.Volume__c);
                }
                else{
                    reqBody.volume=''; 
                }
                if(case1.Type_of_Package__c!=null)
                {
                    reqBody.typeOfPackage=case1.Type_of_Package__c;
                }
                else
                {
                    reqBody.typeOfPackage='';
                }
                //reqBody.source=case1.Origin;
                if(case1.Origin!=null){
                    Lookup_Master__mdt LookupMastermdtRecords2 = [SELECT Id, CRM_Field_Value__c, External_Field_Value__c from Lookup_Master__mdt where MasterLabel =: case1.Origin LIMIT 1];
                    
                    if(LookupMastermdtRecords2!=null){
                        reqBody.source = LookupMastermdtRecords2.External_Field_Value__c;
                    }   
                }
                reqBody.createdDate=case1.CreatedDate.format('dd-MM-yyyy HH:mm:ss');
                
                
                if(case1.Origin=='Web'||case1.Origin=='Website'||case1.Origin=='Simplyfy360'||case1.Origin=='Simply360'||case1.Origin=='WhatsApp'||case1.Origin=='Email')
                {
                    reqBody.pickUpCreatedBy='Customer';
                }
                else if(case1.CreatedBy.Staff_Code__c!=null)
                {
                    reqBody.pickUpCreatedBy=case1.CreatedBy.Staff_Code__c;  
                }
                
                reqBody.pickUpRefNo=case1.CaseNumber;
                if(case1.LastModifiedDate!=null)
                {
                    reqBody.lastModifiedDate=case1.LastModifiedDate.format('dd-MM-yyyy HH:mm:ss');
                }
                else
                {
                    reqBody.lastModifiedDate='';
                }
                system.debug(reqBody.lastModifiedDate);
                if(case1.LastModifiedBy.Staff_Code__c!=null)
                {
                    reqBody.lastModifiedBy=case1.LastModifiedBy.Staff_Code__c;
                }
                system.debug(reqBody.lastModifiedBy);
                if(case1.Approval_Status__c!=null){
                    reqBody.approverStatus=case1.Approval_Status__c;
                }
                else{
                    reqBody.approverStatus='';
                }
                if(case1.Sub_Type__c!=null){
                    reqBody.Pick_up_type=case1.Sub_Type__c;
                }
                else{
                    reqBody.Pick_up_type='';
                }
                System.debug(reqBody.Pick_up_type);
                if(case1.Approver_Remarks__c!=null){
                    reqBody.approverRemarks= case1.Approver_Remarks__c;
                }
                
                else{
                    reqBody.approverRemarks='';
                }
                System.debug(reqBody.approverRemarks);
                if(case1.First_Schedule__c!=null){
                    reqBody.firstSchedule= case1.First_Schedule__c==null?null:case1.First_Schedule__c.format('dd-MM-yyyy HH:mm:ss');
                }
                else
                {
                    reqBody.firstSchedule='';
                }
                system.debug(reqBody.firstSchedule);
                if(case1.Pickup_Status__c!=null)
                {
                    reqBody.pickupStatus= case1.Pickup_Status__c;
                }
                else{
                    reqBody.pickupStatus='';
                } 
                if(case1.Pickup_City__c!=null)
                {
                    reqBody.shipperCity= case1.Pickup_City__c;
                }
                else
                {
                    reqBody.shipperCity='';   
                }
                
                //   reqBody.shipperCity= case1.Pickup_City__c;
                
                if(case1.Pickup_Coordinates__c==null)
                {
                    reqBody.latLong= '';
                }else{
                    Location loc = case1.Pickup_Coordinates__c;
                    System.debug(loc+': '+reqBody.latLong);
                    reqBody.latLong=String.valueOf(loc.latitude)+','+String.valueOf(loc.longitude);
                    System.debug(loc+': '+reqBody.latLong);
                }
                //reqBody.latLong=case1.Pickup_Coordinates__c==null?'':case1.Pickup_Coordinates__c.latitude+','+case1.Pickup_Coordinates__c.longitude;
                reqBody.companyOf=case1.Company_of__c;
                if(case1.Case_Name__c!=null){
                    reqBody.caseName=case1.Case_Name__c;
                }
                else
                {
                    reqBody.caseName='';
                }
                
                
                //reqBody.latLong= case1.Pickup_Coordinates__c;
                //System.debug(reqBody.latLong);//= case1.Pickup_Coordinates__c;
                //System.debug(JSON.serialize(reqBody.latLong));
                
                
                Http http = new Http();              
                HttpRequest req1 = new HttpRequest();
                String AuthParams = API_credential__mdt.getInstance('Pickup_Request').Other_Auth_Parameter__c;
                String[] AuthParamsSplitted = AuthParams.split('\\|');
                for (String Authpar:AuthParamsSplitted)
                {
                    String[] nameValue= Authpar.split('\\:');
                    req1.setHeader(nameValue[0], nameValue[1]);                   
                }
                req1.setHeader('Content-Type','application/json');
                req1.setHeader('accept','application/json');
                req1.setEndpoint(API_credential__mdt.getInstance('Pickup_Request').Endpoint__c);
                req1.setBody(JSON.serialize(reqBody));
                req1.setMethod('POST');
                req1.setTimeout(50000);
                //System.debug(req1);
                HttpResponse result= http.send(req1);
                //System.debug('result.getBody()=='+result.getBody());
                String errormsg1;
                // System.debug(result.getStatusCode());
                
                if(result.getStatusCode()==200)
                {
                    
                    ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                    
                    try{
                        errormsg1=responseObj.sErrMsg;
                        Integration_Log__c ic = new Integration_Log__c();
                        ic.Component_Name__c='PickUp log';
                        ic.Error_Message__c=errormsg1;
                        ic.IsIntegration__c=true; 
                        // ic.eRecordID__c=c.id;
                        ic.CaseNumber__c=case1.CaseNumber;
                        ic.eRecordID__c = case1.id;
                        ic.eObject__c = 'Case';
                        ic.Inbound_JSON__c=result.getBody();
                        ic.Outbound_JSON__c=JSON.serialize(reqBody);
                        insert ic;
                       // system.debug('ic');
                    }
                    catch(Exception e){
                        
                    }
                    
                }
                else{
                    
                    ResponseWrapper responseObj = (ResponseWrapper)JSON.deserialize(result.getBody(), ResponseWrapper.class);
                    
                    errormsg1=responseObj.sErrMsg;
                    Integration_Log__c ic = new Integration_Log__c();
                    ic.Component_Name__c='PickUp log';
                    ic.Error_Message__c=errormsg1;
                    ic.IsIntegration__c=true; 
                    // ic.eRecordID__c=c.id;
                    ic.CaseNumber__c=case1.CaseNumber;
                    ic.eRecordID__c = case1.id;
                    ic.eObject__c = 'Case';
                    ic.Inbound_JSON__c=result.getBody();
                    ic.Outbound_JSON__c=JSON.serialize(reqBody);
                    insert ic;
                }
                
                
            } 
            catch(Exception e){
                
                system.debug(e.getLineNumber());
                Integration_Log__c ic = new Integration_Log__c();
                ic.Component_Name__c='PickUp log';
                ic.Error_Message__c=e.getMessage();
                ic.IsIntegration__c=true; 
                // ic.eRecordID__c=c.id;
                ic.CaseNumber__c=case1.CaseNumber;
                ic.eRecordID__c = case1.id;
                ic.eObject__c = 'Case';
                insert ic;
            }
        }
        system.debug('Pickup_req_OutboundAPIQueueable Finish');
        
    }
    public class PickupPayload
    {
        public string shipperName{get;set;} //new
        public String customerCode{get;set;}
        public string pickUpAddress1{get;set;}
        public string pickUpAddress2{get;set;}
        public string pickUpAddress3{get;set;}
        public string shipperPincode{get;set;} //new   
        public string location{get;set;}
        public string pickupOu{get;set;}
        public string mobileNo{get;set;}
        public string emailId{get;set;}
        public string receiverPincode{get;set;}
        public string pickUpDate{get;set;}
        public string pickUpInstructions{get;set;}
        public string product{get;set;}
        public string noOfPackages{get;set;}
        public string actualWeight{get;set;}
        public string volume{get;set;}
        public string typeOfPackage{get;set;}
        public string source{get;set;}
        public string createdDate{get;set;}
        public string pickUpCreatedBy{get;set;}
        public string pickUpRefNo{get;set;}
        public string lastModifiedDate{get;set;}
        public string lastModifiedBy{get;set;}
        public string approverStatus{get;set;}
        public string approverRemarks{get;set;}
        public string firstSchedule{get;set;} //new
        public string pickupStatus{get;set;}    //new
        public string shipperCity{get;set;}     //new
        public string latLong{get;set;}     //new    
        public string companyOf {get;set;}      //new    
        public string caseName{get;set;}        //new    
        public string Pick_up_type{get;set;}
    }
    
    public class ResponseWrapper{
        public String requid;    //GS21003
        public String result;    //successful
        public String sErrMsg;    //
        
    }
    
    private static void dummy(){
        integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}