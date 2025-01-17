public with sharing class MapPlot {
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
        @AuraEnabled public mapIconWrapper mapIcon{get;set;}
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
    public class mapIconWrapper{
        @AuraEnabled public string path{get;set;}
        @AuraEnabled public string fillColor{get;set;}
        @AuraEnabled public Decimal fillOpacity{get;set;}
        @AuraEnabled public Decimal strokeWeight{get;set;}
        @AuraEnabled public Decimal scale{get;set;}
        @AuraEnabled public anchorWrapper anchor{get;set;}
    }
    public class anchorWrapper{
        @AuraEnabled public Decimal x {get;set;}
        @AuraEnabled public Decimal y {get;set;}
    }
    
    @AuraEnabled
    public static List<LocationWrapper> getAllRelatedAccount(Id cusId){
        String sobjectName = cusId.getSObjectType().getDescribe().getName();
        List<LocationWrapper> locationList = new List<LocationWrapper>();
        if(sobjectName == 'Customer_Connect__c'){
            List<Customer_Connect__c> cusRec = [SELECT Id,Check_In_Address__c,Lead__c, Name,Visit_Start_Date__c,OwnerId,Visit_Date__c, CreatedDate,Check_In_Location__Latitude__s, Check_In_Location__Longitude__s,Check_In_Time__c,Customer_Code__c,Customer_Code__r.Name FROM Customer_Connect__c WHERE Id =: cusId];
            if(cusRec != null && cusRec.size()>0 && cusRec[0].Customer_Code__c != null){
                locationList = getAllMapPoints(cusRec[0],true);
            }
            if(cusRec != null && cusRec.size()>0 && cusRec[0].Lead__c != null){
                locationList = getAllMapPoints(cusRec[0],false);
            }
        }
        else if(sobjectName == 'Account'){
            locationList = getAllAccountsForCurrent(cusId);
        }
        return locationList;
    }
    
    private static List<LocationWrapper> getAllMapPoints(Customer_Connect__c cusRec,Boolean isAccount){
        Id currentUserId = UserInfo.getUserId();
        List<LocationWrapper> locationList = new List<LocationWrapper>();
        Account acc = new Account();
        Lead ld = new Lead();
        
        List<Account> accList = [Select Id,Name,Customer_Category__c,Monthly_Spend_on_Logistic__c,Last_Visit_Date__c,Last_Visited_By__c,BillingStreet,BillingPostalCode,BillingCity,BillingState,Address__c,Geolocation_Address__Latitude__s,Geolocation_Address__Longitude__s,OwnerId From Account WHERE OwnerId =: currentUserId];
        List<Lead> leadList = [Select Id,Name,Last_Visit_Date__c,Last_Visited_By__c,Address__c,Geolocation_Address__Latitude__s,Geolocation_Address__Longitude__s,OwnerId From Lead Where Geolocation_Address__Latitude__s != null AND OwnerId =: currentUserId];
        
        if(isAccount){
            acc = [Select Id,Customer_Category__c,Monthly_Spend_on_Logistic__c,Last_Visited_By__c,Name,Last_Visit_Date__c,BillingState,BillingStreet,BillingPostalCode,BillingCity,Address__c,Geolocation_Address__Latitude__s,Geolocation_Address__Longitude__s,OwnerId From Account Where Id =:cusRec.Customer_Code__c];
            if(!accList.contains(acc)){
                accList.add(acc);
            }
            LocationWrapper loc = new LocationWrapper();
            locationDetailWrapper locLatLong = new locationDetailWrapper();
            loc.icon = 'utility:checkin';
            loc.value = acc.Id;
            if(acc.Last_Visited_By__c != null && acc.Last_Visit_Date__c != null){
                loc.title = acc.Name+': '+acc.Last_Visited_By__c+': '+acc.Last_Visit_Date__c;
            }else{
                loc.title = acc.Name;
            }
            loc.description = String.valueOf(acc.Address__c);
            loc.type= 'Circle';
            loc.radius= 20000;
            loc.strokeColor= '#FFF000';
            loc.strokeOpacity= 0.8;
            loc.strokeWeight= 2;
            loc.fillColor= '#FFF000';
            loc.fillOpacity= 0.35;
            if(acc.Geolocation_Address__Latitude__s != null && acc.Geolocation_Address__Longitude__s != null){
                locLatLong.Latitude = String.valueOf(acc.Geolocation_Address__Latitude__s);
                locLatLong.Longitude = String.valueOf(acc.Geolocation_Address__Longitude__s);
            }
            else{
                locLatLong.City = String.valueOf(acc.BillingCity);
                locLatLong.PostalCode = String.valueOf(acc.BillingPostalCode);
                locLatLong.Street = String.valueOf(acc.BillingStreet);
            }
            loc.location = locLatLong;
            locationList.add(loc);
        }
        else{
            ld = [Select Id,Name,Last_Visit_Date__c,Last_Visited_By__c,Address__c,Geolocation_Address__Latitude__s,Geolocation_Address__Longitude__s,OwnerId From Lead Where Id =:cusRec.Lead__c];
            if(!leadList.contains(ld)){
                leadList.add(ld);
            }
            LocationWrapper loc = new LocationWrapper();
            locationDetailWrapper locLatLong = new locationDetailWrapper();
            loc.icon = 'utility:checkin';
            loc.value = ld.Id;
            if(ld.Last_Visited_By__c != null && ld.Last_Visit_Date__c != null){
                loc.title = ld.Name+': '+ld.Last_Visited_By__c+': '+ld.Last_Visit_Date__c;
            }else{
                loc.title = ld.Name;
            }
            loc.description = String.valueOf(ld.Address__c);
            loc.type= 'Circle';
            loc.radius= 20000;
            loc.strokeColor= '#FFF000';
            loc.strokeOpacity= 0.8;
            loc.strokeWeight= 2;
            loc.fillColor= '#FFF000';
            loc.fillOpacity= 0.35;
            if(ld.Geolocation_Address__Latitude__s != null && ld.Geolocation_Address__Longitude__s != null){
                locLatLong.Latitude = String.valueOf(ld.Geolocation_Address__Latitude__s);
                locLatLong.Longitude = String.valueOf(ld.Geolocation_Address__Longitude__s);
            }
            loc.location = locLatLong;
            locationList.add(loc);
        }
        
        if(accList != null && accList.size()>0){
            for(Account ac : accList){
                if((ac.BillingStreet != null || (ac.BillingPostalCode != null && ac.BillingCity != null)) || (ac.Geolocation_Address__Latitude__s != null && ac.Geolocation_Address__Longitude__s != null)){
                    LocationWrapper loc1 = new LocationWrapper();
                    loc1.description = '';
                    locationDetailWrapper locLatLong1 = new locationDetailWrapper();
                    anchorWrapper anchorWrap = new anchorWrapper();
                    mapIconWrapper mapIconWrap = new mapIconWrapper();
                    loc1.icon = 'utility:checkin';
                    loc1.value = ac.Id ;
                    
                    if(ac.Last_Visited_By__c != null && ac.Last_Visit_Date__c != null){
                        loc1.title = ac.Name+': '+ac.Last_Visited_By__c+': '+ac.Last_Visit_Date__c;
                    }
                    else{
                        loc1.title = ac.Name;
                    }
                    
                    if(ac.Monthly_Spend_on_Logistic__c != null){
                    	loc1.description += '<b>Catagory - '+ac.Monthly_Spend_on_Logistic__c+'</b><br>';
                    }
                    
                    if(ac.Address__c != null){
                        loc1.description += String.valueOf(ac.Address__c);   
                    }
                    
                    if(ac.Geolocation_Address__Latitude__s != null && ac.Geolocation_Address__Longitude__s != null){
                        locLatLong1.Latitude = String.valueOf(ac.Geolocation_Address__Latitude__s);
                        locLatLong1.Longitude = String.valueOf(ac.Geolocation_Address__Longitude__s);
                    }
                    else if(ac.BillingStreet != null || (ac.BillingPostalCode != null && ac.BillingCity != null)){
                        locLatLong1.City = String.valueOf(ac.BillingCity);
                        locLatLong1.PostalCode = String.valueOf(ac.BillingPostalCode);
                        locLatLong1.Street = String.valueOf(ac.BillingStreet);
                    }
                    
                    if(ac.Id == acc.Id){
                        anchorWrap.x = 0;
                        anchorWrap.y = 20;
                        mapIconWrap.path = 'M-1.547 12l6.563-6.609-1.406-1.406-5.156 5.203-2.063-2.109-1.406 1.406zM0 0q2.906 0 4.945 2.039t2.039 4.945q0 1.453-0.727 3.328t-1.758 3.516-2.039 3.070-1.711 2.273l-0.75 0.797q-0.281-0.328-0.75-0.867t-1.688-2.156-2.133-3.141-1.664-3.445-0.75-3.375q0-2.906 2.039-4.945t4.945-2.039z';
                        mapIconWrap.fillColor='green';
                        mapIconWrap.fillOpacity= 1;
                        mapIconWrap.strokeWeight= 0;
                        mapIconWrap.scale = 2;
                        mapIconWrap.anchor= anchorWrap;
                        loc1.mapIcon = mapIconWrap;
                    }
                    else{
                        /*
                            Strategic - #00ddff
                            Retail - #ff5900
                            Partner - #a600ff
                            MSME - #465e1d
                            KEA - #703a07
                        */
                        if(ac.Customer_Category__c != null){
                            anchorWrap.x = 12;
                            anchorWrap.y = 12;
                            mapIconWrap.path = 'M12 11.5A2.5 2.5 0 0 1 9.5 9A2.5 2.5 0 0 1 12 6.5A2.5 2.5 0 0 1 14.5 9a2.5 2.5 0 0 1-2.5 2.5M12 2a7 7 0 0 0-7 7c0 5.25 7 13 7 13s7-7.75 7-13a7 7 0 0 0-7-7Z';
                            mapIconWrap.fillOpacity= 1;
                            mapIconWrap.strokeWeight= 0;
                            mapIconWrap.scale = 2;
                            mapIconWrap.anchor= anchorWrap;
                            loc1.mapIcon = mapIconWrap;
                            loc1.description += '<br><b>Type - '+ac.Customer_Category__c+'</b>';
                            if(ac.Customer_Category__c == 'KEA'){
                                mapIconWrap.fillColor='#703a07';
                            }else if(ac.Customer_Category__c == 'Retail'){
                                mapIconWrap.fillColor='#ff5900';
                            }else if(ac.Customer_Category__c == 'Strategic'){
                                mapIconWrap.fillColor='#00ddff';
                            }else if(ac.Customer_Category__c == 'Partner'){
                                mapIconWrap.fillColor='#a600ff';
                            }else if(ac.Customer_Category__c == 'MSME'){
                                mapIconWrap.fillColor='#465e1d';
                            }
                        }
                    }
                    
                    loc1.location = locLatLong1;
                    locationList.add(loc1);
                }
            }
        }
        
        if(leadList != null && leadList.size()>0){
            for(Lead ac : leadList){
                if(ac.Geolocation_Address__Latitude__s != null && ac.Geolocation_Address__Longitude__s != null){
                    LocationWrapper loc1 = new LocationWrapper();
                    loc1.description = '';
                    locationDetailWrapper locLatLong1 = new locationDetailWrapper();
                    anchorWrapper anchorWrap = new anchorWrapper();
                    mapIconWrapper mapIconWrap = new mapIconWrapper();
                    loc1.icon = 'utility:checkin';
                    loc1.value = ac.Id;
                    if(ac.Last_Visited_By__c != null && ac.Last_Visit_Date__c != null){
                        loc1.title = ac.Name+': '+ac.Last_Visited_By__c+': '+ac.Last_Visit_Date__c;
                    }
                    else{
                        loc1.title = ac.Name;
                    }
                    if(ac.Address__c != null){
                     	loc1.description = String.valueOf(ac.Address__c);   
                    }
                    locLatLong1.Latitude = String.valueOf(ac.Geolocation_Address__Latitude__s);
                    locLatLong1.Longitude = String.valueOf(ac.Geolocation_Address__Longitude__s);
                    loc1.location = locLatLong1;
                    anchorWrap.x = 12;
                    anchorWrap.y = 12;
                    mapIconWrap.path = 'M12 11.5A2.5 2.5 0 0 1 9.5 9A2.5 2.5 0 0 1 12 6.5A2.5 2.5 0 0 1 14.5 9a2.5 2.5 0 0 1-2.5 2.5M12 2a7 7 0 0 0-7 7c0 5.25 7 13 7 13s7-7.75 7-13a7 7 0 0 0-7-7Z';
                    
                    if(ld != null && ac.Id == ld.Id){
                        mapIconWrap.fillColor='green';
                    }
                    else{
                        mapIconWrap.fillColor='blue';
                    }
                    
                    mapIconWrap.fillOpacity= 1;
                    mapIconWrap.strokeWeight= 0;
                    mapIconWrap.scale = 2;
                    mapIconWrap.anchor= anchorWrap;
                    loc1.mapIcon = mapIconWrap;
                    locationList.add(loc1);
                }
            }
        }
        
        return locationList;
    }
    
    private static List<LocationWrapper> getAllAccountsForCurrent(Id accId){
        Id currentUserId = UserInfo.getUserId();
        List<LocationWrapper> locationList = new List<LocationWrapper>();
        List<Account> accList = [Select Id,Name,Customer_Category__c,Monthly_Spend_on_Logistic__c,Last_Visit_Date__c,Last_Visited_By__c,BillingStreet,BillingPostalCode,BillingCity,BillingState,Address__c,Geolocation_Address__Latitude__s,Geolocation_Address__Longitude__s,OwnerId From Account Where OwnerId=: UserInfo.getUserId()];
        Account acc = [Select Id,Customer_Category__c,Monthly_Spend_on_Logistic__c,Last_Visited_By__c,Name,Last_Visit_Date__c,BillingState,BillingStreet,BillingPostalCode,BillingCity,Address__c,Geolocation_Address__Latitude__s,Geolocation_Address__Longitude__s,OwnerId From Account Where Id =:accId];
        if(!accList.contains(acc)){
            accList.add(acc);
        }
        LocationWrapper loc = new LocationWrapper();
        locationDetailWrapper locLatLong = new locationDetailWrapper();
        loc.icon = 'utility:checkin';
        loc.value = acc.Id;
        
        if(acc.Last_Visited_By__c != null && acc.Last_Visit_Date__c != null){
            loc.title = acc.Name+': '+acc.Last_Visited_By__c+': '+acc.Last_Visit_Date__c;
        }
        else{
            loc.title = acc.Name;
        }
        
        loc.description = String.valueOf(acc.Address__c);
        loc.type= 'Circle';
        loc.radius= 20000;
        loc.strokeColor= '#FFF000';
        loc.strokeOpacity= 0.8;
        loc.strokeWeight= 2;
        loc.fillColor= '#FFF000';
        loc.fillOpacity= 0.35;
        if(acc.Geolocation_Address__Latitude__s != null && acc.Geolocation_Address__Longitude__s != null){
            locLatLong.Latitude = String.valueOf(acc.Geolocation_Address__Latitude__s);
            locLatLong.Longitude = String.valueOf(acc.Geolocation_Address__Longitude__s);
        }
        else{
            locLatLong.City = String.valueOf(acc.BillingCity);
            locLatLong.PostalCode = String.valueOf(acc.BillingPostalCode);
            locLatLong.Street = String.valueOf(acc.BillingStreet);
        }
        loc.location = locLatLong;
        locationList.add(loc);
        
        if(accList != null && accList.size()>0){
            for(Account ac : accList){
                if((ac.BillingStreet != null || (ac.BillingPostalCode != null && ac.BillingCity != null)) || (ac.Geolocation_Address__Latitude__s != null && ac.Geolocation_Address__Longitude__s != null)){
                    LocationWrapper loc1 = new LocationWrapper();
                    loc1.description = '';
                    locationDetailWrapper locLatLong1 = new locationDetailWrapper();
                    anchorWrapper anchorWrap = new anchorWrapper();
                    mapIconWrapper mapIconWrap = new mapIconWrapper();
                    loc1.icon = 'utility:checkin';
                    loc1.value = ac.Id ;
                    
                    if(ac.Last_Visited_By__c != null && ac.Last_Visit_Date__c != null){
                        loc1.title = ac.Name+': '+ac.Last_Visited_By__c+': '+ac.Last_Visit_Date__c;
                    }
                    else{
                        loc1.title = ac.Name;
                    }
                    
                    if(ac.Monthly_Spend_on_Logistic__c != null){
                    	loc1.description += '<b>Catagory - '+ac.Monthly_Spend_on_Logistic__c+'</b><br>';
                    }
                    
                    if(ac.Address__c != null){
                        loc1.description += String.valueOf(ac.Address__c);   
                    }
                    
                    if(ac.Geolocation_Address__Latitude__s != null && ac.Geolocation_Address__Longitude__s != null){
                        locLatLong1.Latitude = String.valueOf(ac.Geolocation_Address__Latitude__s);
                        locLatLong1.Longitude = String.valueOf(ac.Geolocation_Address__Longitude__s);
                    }
                    else if(ac.BillingStreet != null || (ac.BillingPostalCode != null && ac.BillingCity != null)){
                        locLatLong1.City = String.valueOf(ac.BillingCity);
                        locLatLong1.PostalCode = String.valueOf(ac.BillingPostalCode);
                        locLatLong1.Street = String.valueOf(ac.BillingStreet);
                    }
                    
                    if(ac.Id == acc.Id){
                        anchorWrap.x = 0;
                        anchorWrap.y = 20;
                        mapIconWrap.path = 'M-1.547 12l6.563-6.609-1.406-1.406-5.156 5.203-2.063-2.109-1.406 1.406zM0 0q2.906 0 4.945 2.039t2.039 4.945q0 1.453-0.727 3.328t-1.758 3.516-2.039 3.070-1.711 2.273l-0.75 0.797q-0.281-0.328-0.75-0.867t-1.688-2.156-2.133-3.141-1.664-3.445-0.75-3.375q0-2.906 2.039-4.945t4.945-2.039z';
                        mapIconWrap.fillColor='green';
                        mapIconWrap.fillOpacity= 1;
                        mapIconWrap.strokeWeight= 0;
                        mapIconWrap.scale = 2;
                        mapIconWrap.anchor= anchorWrap;
                        loc1.mapIcon = mapIconWrap;
                    }
                    else{
                        /*
                            Strategic - #00ddff
                            Retail - #ff5900
                            Partner - #a600ff
                            MSME - #465e1d
                            KEA - #703a07
                        */
                        if(ac.Customer_Category__c != null){
                            anchorWrap.x = 12;
                            anchorWrap.y = 12;
                            mapIconWrap.path = 'M12 11.5A2.5 2.5 0 0 1 9.5 9A2.5 2.5 0 0 1 12 6.5A2.5 2.5 0 0 1 14.5 9a2.5 2.5 0 0 1-2.5 2.5M12 2a7 7 0 0 0-7 7c0 5.25 7 13 7 13s7-7.75 7-13a7 7 0 0 0-7-7Z';
                            mapIconWrap.fillOpacity= 1;
                            mapIconWrap.strokeWeight= 0;
                            mapIconWrap.scale = 2;
                            mapIconWrap.anchor= anchorWrap;
                            loc1.mapIcon = mapIconWrap;
                            loc1.description += '<br><b>Type - '+ac.Customer_Category__c+'</b>';
                            if(ac.Customer_Category__c == 'KEA'){
                                mapIconWrap.fillColor='#703a07';
                            }else if(ac.Customer_Category__c == 'Retail'){
                                mapIconWrap.fillColor='#ff5900';
                            }else if(ac.Customer_Category__c == 'Strategic'){
                                mapIconWrap.fillColor='#00ddff';
                            }else if(ac.Customer_Category__c == 'Partner'){
                                mapIconWrap.fillColor='#a600ff';
                            }else if(ac.Customer_Category__c == 'MSME'){
                                mapIconWrap.fillColor='#465e1d';
                            }
                        }
                    }
                    loc1.location = locLatLong1;
                    locationList.add(loc1);
                }
            }
        }
        
        return locationList;
    }
    
}