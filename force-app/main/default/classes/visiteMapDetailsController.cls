public with sharing class visiteMapDetailsController {
    public class LocationWrapper{
        @AuraEnabled public string icon{get;set;}
        @AuraEnabled public string value{get;set;}
        @AuraEnabled public string title{get;set;}
        @AuraEnabled public string description{get;set;}
        @AuraEnabled public string type{get;set;}
        @AuraEnabled public Decimal radius{get;set;}
        @AuraEnabled public string strokeColor{get;set;}
        @AuraEnabled public Decimal strokeOpacity{get;set;}
        @AuraEnabled public Decimal strokeWeight{get;set;}
        @AuraEnabled public string fillColor{get;set;}
        @AuraEnabled public Decimal fillOpacity{get;set;}
        @AuraEnabled public locationDetailWrapper location{get;set;} 
    }
    public class locationDetailWrapper{
        @AuraEnabled public string Latitude{get;set;}
        @AuraEnabled public string Longitude{get;set;}
        @AuraEnabled public string City{get;set;}
        @AuraEnabled public string Country{get;set;}
        @AuraEnabled public string PostalCode{get;set;}
        @AuraEnabled public string State{get;set;}
        @AuraEnabled public string Street{get;set;}
    }
    
    @AuraEnabled
    public static List<LocationWrapper> getLocations(Id recordId){
        List<LocationWrapper> locationList = new List<LocationWrapper>();
        Visit__c visitDetail = [Select Name,Source_Address__c, Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s From Visit__c Where Id =:recordId];
        List<Expense__c> expenseList = [Select Id, visit__c,Name,Customer_Connect__c From Expense__c Where visit__c =: recordId];
        Set<Id> customerConnectIds = new Set<Id>();
        if(!expenseList.isEmpty()){
            for(Expense__c exp : expenseList){
                customerConnectIds.add(exp.Customer_Connect__c);
            }
        }
        List<Customer_Connect__c> customerConnectList = new List<Customer_Connect__c>();
        if(customerConnectIds != Null){
            customerConnectList = [SELECT Id,Name,Check_In_Address__c,Customer_Code__r.Name,Lead__r.Name,Customer_Code__r.Customer_Category__c,Customer_Code__c,Lead__c, Check_In_Location__Latitude__s, Check_In_Location__Longitude__s, Check_In_Time__c FROM Customer_Connect__c WHERE Id IN :customerConnectIds ORDER BY Check_In_Time__c];
        }
        LocationWrapper centerL = new LocationWrapper();
        locationDetailWrapper cL = new locationDetailWrapper();
        centerL.icon = 'utility:checkin';
        centerL.value = visitDetail.Id;
        centerL.title = visitDetail.Name;
        centerL.description = visitDetail.Source_Address__c;
        cL.Latitude = String.valueOf(visitDetail.Source_Geo_Coordinate__Latitude__s);
        cL.Longitude = String.valueOf(visitDetail.Source_Geo_Coordinate__Longitude__s);
        String geoCheckInAddress = '';
        if(visitDetail.Source_Address__c != null){
            geoCheckInAddress = visitDetail.Source_Address__c;    
        }
        else{
            geoCheckInAddress = GoogleApiApex.parseJSONResponse(visitDetail.Source_Geo_Coordinate__Latitude__s,visitDetail.Source_Geo_Coordinate__Longitude__s);  
        }
        
        System.debug('address==>'+geoCheckInAddress);
        List<String> locStr = geoCheckInAddress.split(',');
        Integer sizelocStr = locStr.size();
        if(sizelocStr > 2){
            cL.Street = locStr[2];
        }
        if(sizelocStr > 3){
            cL.City = locStr[3];
        }
        cL.Country = locStr[sizelocStr-1];
        if(sizelocStr >= 2){
            cL.PostalCode = locStr[sizelocStr-2].substringAfterLast(' ');
            cL.State = locStr[sizelocStr-2].substringBeforeLast(' ');
        }
        centerL.location = cL;
        locationList.add(centerL);
        for(Customer_Connect__c connect : customerConnectList){
            LocationWrapper centerL1 = new LocationWrapper();
            locationDetailWrapper cL1 = new locationDetailWrapper();
            centerL1.icon = 'utility:checkin';
            centerL1.value = connect.Id;
            if(connect.Lead__c != null){
                centerL1.title = connect.Name+': '+connect.Lead__r.Name;
            }
            else if(connect.Customer_Code__c != null){
                if(connect.Customer_Code__r.Customer_Category__c != null){
                	centerL1.title = connect.Name+': '+connect.Customer_Code__r.Name + ': '+connect.Customer_Code__r.Customer_Category__c;
                }
                else{
                    centerL1.title = connect.Name+': '+connect.Customer_Code__r.Name;
                }
            }
            else{
                centerL1.title = connect.Name;
            }
            centerL1.description = connect.Check_In_Address__c;
            cL1.Latitude = String.valueOf(connect.Check_In_Location__Latitude__s);
            cL1.Longitude = String.valueOf(connect.Check_In_Location__Longitude__s);
            String geoCheckInAddress1 = '';
            if(connect.Check_In_Address__c != null){
                geoCheckInAddress1 = connect.Check_In_Address__c;
            }
            else{
                geoCheckInAddress1 = GoogleApiApex.parseJSONResponse(connect.Check_In_Location__Latitude__s,connect.Check_In_Location__Longitude__s);
            }
            List<String> locationStrings = geoCheckInAddress1.split(',');
            Integer sizeOflocationStrings = locationStrings.size();
            if(sizeOflocationStrings > 2){
                cL1.Street = locationStrings[2];
            }
            if(sizeOflocationStrings > 3){
                cL1.City = locationStrings[3];
            }
            cL1.Country = locationStrings[sizeOflocationStrings-1];
            if(sizeOflocationStrings >= 2){
                cL1.PostalCode = locationStrings[sizeOflocationStrings-2].substringAfterLast(' ');
                cL1.State = locationStrings[sizeOflocationStrings-2].substringBeforeLast(' ');
            }
            centerL1.location = cL1;
            locationList.add(centerL1);
        }
        return locationList;
    }
    
    @AuraEnabled
    public static String getiframeUrl(Id visitId){
        String srcString = 'https://www.google.com/maps/embed/v1/directions?key=AIzaSyBZytKNNy09mihaVpMv-znXnt6b5WEtHoc&origin=';
        Visit__c visitDetail = [Select Name,Source_Address__c, Source_Geo_Coordinate__Latitude__s,Source_Geo_Coordinate__Longitude__s From Visit__c Where Id =:visitId];
        string orign = visitDetail.Source_Geo_Coordinate__Latitude__s+','+visitDetail.Source_Geo_Coordinate__Longitude__s;
        List<Expense__c> expenseList = [Select Id, visit__c,Name,Customer_Connect__c From Expense__c Where visit__c =: visitId];
        Set<Id> customerConnectIds = new Set<Id>();
        if(!expenseList.isEmpty()){
            for(Expense__c exp : expenseList){
                customerConnectIds.add(exp.Customer_Connect__c); 
            }
        }
        List<Customer_Connect__c> customerConnectList = new List<Customer_Connect__c>();
        if(customerConnectIds != Null){
            customerConnectList = [SELECT Id,Name,Check_In_Address__c, Check_In_Location__Latitude__s, Check_In_Location__Longitude__s, Check_In_Time__c FROM Customer_Connect__c WHERE Id IN :customerConnectIds ORDER BY Check_In_Time__c];
        }
        Integer sizeOfcusList = customerConnectList.size();
        String destination = '';
        if(sizeOfcusList > 0){
            destination = '&destination='+customerConnectList[sizeOfcusList-1].Check_In_Location__Latitude__s+','+customerConnectList[sizeOfcusList-1].Check_In_Location__Longitude__s+'&avoid=tolls|highways&zoom=11';   
        }
        String wayPoint = '';
        if(sizeOfcusList>1){
            wayPoint = '&waypoints=';
            for(Customer_Connect__c cus : customerConnectList){
                if(cus.Id != customerConnectList[sizeOfcusList-1].Id){                    
                    wayPoint = wayPoint+cus.Check_In_Location__Latitude__s+','+cus.Check_In_Location__Longitude__s+'|';
                }
            }
        }
        if(wayPoint != ''){
            srcString = srcString+orign+destination+wayPoint;
        }else{
            srcString = srcString+orign+destination;
        }
        
        if (srcString.endsWith('|')) {
            srcString = srcString.substring(0, srcString.length() - 1);
        }
        return srcString;
    }
}