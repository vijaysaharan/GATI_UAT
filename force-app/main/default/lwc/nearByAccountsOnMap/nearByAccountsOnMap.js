import { LightningElement,track, api } from 'lwc';
import getAllRelatedAccount from '@salesforce/apex/MapPlot.getAllRelatedAccount';
import { NavigationMixin } from "lightning/navigation";

export default class NearByAccountsOnMap extends NavigationMixin(LightningElement) {
    @api recordId;
    selectedMarkerValue;
    @track center;
    @track rangeKM ;
    @track zoomLevel = 13;
    showMap = false;
    noData = false;
    @track message = 'THERE IS NO ACCOUNT OR LEAD FOR THIS CUSTOMER CONNECT';

    rangeOptions = [
        {label : '10', value : "10"},
        {label : '20', value : "20"},
        {label : '30', value : "30"},
        {label : '40', value : "40"},
        {label : '50', value : "50"},
    ];

    @track mapMarkers = [];
    //@track allData = [];
    @track mainRecord = {};
    currentAccount= null;


    connectedCallback() {
        getAllRelatedAccount({ cusId: this.recordId }).then(res => {
            this.mapMarkers = JSON.parse(JSON.stringify(res));
            if(this.mapMarkers.length <= 0){
                this.noData = true;
            }
            /*
            this.allData = JSON.parse(JSON.stringify(res));
            if(this.allData.length <= 0){
                this.noData = true;
            }
            this.mapMarkers = JSON.parse(JSON.stringify (this.allData.filter(el => el.distance <= this.allData[0].radius / 1000)));
            this.mapMarkers = this.mapMarkers.map(el => {
                delete el.distance;
                return el;
            });*/
            else{
                this.selectedMarkerValue = this.mapMarkers[0].value;
                this.currentAccount = this.mapMarkers[0].value;
                this.rangeKM = String(this.mapMarkers[0].radius / 1000);
                this.center = {
                    location: this.mapMarkers[0].location,
                };
                this.showMap = true;
            }
        }).catch(err => {
            this.noData = true;
            this.message = err.body.message;
        });
    }

    handleMarkerSelect = (event) => {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
        /*if(this.currentAccount != this.selectedMarkerValue){
            console.log('selectedMarkerValue',this.selectedMarkerValue);
            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                  objectApiName: "Customer_Connect__c",
                  actionName: "new",
                },
                state: {
                    c__parentId : this.selectedMarkerValue,
                }
              });
        }*/
    };

    handleInputChange(event){
        this.showMap = false;
        setTimeout(() => {
            this.rangeKM = event.detail.value;
            var diff = (this.mapMarkers[0].radius / 1000) - parseInt(this.rangeKM);
            /*this.mapMarkers = JSON.parse(JSON.stringify(this.allData.filter(el => parseInt(el.distance) <= parseInt(this.rangeKM))));  
            this.mapMarkers = this.mapMarkers.map(el => {
                delete el.distance;
                return el;
            });*/
            this.mapMarkers[0].radius = (parseInt(this.rangeKM) * 1000);
            this.zoomLevel = this.zoomLevel + (diff/20);
            this.showMap = true;
        }, 50);
    }
}