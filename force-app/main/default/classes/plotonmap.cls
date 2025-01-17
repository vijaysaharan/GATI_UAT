public class plotonmap {
   //List<Decimal> LatLonList = new List<Decimal>();
    public static String obj='';//{get;set;} 
    public static resWrapper getdistance(){
        
        Http http = new Http();              
        HttpRequest req1 = new HttpRequest();
        req1.setHeader('Content-Type','application/x-www-form-urlencoded'); 
        string apikey = '4096efcb6b6032b915632e86c2603ae4';		
        System.debug(obj);
        req1.setEndpoint('https://apis.mapmyindia.com/advancedmaps/v1/'+apikey+'/distance_matrix/driving/'+obj);
        //req1.setBody(Epoint);
        req1.setMethod('GET');
        req1.setTimeout(15000);
        System.debug(req1); 
        HttpResponse result= http.send(req1);
        result.getStatusCode();
        System.debug('result.getBody()=='+result.getBody());
        resWrapper dist = new resWrapper();
        dist = (resWrapper)JSON.deserialize(result.getbody(),resWrapper.class);
        system.debug(dist);
        return dist;
    }
     public class resWrapper{
        Integer responseCode{get;set;}
        String version{get;set;}
        result results = new result();
    }
    public class result{
        String code{get;set;}
        List<List<decimal>> distances = new List<List<decimal>>(); //distance required
        List<List<decimal>> durations = new List<List<decimal>>();
    }
    
    
    
    public static id id1 { get; set; } 
    list<account> acc = new list <account>();
    list <string> a = new list<string>();
    public static Customer_Connect__c var;
   
    public static account accountdetails;
    public Customer_Connect__c cas { get; set; }
    public map<decimal,string> a1=new map<decimal,string>();
    public map<decimal,string> b1{get;set;}
    public map<decimal,string> b2 {get;set;}
    public map<decimal,id> a2 {get;set;}//
    list<decimal> c1 = new list<decimal>();
    public string values{get;set;}
    public string coordinates{get;set;}
    public string centercoords{get;set;}
    public class coordinate{
        public decimal lat{get;set;}
        public decimal lon{get;set;}
    }
    map<string,coordinate> coords = new map<string,coordinate>();
    public coordinate center{get;set;}
   
    public static boolean isrender{get;set;}
    public static boolean isrender2{get;set;}
   
    public plotonmap (ApexPages.StandardController controller) 
    {
      
        isrender=false;
        isrender2=false;
      
  
     cas =  (Customer_Connect__c) controller.getRecord();
     id1 = cas.Id;
     
     var =[select Customer_Code__c from Customer_Connect__c where id=:id1];
     accountdetails =[select id,BillingLongitude, BillingLatitude, BillingCity,ownerid from account where id=:var.Customer_Code__c];  //first
     acc=[select id,name,BillingLongitude, BillingLatitude, BillingCity from account where BillingCity=:accountdetails.BillingCity and id<>:accountdetails.id and ownerid=:accountdetails.ownerid ]; //all the neaarest
         center = new coordinate();
        center.lat = accountdetails.BillingLatitude;
        center.lon = accountdetails.BillingLongitude;
        centercoords = JSON.serialize(center);
      b2=new map<decimal,string>();a2=new map<decimal,id>();
        
         obj=obj+accountdetails.BillingLongitude+','+accountdetails.BillingLatitude;
        for(account acc2 : acc)
          {string cord =  acc2.BillingLongitude +','+ acc2.BillingLatitude;
          location loc1 = location.newinstance(accountdetails.BillingLatitude, accountdetails.BillingLongitude);// lat, lon list
          location loc2 = location.newinstance(acc2.BillingLatitude, acc2.BillingLongitude);// lat lon list
          // LatLonList.add(acc2.BillingLatitude);
         //  LatLonList.add(acc2.BillingLongitude);
           obj=obj+';'+acc2.BillingLongitude+','+acc2.BillingLatitude;

           
          coordinate cinst = new coordinate();
              cinst.lat = acc2.BillingLatitude;
              cinst.lon = acc2.BillingLongitude;
          coords.put(acc2.Name,cinst);
          double Distance = location.getdistance(loc1,loc2,'km');//distance from sf predefined // stamp response here
          decimal Distance2 = loc1.getDistance(loc2, 'km');    
        // System.debug(Distance);
          //  System.debug(Distance2);
         if(Distance2 <>null ) // sorting
         {
            
         
          a1.put(Distance2,acc2.name);
          c1.add(Distance2);
          c1.sort();
          a2.put(Distance2,acc2.id);
          
         } 
         }
                   System.debug(obj);
         System.debug(plotonmap.getdistance());
        
        // obj = String.valueOf(LatLonList);
       // System.debug(obj);
        if(a1.values().size()>0){
            isrender=true;
            
            b1=new map<decimal,string>();
            b2=new map<decimal,string>();
            
            for(decimal d:c1){
                
                b1.put(d,a1.get(d));
                 b2.put(d,url.getSalesforceBaseUrl().toExternalFOrm()+'/'+a2.get(d));
               
            }  
            values = JSON.serialize(b1);
            coordinates = JSON.serialize(coords);
        }
        else{
            isrender2=true;
        }
 }
           
   
}