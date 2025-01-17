import { LightningElement,api,track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRates from '@salesforce/apex/ProspectivePickupGetRates_Outbound.proCallOut';
import getRates1 from '@salesforce/apex/ProspectivePickupGetRates_Outbound.proCallOut2';

const columns = [
    { label: 'Product Code', fieldName: 'PROD_CODE' , type: 'text'},
    { label: 'Product Description', fieldName: 'PROD_DESC', type: 'text' },
    { label: 'Charge Description', fieldName: 'CHARGE_DESC', type: 'text' },
    { label: 'Charge Code', fieldName: 'CHARGE_CODE' , type: 'text'},
    { label: 'Charge Amount', fieldName: 'CHARGE_AMT', type: 'currency',
                typeAttributes: { currencyCode: 'INR', step: '0.001' },
                cellAttributes:{class:'slds-p-right_xx-small'} },
    { label: 'Charged Weight', fieldName: 'CHARGED_WT' , type: 'text' },
    { label: 'Transit Days', fieldName: 'TRANSIT_DAYS' , type: 'text'}
];

const columns2 = [
    { label: 'Product', fieldName: 'PROD_DESC' , type: 'text'},
    { label: 'Charged Weight', fieldName: 'CHARGED_WT' , type: 'text' },
    { label: 'Transit Days', fieldName: 'TRANSIT_DAYS' , type: 'text'},
    { label: 'Charge Amount', fieldName: 'CHARGE_AMT', type: 'currency',
                typeAttributes: { currencyCode: 'INR', step: '0.001' },
                cellAttributes:{class:'slds-p-right_xx-small'}},
    { label: 'Add Gst', fieldName: 'ADD GST', type: 'currency',
                typeAttributes: { currencyCode: 'INR', step: '0.001' },
                cellAttributes:{class:'slds-p-right_xx-small'}}     
];


export default class ProspectPickupGetRatesRates extends LightningElement {

@api recordId='5009D000003OZelQAG';
@track GemsRateDetails;
@track GemsRateDetails2;
@track error;
columns = columns;
columns2 = columns2;
showdataTable=false;
@wire(getRates, { caseid: '$recordId' }) GemsRateDetail (val){
       if (val.data) {
           this.GemsRateDetails = val.data;
           console.log(val.data);
           this.showdataTable = true;
           getRates1({ respList: this.GemsRateDetails })
           .then(result => {
               this.GemsRateDetails2 = result;
               console.log('result :' + JSON.stringify(result) );
           })
           .catch(error => {
               
           })
       } else if (val.error) {
           
           console.log(val.error.body.message);
            const filterChangeEvent = new CustomEvent('showerror', {
            detail: val.error.body.message
        });
        // Fire the custom event
        this.dispatchEvent(filterChangeEvent);
       /*const evt = new ShowToastEvent({
            title: 'Sync Error',
            message: error,
            variant: 'error',
        });
        this.dispatchEvent(evt); */  
 
       }
   }
/*
showdataTable(){
    console.log('in function');
    getRates({ caseid:this.recordId}).then(response =>{
            console.log(response.toString());
            this.GemsRateDetails =response;
            this.showdataTable = true;

    });
    this.showdataTable = true;

}*/
}