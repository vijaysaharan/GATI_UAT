import { LightningElement, track} from 'lwc';
import latlong from '@salesforce/apex/JourneyPlan.latlong';
export default class CurrentLocation extends LightningElement {
    @track long;
    @track lat;
    lstMarkers = [];
    zoomlevel = "1";

    handleClick(){
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {

                // Get the Latitude and Longitude from Geolocation API
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
                var latitude2;
                var longitude2;
                
                // Add Latitude and Longitude to the markers list.
                this.lstMarkers = [{
                    location : {
                        Latitude: latitude,
                        Longitude : longitude
                    },
                    title: 'You are here'
                }];
                /* Value: 'SF1',
                    title : 'You are here'
                },
                {
            location :
             {
                latitude2 : 12.9716,
                longitude2 : 77.5946

             },
            value : 'SF2',
            title : 'Customers location'
                }, */
            
                this.zoomlevel = "4";
            
            });
        }
        latlong({aa:this.Latitude,bb:this.Longitude})
           
    }
}