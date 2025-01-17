public without sharing class ProspectivePickupGetRates_Outbound {
    @AuraEnabled(cacheable=true)
    public static List<Map<String,string>> proCallOut(String caseid){  
        prospectWrapper reqBody = new prospectWrapper();
        List<Map<String,string>> respList =  new List<Map<String,string>>();
        Integration_Log__c Il;
        for (Case case1: [Select Pick_Up_Pincode__r.Name,Account.GATI_Customer_Code__c, Pick_Up_Pincode__r.Location__c,Pick_Up_Pincode__r.Distance__c,
                          Pick_Up_Pincode__r.ESS_Category__c,Pick_Up_Pincode__r.Parent__r.Name,Volume__c,Unit_of_Measurement__c,COD__c,Delivery_Pincode_Location__r.ESS_Category__c,
                          Pick_Up_Pincode__r.REF_Code__c,Delivery_Pincode_Location__r.REF_Code__c,
                          Delivery_Pincode_Location__r.Name,Delivery_Pincode_Location__r.Location__c,Delivery_Pincode_Location__r.Distance__c,
                          Delivery_Pincode_Location__r.Parent__r.Name ,Actual_Weight__c,
                          No_Of_Packages__c,Decl_Cargo_value__c,COD_Amt__c,Created_Date__c,Cargo_Purpose__c,
                          Warehouse_Delivery__c,Value__c,Risk_Coverage_Prospect__c,
                          Booking_Basis__c,Exp_Bkg_Dt__c from Case where ID =:caseid limit 1])
        {
            reqBody.custCode=case1.Account.GATI_Customer_Code__c!=null?case1.Account.GATI_Customer_Code__c:'99999';
            reqBody.bkgPincode = case1.Pick_Up_Pincode__r.Name;
            //reqBody.bkgLocation = case1.Pick_Up_Pincode__r.Location__c;
            reqBody.bkgOU = case1.Pick_Up_Pincode__r.Parent__r.Name;
            reqBody.dlyPincode = case1.Delivery_Pincode_Location__r.Name;
            //reqBody.dlyLocation = case1.Delivery_Pincode_Location__r.Location__c;
            reqBody.dlyOU = case1.Delivery_Pincode_Location__r.Parent__r.Name;                   
            reqBody.actWt = string.valueof(case1.Actual_Weight__c);
            reqBody.noOfPkgs = case1.No_Of_Packages__c;
            reqBody.declCargoVal = case1.Decl_Cargo_value__c>0?case1.Decl_Cargo_value__c:0;
            reqBody.totVol=String.valueOf(case1.Volume__c);
            reqBody.volUom=case1.Unit_of_Measurement__c;
            if(case1.Value__c!=null){
            reqBody.codAmt = case1.Value__c.contains('COD/DOD')?string.valueOf(case1.COD_Amt__c>0?case1.COD_Amt__c:0):'';
            }else{
                reqBody.codAmt = '0';
               
            }
             reqBody.codInFavour=case1.COD__c!=null?case1.COD__c:'';
            //reqBody.cargoPurpose = case1.Cargo_Purpose__c;
            reqBody.bkgOuEssDist = case1.Pick_Up_Pincode__r.ESS_Category__c=='ESS1'||case1.Pick_Up_Pincode__r.ESS_Category__c =='ESS2'?String.ValueOf(case1.Pick_Up_Pincode__r.Distance__c):'';
            reqBody.dlyOuEssDist =case1.Delivery_Pincode_Location__r.ESS_Category__c=='ESS1'||case1.Pick_Up_Pincode__r.ESS_Category__c =='ESS2'? String.ValueOf(case1.Delivery_Pincode_Location__r.Distance__c):'';
            reqBody.bkgOuEss = case1.Pick_Up_Pincode__r.ESS_Category__c=='ESS1'||case1.Pick_Up_Pincode__r.ESS_Category__c =='ESS2'?String.ValueOf(case1.Pick_Up_Pincode__r.REF_Code__c):'';
            reqBody.dlyOuEss = case1.Delivery_Pincode_Location__r.ESS_Category__c=='ESS1'||case1.Pick_Up_Pincode__r.ESS_Category__c =='ESS2'?String.ValueOf(case1.Delivery_Pincode_Location__r.REF_Code__c):'';
            reqBody.gdwDlyFlag = case1.Warehouse_Delivery__c;
            reqBody.gwdDly = case1.Warehouse_Delivery__c;
            //reqBody.valueAddedService = case1.Value__c;
            //reqBody.callTime = case1.Created_Date__c;   
            reqBody.riskCoverage = case1.Risk_Coverage_Prospect__c;
            reqBody.bkgBasis = case1.Booking_Basis__c; 
            reqBody.requestedBy=[Select Staff_Code__c from User where Id=:userinfo.getuserId()].Staff_Code__c;
            //reqBody.expectedBookingDate = case1.Exp_Bkg_Dt__c;
            reqBody.studentExpFlag = case1.Cargo_Purpose__c=='Student Express'?'Y':'N';
            reqBody.excessBagFlag=case1.Cargo_Purpose__c=='Excess Baggage'?'Y':'N';
            reqBody.retailFlag=case1.Cargo_Purpose__c=='Personal'?'Y':'N';
            reqBody.domIntl='D';
            if(case1.Value__c!=null){
            reqBody.hpod=case1.Value__c.contains('POD Hard Copy')?'Y':'N';
            reqBody.ackDlyChalan=case1.Value__c.contains('Personal')?'Y':'N';
            reqBody.CodDod=case1.Value__c.contains('COD/DOD')?'Y':'N'; 
            reqBody.sundayDly=case1.Value__c.contains('Sunday Delivery')?'Y':'N'; 
            }
            system.debug(reqBody);
        }                              
        Http http = new Http();              
        HttpRequest req = new HttpRequest();
        String AuthParams = API_credential__mdt.getInstance('ProspectivePickup').Other_Auth_Parameter__c;
        String[] AuthParamsSplitted = AuthParams.split('\\|');
        for (String Authpar:AuthParamsSplitted)
        {
            String[] nameValue= Authpar.split('\\:');
            req.setHeader(nameValue[0], nameValue[1]);                   
        }
        req.setHeader('Content-Type','application/json');
        req.setHeader('accept','application/json');
        req.setEndpoint(API_credential__mdt.getInstance('ProspectivePickup').Endpoint__c);
        //string body='{"requestedBy":"kar_93961","bkgPincode":"500084","dlyPincode":"600024","bkgOU":"HYDC","bkgOuEss":"","bkgOuEssDist":"","dlyOU":"MAAW","dlyOuEss":"","dlyOuEssDist":"","custCode":"99999","gdwDlyFlag":"N","actWt":"20","noOfPkgs":"1","declCargoVal":"4999","bkgBasis":"1","codInFavour":"","codAmt":"","riskCoverage":"OR","studentExpFlag":"N","excessBagFlag":"N","retailFlag":"Y","domIntl":"D","sundayDly":"N","gwdDly":"N","hpod":"N","ackDlyChalan":"N","CodDod":"N","totVol":"500","volUom": "CM"}';
        req.setBody(JSON.serialize(reqBody));
        // req.setBody(body);
        req.setMethod('POST');
        System.debug('Request body '+req);
        
        try{
            
            HttpResponse result= http.send(req);
            System.debug('result.getBody()=='+result.getBody());
            insertLogs(caseid,JSON.serialize(reqBody),result.getBody());
            if(result.getstatuscode()==200)
            {
                Map <String,Object> respObject =  (Map<String, Object>)JSON.deserializeUntyped( result.getBody());
                
                if (respObject.get('result')=='successful')
                {
                    //respList = (List<RateDetailsWrapper>)respObject.get('response');
                    List<Object> listobj = (List<Object>)respObject.get('response');
                    System.debug('result.respBody()=='+listobj);
                    for (Object a:listobj)
                    {
                        //RateDetailsWrapper rw = (RateDetailsWrapper)a;
                        Map<String,Object> b= (Map<String,Object>)a;
                        System.debug(b.get('PROD_CODE'));
                        Map<String,String> rateDetails = new Map<String,String>();                     
                        rateDetails.put('PROD_CODE',(String)b.get('PROD_CODE'));
                        rateDetails.put('PROD_DESC',(String)b.get('PROD_DESC'));
                        rateDetails.put('CHARGE_DESC',(String)b.get('CHARGE_DESC'));
                        rateDetails.put('CHARGE_CODE',(String)b.get('CHARGE_CODE'));
                        rateDetails.put('CHARGE_AMT',(String)b.get('CHARGE_AMT'));  
                        rateDetails.put('CHARGED_WT',(String)b.get('CHARGED_WT')); 
                        rateDetails.put('TRANSIT_DAYS',(String)b.get('TRANSIT_DAYS')); 
                        
                        respList.add(rateDetails);
                    }
                }else{
                    // AuraHandledException e = new AuraHandledException(respObject.get('sErrMsg'));
                    //throw e;
                    throw new CalloutException('Failed to get Details from GEMS: '+respObject.get('sErrMsg'));
                }
            }
            
        }
        catch(Exception e)
        {	system.debug(e.getMessage());
         throw new AuraHandledException(e.getMessage());
        }
        return respList;    
        
    }
    @future
    public static void insertLogs(String rid, String inp,String op){
        try{
            Integration_Log__c ic = new Integration_Log__c();
            ic.Component_Name__c='ProspectivePickupGetRates_Outbound';
            ic.eRecordID__c=rid;
            ic.Inbound_JSON__c=op;
            ic.Outbound_JSON__c=inp;
            insert ic;
        }catch(Exception exe)
        {
            
        }        
        
    }
    public class prospectWrapper{
        public String custCode{get;set;}//added
        public string bkgPincode{get;set;}
        //public String bkgLocation{get;set;}
        public String bkgOU{get;set;}
        public String dlyPincode{get;set;}
        //public String dlyLocation{get;set;}
        public String dlyOU{get;set;}
        public String gdwDlyFlag{get;set;} //not present
        public String actWt{get;set;}
        public decimal noOfPkgs{get;set;}
        public decimal declCargoVal{get;set;}
        public String riskCoverage{get;set;}
        public string codInFavour{get;set;} //yet to clarify
        public String codAmt{get;set;}
        public String bkgBasis{get;set;}
        public DateTime callTime{get;set;}
        //public String cargoPurpose{get;set;}
        public String bkgOuEss{get;set;}//added
        public String dlyOuEss{get;set;}//added
        public String bkgOuEssDist {get;set;}
        public String dlyOuEssDist{get;set;}
        //public String valueAddedService{get;set;}
        public Date expectedBookingDate{get;set;}
        public String requestedBy{get;set;}
        public String totVol{get;set;}
        public String volUom{get;set;}
        public String studentExpFlag = 'N';
        public String excessBagFlag='N';
        public String retailFlag='N';
        public String domIntl='N';
        public String gwdDly='N';
        public String hpod='N';
        public String ackDlyChalan='N';
        public String CodDod='N';
        public String sundayDly='N';
        //    public packageWrapper packageobj;
    }
    public class RateDetailsWrapper{
        public string PROD_CODE{get;set;}
        public string PROD_DESC{get;set;}
        public string CHARGE_DESC{get;set;}
        public string CHARGE_CODE{get;set;}
        public string CHARGE_AMT{get;set;}
        public string CHARGED_WT{get;set;}
        public string TRANSIT_DAYS{get;set;}
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String,string>> proCallOut2(List<Map<String,string>> respList){  
        List<Map<String,string>> respList2 =  new List<Map<String,string>>();
        Map<String,String> rateDetails2 = new Map<String,String>(); 
        Map<String,String> rateDetails3 = new Map<String,String>(); 
        Decimal surface = 0,air = 0, gst1 = 0,gst2 = 0;
        String chd_wt1, tran_days1,chd_wt2, tran_days2;
        for(Map<String,string> b:respList )
        {
            if(b.get('PROD_CODE')=='1')
            {
                surface = surface + Decimal.ValueOf(b.get('CHARGE_AMT'));
                chd_wt1 = b.get('CHARGED_WT');
                tran_days1 = b.get('TRANSIT_DAYS');
            }
            else
            {
                air = air + Decimal.ValueOf(b.get('CHARGE_AMT'));
                chd_wt2 = b.get('CHARGED_WT');
                tran_days2 = b.get('TRANSIT_DAYS');
            }
        }
        rateDetails2.put('PROD_CODE',String.ValueOf('1'));
        rateDetails2.put('PROD_DESC',String.ValueOf('Surface Express'));
        rateDetails2.put('CHARGED_WT',String.ValueOf(chd_wt1));
        rateDetails2.put('TRANSIT_DAYS',String.ValueOf(tran_days1));
        rateDetails2.put('CHARGE_AMT',String.ValueOf(surface));
        gst1 = (surface * 118)/100;
        rateDetails2.put('ADD GST',String.ValueOf(gst1));			
        rateDetails3.put('PROD_CODE',String.ValueOf('2'));
        rateDetails3.put('PROD_DESC',String.ValueOf('Air Express'));
        rateDetails3.put('CHARGED_WT',String.ValueOf(chd_wt2));
        rateDetails3.put('TRANSIT_DAYS',String.ValueOf(tran_days2));
        rateDetails3.put('CHARGE_AMT',String.ValueOf(air)); 
        gst2 = (air * 118)/100;			
        rateDetails3.put('ADD GST',String.ValueOf(gst2));
        respList2.add(rateDetails2);
        respList2.add(rateDetails3);
        return respList2;
    }
}