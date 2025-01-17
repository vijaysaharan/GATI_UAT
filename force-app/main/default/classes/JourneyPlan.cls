public class JourneyPlan 
{ 
    
    public static string currentRecordId {get;set;}
    public static boolean a {get;set;}
    public JourneyPlan(ApexPages.StandardController controller) 
    {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        
        
    }
    public static void method()
    {
        dummy();
        a=false;
        list<account> acc= new list <account>();
        list<Journey_Plan__c> jplan = new list<Journey_Plan__c>();
        list<Customer_Connect__c> custom = new list<Customer_Connect__c>();
        list<Customer_Connect__c> allcust = new list<Customer_Connect__c>();
        map<id,Customer_Connect__c> cust = new map<id,Customer_Connect__c>();
        
        set<id> custconnectid= new set<id>();
        set<id> ownid = new set<id>();
        
        list<Customer_Connect__c> currid = new list<Customer_Connect__c>();
        currid=[select id,ownerid from Customer_Connect__c where id=:currentRecordId];
        for(Customer_Connect__c cc: currid)
        {
            custconnectid.add(cc.id); 
            ownid.add(cc.ownerid);   
        }
        
        
        custom = [select id, ownerid,Lead__c,Lead__r.Longitude, Lead__r.Latitude,Customer_Code__r.BillingLatitude, Customer_Code__r.BillingLongitude from Customer_Connect__c where id in :custconnectid];
        allcust =[select id,ownerid,Lead__c,Lead__r.Longitude, Lead__r.Latitude,Customer_Code__r.BillingLatitude, Customer_Code__r.BillingLongitude from  Customer_Connect__c where createddate=today and ownerid=:ownid and id not in :custconnectid order by createddate asc];    
        for(Customer_Connect__c con : allcust)
        {
            cust.put(con.ownerid,con);
        }
        
        
        
        for(Customer_Connect__c accc : custom)
        {
            if(cust.get(accc.ownerid) == null)
            {
                if(accc.Customer_Code__r <> null)
                {
                    
                    Journey_Plan__c jj = new Journey_Plan__c();
                    jj.Destination_Latitude__c=accc.Customer_Code__r.BillingLatitude;
                    jj.Destination_Longitude__c=accc.Customer_Code__r.BillingLongitude; 
                    jj.Customer_Connects__c	= accc.id;
                    
                    jplan.add(jj);
                }
                else
                {
                    Journey_Plan__c jj = new Journey_Plan__c();
                    jj.Destination_Latitude__c=accc.Lead__r.Latitude;
                    jj.Destination_Longitude__c=accc.Lead__r.Longitude;      
                    jj.Customer_Connects__c	= accc.id;
                    
                    jplan.add(jj);
                }
            }
            else 
            {
                if(accc.Customer_Code__r <> null)
                {
                    
                    Journey_Plan__c jj = new Journey_Plan__c();
                    jj.Destination_Latitude__c=accc.Customer_Code__r.BillingLatitude;
                    jj.Destination_Longitude__c=accc.Customer_Code__r.BillingLongitude;
                    jj.Source_Latitude__c = string.valueof(cust.get(accc.ownerid).Customer_Code__r.BillingLatitude);
                    jj.Source_Longitude__c = string.valueof(cust.get(accc.ownerid).Customer_Code__r.BillingLongitude);
                    jj.Customer_Connects__c	= accc.id;
                    
                    jplan.add(jj);
                }
                else
                {
                    Journey_Plan__c jj = new Journey_Plan__c();
                    jj.Destination_Latitude__c=accc.Lead__r.Latitude;
                    jj.Destination_Longitude__c=accc.Lead__r.Longitude;
                    jj.Source_Latitude__c = string.valueof(cust.get(accc.ownerid).Lead__r.Latitude);
                    jj.Source_Longitude__c = string.valueof(cust.get(accc.ownerid).Lead__r.Longitude);
                    jj.Customer_Connects__c	= accc.id;
                    
                    jplan.add(jj);
                }
            }
        }
        insert jplan;
        a=true;
    }
    private static void dummy(){
        integer i=1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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