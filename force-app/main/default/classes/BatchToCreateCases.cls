public with sharing class BatchToCreateCases implements Database.batchable<CSVIterator.CsvRow>, Database.Stateful{
private List<Map<String,String>> data;
public Integer recordid;
public string errormsgs;
public string casetype;
public BatchToCreateCases(List<Map<String,String>> initial,String type)
{
  data= initial;
  recordid=0;
  errormsgs='';
  casetype=type;

}

  public Iterable<CSVIterator.CsvRow>  start(Database.batchableContext batchableContext)
  { 
    return new CSVIterable(data);
  }
  public void execute(Database.BatchableContext batchableContext, list<CSVIterator.CsvRow> scope)  
  {
      
    system.System.debug(scope.size());
    list<SObject> objects= new list<SObject>();
    system.debug(scope);
    id complaint = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
   // id Query = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query').getRecordTypeId();
    id service = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
    
    for(CSVIterator.CsvRow sc: scope)
    {
     system.debug(sc.tokenList);

      SObject sobjectRecord = Schema.getGlobalDescribe().get('Case').newSObject();
        
        sobjectRecord.put('Subject',sc.tokenList.get('Subject'));
        sobjectRecord.put('Origin','Bulk');
        sobjectRecord.put('Status',sc.tokenList.get('Status'));
        sobjectRecord.put('Type',sc.tokenList.get('Type'));
        sobjectRecord.put('Sub_Type__c',sc.tokenList.get('Sub_Type__c'));
        if(sc.tokenList.get('AccountId')!=null && sc.tokenList.containsKey('AccountId'))
        {
       	Account acc=new Account(Contract_Number__c=sc.tokenList.get('AccountId'));
        sobjectRecord.putSObject('Account',acc);
        }
        if(sc.tokenList.get('ContactId')!=null && sc.tokenList.containsKey('ContactId'))
        {
        Contact con=new Contact(Gati_Con_eid__c=sc.tokenList.get('ContactId'));
        sobjectRecord.putSObject('Contact',con);
        }
        
        if(casetype=='Pick Up')
        {
            sobjectRecord.put('RecordTypeId',service);
            system.debug('case type is'+casetype);
			sobjectRecord.put('Non_Pick_Up_Delivery_Reason__c',sc.tokenList.get('Non_Pick_Up_Delivery_Reason__c'));
            sobjectRecord.put('Pick_Up_Pincode__c',sc.tokenList.get('Pick_Up_Pincode__c'));
            if(sc.tokenList.get('Pickup_Date__c')!=null && sc.tokenList.get('Pickup_Date__c')!=''){
            sobjectRecord.put('Pickup_Date__c',Date.parse(sc.tokenList.get('Pickup_Date__c')));          
            }

            sobjectRecord.put('Pick_Up_Instructions__c',sc.tokenList.get('Pick_Up_Instructions__c'));
        }
        else if(casetype=='Rebooking')
        {
          system.debug('case type is'+casetype);
            sobjectRecord.put('RecordTypeId',service);
            sobjectRecord.put('Booking_Pincodes__c',sc.tokenList.get('Booking_Pincodes__c'));
            sobjectRecord.put('Booking_OU_Details__c',sc.tokenList.get('Booking_OU_Details__c'));
            sobjectRecord.put('Booking_ESS_Codes__c',sc.tokenList.get('Booking_ESS_Codes__c'));        
            sobjectRecord.put('Booking_Location_Name__c',sc.tokenList.get('Booking_Location_Name__c'));
            sobjectRecord.put('Booking_Distance__c',sc.tokenList.get('Booking_Distance__c'));
            sobjectRecord.put('Booking_Transit__c',sc.tokenList.get('Booking_Transit__c'));
        }
        else
        {
          system.debug('case type is'+casetype);
            sobjectRecord.put('RecordTypeId',complaint);
            sobjectRecord.put('Docket_Number__c',sc.tokenList.get('Booking_Transit__c'));
            sobjectRecord.put('Pick_Up_Ref_No__c',sc.tokenList.get('Booking_Transit__c'));
        }
        objects.add(sobjectRecord);
       
    }
    

    if(objects.size()>0)
    {
      system.debug(objects);
      Database.SaveResult[] sveResult = Database.insert(objects, true);
      
      
      for (Database.SaveResult sr : sveResult) {
          if (!sr.isSuccess() && recordid<11) {
          errormsgs += 'Case Record:' + sveResult[recordid].id + ', ' + sr.getErrors()[0].getMessage() + '<br/>';
          }
          recordid++;
          }
      
    }
  }
  public void finish(database.BatchableContext con){
    
errormsgs=errormsgs+'Total records Processed= '+recordid;
      if(errormsgs.length()>1)
      {
        string tempBody='';
        List<Messaging.SingleEmailMessage> lstMail=new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress limit 1];
        string username=UserInfo.getUserName();
        
        User activeUser = [Select Email,Name From User where Username = : userName limit 1];
        tempBody='Hi <b>'+activeUser.Name+'</b>,';
        tempBody+= '<br/> <br/>'+ 'Please find bulk upload results as below: <br/> <br/>';

        
        String userEmail = activeUser.Email;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
        String[] toAddresses = new String[] {'gupta.vikas9433@gmail.com',userEmail}; 
        mail.setSubject('Batch Job Completed');

        mail.setToAddresses(toAddresses); 
        mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
        tempBody+=errormsgs;
        tempBody+='<br/> <br/> Thanks and regards,<br/> Allcargogati';
        mail.setHtmlBody(tempBody);
        lstMail.add(mail);  
        Messaging.sendEmail(lstMail);
        System.debug(lstMail);

      }

  }   

}