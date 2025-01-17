public class GoogleApiApex {
    public static String parseJSONResponse(Decimal eventlat, Decimal eventlong) { 
        
        String address=eventlat+'+'+eventlong;
        String key='AIzaSyBZytKNNy09mihaVpMv-znXnt6b5WEtHoc';
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&key='+key;
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = httpProtocol.send(request);
        ReverseGeoCodeWrapper geoCodeAddress = (ReverseGeoCodeWrapper) System.JSON.deserialize(response.getBody(), ReverseGeoCodeWrapper.Class);
        //System.debug(response.getBody());
        System.debug('-- address reverse--'+geoCodeAddress.Results[0].formatted_address);
        return geoCodeAddress.Results[0].formatted_address;
    } 
    
    public static String parseJSONResponseByAddress(String Street, String PostalCode, String City, String State, String Country) { 
        
        String address=Street+'+'+City+'+'+State+'+'+PostalCode+'+'+Country;
        String key='AIzaSyBZytKNNy09mihaVpMv-znXnt6b5WEtHoc';
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&key='+key;
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = httpProtocol.send(request);
        ReverseGeoCodeWrapper geoCodeAddress = (ReverseGeoCodeWrapper) System.JSON.deserialize(response.getBody(), ReverseGeoCodeWrapper.Class);
        System.debug('-- check response--'+geoCodeAddress);
        return geoCodeAddress.Results[0].formatted_address;
    }  
    
    public static Map<String, Object> getLatLongFromAddress(String address){
        Map<String, Object> returnMap = new Map<String, Object>();
        //address = 'Ward no 7, Chandari Bari, Purabsar, Rawatsar, Hanumangarh, Rajasthan 335524';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + address;
        endpoint += '&key=AIzaSyBZytKNNy09mihaVpMv-znXnt6b5WEtHoc';
        
        request.setEndpoint(endpoint.replace(' ', '+')); 
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        Map<String, Object> resultJSON = (Map<String, Object>)JSON.deserializeUntyped(response.getBody()); 
        System.debug('resultJSON'+resultJSON);
        if ((String)resultJSON.get('status') != 'OK') {
            
        } else {
            List<Object> apiResult = (List<Object>)resultJSON.get('results');
            
            Object actualResult = (Object)apiResult[0]; 
            Map<String, Object> actualResultMap = (Map<String, Object>)actualResult; 
            Map<String, Object> geo = (Map<String, Object>)actualResultMap.get('geometry'); 
            Map<String, Object> coords = (Map<String, Object>)geo.get('location'); 
            
            returnMap.put('lng', coords.get('lng'));
            returnMap.put('lat', coords.get('lat'));
            
            returnMap.put('formatted_address', actualResultMap.get('formatted_address'));
            System.debug(returnMap);
            
        }
        return returnMap;
    }
    
    public static Integer getDistanceBetweenLatLog(Decimal orgLat, Decimal orgLog, Decimal desLat, Decimal desLog) {
        System.debug('########'+orgLat);
        Integer distanceMeters;
        String key='AIzaSyBZytKNNy09mihaVpMv-znXnt6b5WEtHoc';
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint = 'https://routes.googleapis.com/directions/v2:computeRoutes';
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('X-Goog-Api-Key', key);
        request.setHeader('X-Goog-FieldMask', 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline');
        String jsonRequestBody = createJsonRequestBody(orgLat, orgLog, desLat, desLog);
        request.setBody(jsonRequestBody);
        System.debug('request'+jsonRequestBody);
        HttpResponse response = httpProtocol.send(request);
        System.debug(response);
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            List<Object> routesList = (List<Object>)responseData.get('routes');
            
            if (routesList != null && !routesList.isEmpty()) {
                Map<String, Object> routeInfoMap = (Map<String, Object>)routesList[0];
                RouteInfo routeInfo = (RouteInfo)JSON.deserialize(JSON.serialize(routeInfoMap), RouteInfo.class);
                System.debug('routeInfo'+routeInfo);
                distanceMeters = routeInfo.distanceMeters;
            } else {
                System.debug('No routes found in the response.');
            }
        } else {
            System.debug('Request failed with status code: ' + response.getStatusCode());
            System.debug('Response body: ' + response.getBody());
        }
        System.debug('#######'+distanceMeters);
        return distanceMeters;
    } 
    
    public static String createJsonRequestBody(Decimal originLatitude, Decimal originLongitude, Decimal destinationLatitude, Decimal destinationLongitude) {
        Map<String, Object> requestBody = new Map<String, Object>{
             'origin' => new Map<String, Object>{
                                                   'location' => new Map<String, Object>{
                                                   'latLng' => new Map<String, Double>{
                                                   			'latitude' => originLatitude,
                                                   			'longitude' => originLongitude
                                                           }
                                                    }
                                               	},
             'destination' => new Map<String, Object>{
                                                       'location' => new Map<String, Object>{
                                                       'latLng' => new Map<String, Double>{
                                                               'latitude' => destinationLatitude,
                                                               'longitude' => destinationLongitude
                                                             }
                                                          }
                                                      },
            'travelMode' => 'DRIVE',
            'routingPreference' => 'TRAFFIC_AWARE',
            'computeAlternativeRoutes' => false,
            'routeModifiers' => new Map<String, Object>{
            				'avoidTolls' => false,
            				'avoidHighways' => false,
            				'avoidFerries' => false
          		},
        'languageCode' => 'en-US',
       	'units' => 'IMPERIAL'
    };
                                                                               
    return JSON.serialize(requestBody);
   }
    
    public class RouteInfo {
        public Integer distanceMeters;
        public String duration;
        public PolylineInfo polyline;
    }
    
    public class PolylineInfo {
        public String encodedPolyline;
    }
}