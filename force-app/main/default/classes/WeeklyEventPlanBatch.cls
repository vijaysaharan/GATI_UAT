public class WeeklyEventPlanBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, Visit_Start_Date__c,Visit_End_Date__c,Call_Type__c,Customer_Code__r.Name, Lead__r.Name,Sub_Type__c, Owner.Email, Owner.FirstName, Owner.LastName FROM Customer_Connect__c WHERE Visit_Start_Date__c=THIS_WEEK ORDER BY Visit_Start_Date__c';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Customer_Connect__c> listOfCustomerConnect){
        Set<String> emailIds = new Set<String>();
        Map<String, String> nameWithEmail = new Map<String,String>();
        for(Customer_Connect__c cc: listOfCustomerConnect){
            if(cc.Owner.Email!=null){
                emailIds.add(cc.Owner.Email);
            }
            if(cc.Owner.FirstName!=null && cc.Owner.LastName!=null){
                nameWithEmail.put(cc.Owner.Email, cc.Owner.FirstName+' '+cc.Owner.LastName);
            }else{
                 nameWithEmail.put(cc.Owner.Email,cc.Owner.LastName);
            }
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@gatikwe.com'];
        if(!emailIds.isEmpty()){
            for(String emailSet : emailIds){
                String UserName='';
                List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                List<String> sendTo = new List<String>();
                sendTo.add(emailSet);
                mail.setToAddresses(sendTo);        
                //mail.setSenderDisplayName('Weekly Plan Report');
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
                
                String body='Dear '+nameWithEmail.get(emailSet);
                body+='<br/> Your Weekly Report of this week given below.<br/>';
                body += '<table style="border:1px solid black;">';
                body+= '<tr >';
                body+= '<th style="border:1px solid black;">Customer Connect</th>';
                body+= '<th style="border:1px solid black;">Account/Lead</th>';
                body+= '<th style="border:1px solid black;">Call Type</th>';
                body+= '<th style="border:1px solid black;">Sub Type</th>';
                body+= '<th style="border:1px solid black;">Visit Start Date</th>';
                body+= '<th style="border:1px solid black;">Visit End Date</th>';
                body+= '</tr>';
                for(Customer_Connect__c fillTable : listOfCustomerConnect){
                    if(fillTable.Owner.Email == emailSet){
                        if(fillTable.Owner.FirstName!=null && fillTable.Owner.LastName!=null){
                            UserName = fillTable.Owner.FirstName+' '+fillTable.Owner.LastName;
                        }else{
                            UserName =fillTable.Owner.LastName;
                        }
                        body+='<tr>';
                        body+='<td style="border:1px solid black;">'+fillTable.Name+'</td>';
                        if(fillTable.Customer_Code__r.Name!=null){
                            body+='<td style="border:1px solid black;">'+fillTable.Customer_Code__r.Name+'</td>';
                        }else{
                            body+='<td style="border:1px solid black;">'+fillTable.Lead__r.Name+'</td>';
                        }
                        body+='<td style="border:1px solid black;">'+fillTable.Call_Type__c+'</td>';
                        body+='<td style="border:1px solid black;">'+fillTable.Sub_Type__c+'</td>';
                        body+='<td style="border:1px solid black;">'+fillTable.Visit_Start_Date__c+'</td>';
                        body+='<td style="border:1px solid black;">'+fillTable.Visit_End_Date__c+'</td>';
                        body+='</tr>';
                    }
                }
                
                body += '</table>';
                mail.setHtmlBody(body);
                
                mail.setSubject('Weekly Plan Report');
                mails.add(mail);
                
                Messaging.sendEmail(mails);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}