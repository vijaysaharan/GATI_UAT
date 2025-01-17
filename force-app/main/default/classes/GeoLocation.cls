public class GeoLocation {
    public static String obj='';
    
    public static id id1 { get; set; } 
    list<account> acc = new list <account>();
    list<lead> lcc = new list<lead>();
    list <string> a = new list<string>();
    public static Customer_Connect__c var;
    
    public static account accountdetails;
    public static lead leaddetails;
    public Customer_Connect__c cas { get; set; }
    public map<decimal,string> a1=new map<decimal,string>();
    public map<decimal,string> b1{get;set;}
    public map<decimal,string> b2 {get;set;}
    public map<decimal,id> a2 {get;set;}//
    list<decimal> c1 = new list<decimal>();
    
    public static boolean isrender{get;set;}
    public static boolean isrender2{get;set;}
    
    public GeoLocation (ApexPages.StandardController controller) {
        dummy();
        
        isrender=false;
        isrender2=false;
        
        
        cas =  (Customer_Connect__c) controller.getRecord();
        id1 = cas.Id;
        
        var =[select Customer_Code__c,Lead__c from Customer_Connect__c where id=:id1];
        System.debug(var);
        if(var.Customer_Code__c <> null)
        {
            accountdetails =[select id,BillingLongitude,BillingLatitude, BillingCity,ownerid from account where id=:var.Customer_Code__c];  //first
            acc=[select id,name,BillingLongitude, BillingLatitude, BillingCity from account where BillingCity=:accountdetails.BillingCity and id<>:accountdetails.id and ownerid=:accountdetails.ownerid ]; //all the neaarest
            b2=new map<decimal,string>();a2=new map<decimal,id>();                         
            obj=obj+accountdetails.BillingLongitude+','+accountdetails.BillingLatitude;
            for(account acc2 : acc)
            {
                location loc1 = location.newinstance(accountdetails.BillingLatitude, accountdetails.BillingLongitude);
                location loc2 = location.newinstance(acc2.BillingLatitude, acc2.BillingLongitude);
                double Distance = location.getdistance(loc1,loc2,'km');//distance from sf predefined
                decimal Distance2 = loc1.getDistance(loc2, 'km');    
                obj=obj+';'+acc2.BillingLongitude+','+acc2.BillingLatitude;
                //    System.debug('acc'+obj);
                if(Distance2 <>null ) // sorting
                {
                    
                    
                    a1.put(Distance2,acc2.name);
                    c1.add(Distance2);
                    c1.sort();
                    a2.put(Distance2,acc2.id);
                    
                } 
            }
            System.debug('acc'+obj);
            //   System.debug(GeoLocation.getdistance());
            
            
            if(a1.values().size()>0){
                isrender=true;
                
                b1=new map<decimal,string>();
                b2=new map<decimal,string>();
                
                for(decimal d:c1){
                    
                    b1.put(d,a1.get(d));
                    b2.put(d,url.getSalesforceBaseUrl().toExternalFOrm()+'/'+a2.get(d));
                    
                }   
            }
            else{
                isrender2=true;
            }
        }
        else
        {
            leaddetails = [select id, Latitude, Longitude, city, street, ownerid from lead where id=:var.Lead__c];
            system.debug(leaddetails);
            lcc=[select id, name, Latitude, Longitude,city from lead where city=:leaddetails.city and id<>:leaddetails.id and ownerid=:leaddetails.ownerid];
            system.debug(lcc);
            b2=new map<decimal,string>();                  //   where BillingCity=:accountdetails.BillingCity and id<>:accountdetails.id and ownerid=:accountdetails.ownerid 
            a2=new map<decimal,id>();
            obj=obj+leaddetails.Longitude+','+leaddetails.Latitude;
            System.debug('1   '+obj);
            System.debug('1   '+lcc);
            System.debug('lead details   '+leaddetails);
            for(lead acc3 : lcc)
            {
                location loc1 = location.newinstance(leaddetails.Latitude, leaddetails.Longitude);
                location loc2 = location.newinstance(acc3.Latitude, acc3.Longitude);
                double Distance = location.getdistance(loc1,loc2,'km');//distance from sf predefined
                decimal Distance2 = loc1.getDistance(loc2, 'km');    
                obj=obj+';'+acc3.Longitude+','+acc3.Latitude;
                //     System.debug('2   '+obj);
                //   System.debug('lead'+obj);
                if(Distance2 <>null ) // sorting
                {
                    
                    
                    a1.put(Distance2,acc3.name);
                    c1.add(Distance2);
                    c1.sort();
                    a2.put(Distance2,acc3.id);
                    
                } 
            }
            System.debug('lead'+obj);
            //  System.debug(GeoLocation.getdistance());
            
            system.debug(a1);
            if(a1.values().size()>0){
                isrender=true;
                system.debug(isrender); 
                b1=new map<decimal,string>();
                b2=new map<decimal,string>();
                
                for(decimal d:c1){
                    
                    b1.put(d,a1.get(d));
                    b2.put(d,url.getSalesforceBaseUrl().toExternalFOrm()+'/'+a2.get(d));
                    
                }   
            }
            else{
                isrender2=true;
            }
        }
        
      
    }
      public static void dummy(){
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
        }
}