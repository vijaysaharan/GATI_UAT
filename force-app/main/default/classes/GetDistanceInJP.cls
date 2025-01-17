public class GetDistanceInJP {
    
    public static Journey_Plan__c JPDetails;
    @InvocableMethod(label='GetDistanceInJP') 
    public static Void calloutMethod(List<String> JPId){
        getDistanceMethod(JPId);
    }
    
     @future(callout=true)
    public static void getDistanceMethod(list<String> JPId){
        
        String obj='';
        JPDetails = [Select Id,Distance__c,Destination_Longitude__c,Source_Longitude__c,Destination_Latitude__c,Source_Latitude__c from Journey_Plan__c where ID =:JPId ];
        
        //Distance__c
        obj=JPDetails.Source_Longitude__c+','+JPDetails.Source_Latitude__c+';'+JPDetails.Destination_Longitude__c+','+JPDetails.Destination_Latitude__c;     
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
        
        
        
        
        
        try{
            if(result.getStatusCode()==200)
            {
                ResWrapper responseObj = (ResWrapper)JSON.deserialize(result.getBody(), ResWrapper.class);
                //System.debug(responseObj.results.distances);
                System.debug(responseObj.results.distances[0][1]);
                JPDetails.Distance__c=responseObj.results.distances[0][1];
              //  
            }
            
              
            
            
        }
        
        catch(Exception e)
        {
            Integration_Log__c ic = new Integration_Log__c();
            ic.Component_Name__c='JourneyPLan log';
            ic.Error_Message__c=e.getMessage();
            ic.IsIntegration__c=true; 
            ic.eRecordID__c = JPDetails.id;
            ic.eObject__c = 'Journey Plan';
            insert ic;
            
        }
      update JPDetails;
    }
    public class ResWrapper{
        Integer responseCode{get;set;}
        String version{get;set;}
        result results = new result();
    }
    public class result{
        String code{get;set;}
        List<List<decimal>> distances = new List<List<decimal>>(); //distance required
        List<List<decimal>> durations = new List<List<decimal>>();
    }
}