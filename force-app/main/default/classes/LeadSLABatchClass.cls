public class LeadSLABatchClass implements database.Batchable<sObject> {
    OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName ='GATI' LIMIT 1];
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Getting all Working Leads with appropriate period as pe KEA/SME/
        if(Test.isRunningTest()){
            String query = 'SELECT Product__c,Id,name,Lead_Assigned_OU__r.SME_BDM__r.Manager.Manager.Email,Lead_Assigned_OU__r.SME_BDM__r.Manager.Email,Lead_Assigned_OU__r.Parent__r.Parent__r.KEA_NBD_Zonal_Head__r.Email,Owner.Name,Lead_Assigned_OU__c,Lead_Assigned_OU__r.KEA_NBD_Zonal_Head__r.manager.manager.email,owner.email,Working_start_Date__c,Customer_Type__c,Status,Owner.userRole.name FROM Lead' ;
            return Database.getQueryLocator(query);
        }
        else{
            
            String query = 'SELECT Product__c,Id,name,Lead_Assigned_OU__r.SME_BDM__r.Manager.Manager.Email,Lead_Assigned_OU__r.SME_BDM__r.Manager.Email,Lead_Assigned_OU__r.Parent__r.Parent__r.KEA_NBD_Zonal_Head__r.Email,Owner.Name,Lead_Assigned_OU__c,Lead_Assigned_OU__r.KEA_NBD_Zonal_Head__r.manager.manager.email,owner.email,Working_start_Date__c,Customer_Type__c,Status,Owner.userRole.name FROM Lead WHERE ((Working_start_Date__c =N_DAYS_AGO:3 AND Customer_Type__c !=\'Retail\')OR (Working_start_Date__c =N_DAYS_AGO:5 AND Customer_Type__c !=\'Retail\') OR (Working_start_Date__c =N_DAYS_AGO:1 AND Customer_Type__c =\'Retail\') OR (Working_start_Date__c =N_DAYS_AGO:12 AND Customer_Type__c =\'KEA\') OR (Working_start_Date__c =N_DAYS_AGO:7 AND Customer_Type__c =\'SME\') )AND Status=\'Working\' order by owner.name';
            return Database.getQueryLocator(query);
        }
    }
    
    
    
    public void execute(Database.BatchableContext bc, list<Lead> leadList) {
        system.debug(leadlist);
        //list<user> KEAnationalhead=[select id,name,email from user  where userrole.name=:'NATIONAL_KEA_HEAD' limit 1];
        list<user> creditnationalhead=[select id,name,email from user  where userrole.name=:'NationalCreditHead' limit 1];
        //	list<user> retailnationalhead=[select id,name,email from user  where userrole.name=:'NationalRetailHead' limit 1];
        map<Lead, string> leadVsEscalation = new Map<Lead, string>();
        String Link = Url.getOrgDomainUrl().toExternalForm() + '/lightning/r/Lead/';
        map<String,integer> emailvscount= new map<string,integer>();
        map<id, list<string>> cc = new Map<id, list<String>>();
        list<id> owners = new List<id>();
        for (Lead l : LeadList) {
            owners.add(l.ownerid);
        }
        map<id, user> usermap = new Map<id, user>(
            [
                SELECT id, name, managerid, manager.name, manager.email, manager.manager.email
                FROM user
                WHERE id IN :owners
            ]
        );
        Map<String, string> mails = new Map<string, string>();
        Map<Id,list<String>> sp=new Map<id,list<String>>();
        for (Lead l : LeadList) {
            
            string temp='';
            
            if (l.Customer_Type__c == 'Retail') {
                temp=(usermap.get(l.ownerid)?.manager?.manager.email);
                
            }
           
            else if (l.Customer_Type__c == 'MSME' || l.Customer_Type__c == 'Strategic' ) {
                if( (l.Working_start_Date__c.daysBetween(date.today()) == 3)||(L.Working_start_Date__c.daysBetween(date.today()) == 5)) {
                    temp=(usermap.get(l.ownerid)?.manager?.manager?.email);
                    
                }else if (l.Working_start_Date__c.daysBetween(date.today()) == 7) {
                    if(creditnationalhead.size()>0)
                        temp=creditnationalhead[0]?.email;
                }
            }
            
            if(temp==''|| temp==null)
            {
                temp=l.owner.email;
            }
            
            if(mails.ContainsKey(temp))
            {
                emailvscount.put(temp,emailvscount.get(temp)+1);
                string 	bodytemp='<tr><td style="border: 1px solid black">'+emailvscount.get(temp)+'</td><td style="border: 1px solid black"><a href="'+Link+l.id+'/view">'+l.name+'</a></td><td style="border: 1px solid black">'+l.owner.Name+'</td><td style="border: 1px solid black">'+L.Working_start_Date__c.daysBetween(date.today())+'</td><td  style="border: 1px solid black">'+l.Status+'</td><td  style="border: 1px solid black">'+l.Customer_Type__c+'</td><td style="border: 1px solid black">'+l.Product__c+'</td></tr>';
                
                string appendbody=mails.get(temp);
                appendbody+=bodytemp;
                mails.put(temp,appendbody);
            }
            else
            {
                emailvscount.put(temp,1);
                string 	bodytemp='<tr><td style="border: 1px solid black">'+emailvscount.get(temp)+'</td><td style="border: 1px solid black"><a href="'+Link+l.id+'/view">'+l.name+'</a></td><td style="border: 1px solid black">'+l.owner.Name+'</td><td style="border: 1px solid black">'+L.Working_start_Date__c.daysBetween(date.today())+'</td><td  style="border: 1px solid black">'+l.Status+'</td><td  style="border: 1px solid black">'+l.Customer_Type__c+'</td><td style="border: 1px solid black">'+l.Product__c+'</td></tr>';
                
                mails.put(temp,bodytemp);
            }
            
        }
        
        list<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        system.debug(mails);
        for (string l :mails.keySet() ) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            list<string> toList = new List<string>();
            string header =
                'Dear User, <br>Leads are pending at below status for more than mentioned Days,</br></br>This is for your necessary action:  </br><br>';
            email.setToAddresses(new list<String>{'noreply@gatikwe.com'});
            //email.setToAddresses(List<String> param1)
            //system.debug(new list<String>{l});
            email.setOrgWideEmailAddressId(owea.Id);
            email.setSubject('Lead Idle Alert');
            String itial =header+ '<table  style="border:1px solid black;border-collapse: collapse;"><tr style="color:white"><th colspan="7" style="border: 1px solid black;background-color:#0095b1;" >Leads</th></tr> <tr style="background-color:#0095b1;color:white" >  <th style="border: 1px solid black;">Sr. No.</th>  <th style="border: 1px solid black;">Lead</th>    <th style="border: 1px solid black;">Owner</th> <th style="border: 1px solid black;">Days</th> <th style="border: 1px solid black;">Stage</th>  <th style="border: 1px solid black;">Customer Type</th><th style="border: 1px solid black;">Product Category</	th>  </tr>' + mails.get(l) +'</table>';
            system.debug(mails.get(l));
            email.setHtmlBody(itial);
            emailList.add(email);
        }
        if (emailList.size() > 0) {
            List<Messaging.SendEmailResult> Result = Messaging.sendEmail(emailList);
            system.debug(result);
        }
    }
    public void finish(Database.BatchableContext bc) {
    }
}