import { LightningElement, api, track } from 'lwc';
import getLocations from '@salesforce/apex/visiteMapDetailsController.getLocations';
import getiframeUrl from '@salesforce/apex/visiteMapDetailsController.getiframeUrl';

export default class VisiteMapDetails extends LightningElement {
    @track srcUrl;
    @api recordId;
    selectedMarkerValue;

    @track center;

    @track mapMarkers = [];

    connectedCallback() {
        getLocations({ recordId: this.recordId }).then(res => {
            this.mapMarkers = JSON.parse(JSON.stringify(res));
            this.selectedMarkerValue = this.mapMarkers[0].value;
            getiframeUrl({visitId : this.recordId}).then(res=>{
                this.srcUrl = res;
            }).catch(err => {
                console.log('Error In set mapMaker' + JSON.stringify(err));
            });
            this.center = {
                location: this.mapMarkers[0].location,
            };
        }).catch(err => {
            console.log('Error In set mapMaker' + JSON.stringify(err));
        });
    }

    handleMarkerSelect = (event) => {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
    };
}