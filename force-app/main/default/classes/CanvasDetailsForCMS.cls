public without sharing class CanvasDetailsForCMS {
    @AuraEnabled
    Public static CanvasParametersCMS getData(String recId,String CanvasName,String objectName)
    {
		CanvasParametersCMS cp = new CanvasParametersCMS(); 
		CanvasParameter__mdt canvasParam = CanvasParameter__mdt.getInstance(CanvasName);
        System.debug('in Class');
        User userinfo = [SELECT ADID__c  FROM User where Id=:Userinfo.getUserId()];
        cp.puser=userinfo.ADID__c;
        cp.requid = canvasParam.requid__c;
        cp.authorization=canvasParam.authorization__c;       
        if (String.isBlank(canvasParam.action__c))
        	{cp.action=null;   
        }else {cp.action=canvasParam.action__c;}		
        if (String.isBlank(canvasParam.p1__c))
       		{cp.p1=null;   
        }else {cp.p1=canvasParam.p1__c;}
        if (String.isBlank(canvasParam.p2__c))
       		{cp.p2=null;   
        }else {cp.p2=canvasParam.p2__c;}
        if (String.isBlank(canvasParam.p3__c))
        	{cp.p3=null;   
        }else {cp.p3=canvasParam.p3__c;}   
		system.debug(objectName+' '+recId);
		if(objectName=='Account' && recId!=null && recId!='' )	
        {
         	Account act = [Select GATI_Company_Code__c,
                           Contract_Number__c ,
                           Associated_OU__r.Name,
                           Version__c
                          FROM Account Where Id=:recId];
                cp.cid = act.GATI_Company_Code__c;
                cp.p1 = act.Contract_Number__c;
                cp.p2 = String.valueOf(act.Version__c);	
            	cp.p3= act.Associated_OU__r.Name;
            	cp.p4 = act.Id;
            	cp.action = setTransactionType('AddCustomer');	
        }
		if(objectName=='Opportunity' && recId!=null && recId!='' )
		{
            Opportunity opty = [SELECT Account.GATI_Company_Code__c,
                                Opportunity_Type_Contract__c,
                                    Account.Contract_Number__c ,
                                Account.Version__c,
                                (Select Test_LOF_number__c, 
										AmendedVersion__c
										FROM Quotes Order by CreatedDate DESC limit 1)
                                From Opportunity
                                Where Id=:recId];
            if (opty.Quotes.isEmpty())
            {
                cp.cid = opty.Account.GATI_Company_Code__c;
                cp.p1 = opty.Account.Contract_Number__c;
                cp.p2 = String.valueOf(opty.Account.Version__c);	
            }else{
                cp.cid = opty.Account.GATI_Company_Code__c;
                cp.p1 = opty.Quotes[0].Test_LOF_number__c;
                cp.p2 = String.valueOf(opty.Quotes[0].AmendedVersion__c);	
            }
				cp.p3= opty.Id;
				cp.p4 = opty.AccountId;	
          		
				cp.action =canvasParam.action__c=='EDITROF'?'EDITROF': setTransactionType(opty.Opportunity_Type_Contract__c);	
            
		}else if(objectName=='Quote' && recId!=null && recId!='')
		{
			Quote qt = [Select Test_LOF_number__c, 
						AmendedVersion__c, 
						Account.GATI_Company_Code__c,
                        AccountId,
                        OpportunityId,
                        Opportunity.Opportunity_Type_Contract__c
						FROM Quote
						Where Id=:recId];
			cp.cid = qt.Account.GATI_Company_Code__c;
            cp.p1 = qt.Test_LOF_number__c;
			cp.p2 = String.valueOf(qt.AmendedVersion__c);				
            cp.p3 = qt.OpportunityId;
            cp.p4 = qt.AccountId;
            cp.action = setTransactionType(qt.Opportunity.Opportunity_Type_Contract__c);
		}else if(objectName=='Activity' && recId!=null && recId!='')
		{
            Task tsk =[SELECT WhatId,What.Type From Task where Id=:recId];
            if(tsk.What.Type!='Quote')
            {
                throw new AuraHandledException('Approval is only available for LOF and Contract');
            }
			Quote qt = [Select Test_LOF_number__c, 
						AmendedVersion__c, 
						Account.GATI_Company_Code__c,
                        Account.Associated_OU__r.Name,
                        AccountId,
                        OpportunityId,
                        Opportunity.Opportunity_Type_Contract__c
						FROM Quote
						Where Id=:tsk.WhatId];
			cp.cid = qt.Account.GATI_Company_Code__c;
            cp.p1 = qt.Test_LOF_number__c;
			cp.p2 = String.valueOf(qt.AmendedVersion__c);				
            cp.p3 = qt.OpportunityId;
            cp.p4 = qt.AccountId;
            cp.action = setTransactionType('Approval');
            cp.p5=qt.Account.Associated_OU__r.Name;
		}
        return cp;
        
    }
    
     private static string setTransactionType(String transType)
     {	
         switch on transType{
             when 'New Contract' {return 'EDIT';}
             when 'Contract Renewal' {return 'RENEWAL';}
			 when 'AddCustomer' {return 'ADD CUSTOMER';}
			 when 'Approval' {return 'APPROVAL';}
             when else{ return 'AMEND';}
         }
     }    
    
	public class CanvasParametersCMS{
			@AuraEnabled
			public String puser{get;set;}
			@AuraEnabled
			public String requid{get;set;}  
			@AuraEnabled
			public String authorization{get;set;}   
			@AuraEnabled
			public String action{get;set;}  
			@AuraEnabled
			public String cid{get;set;}			
			@AuraEnabled
			public String p1{get;set;}  
			@AuraEnabled
			public String p2{get;set;}  
			@AuraEnabled
			public String p3{get;set;}  
			@AuraEnabled
			public String p4{get;set;}  
			@AuraEnabled
			public String p5{get;set;}   
			@AuraEnabled
			public String p6{get;set;} 		
	}
}