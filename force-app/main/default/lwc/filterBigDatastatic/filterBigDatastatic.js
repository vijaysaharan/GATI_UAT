import { LightningElement,track } from 'lwc';
import getDataInRange from '@salesforce/apex/FilterBigDataStaticController.getDataInRange';
import getCsvFlag from '@salesforce/apex/FilterBigDataStaticController.getCsvFlag';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';

export default class FilterBigDatastatic extends LightningElement {
    fromDate;
    toDate;
    disableSubmit = false;
    isLoading = false;
    @track caseCsvString = '';
    @track objectName = '';
    channelName = '/event/ProvideCsv__e';
    @track check = 0;

    connectedCallback(){
        this.alreadyDownload = false;
        this.handleSubscribe();
    }

    handelsubmit(){
        this.disableSubmit = true;
        // this.isLoading = true;
        // console.log((this.toDate - this.fromDate));


        const date1 = new Date(this.fromDate);
        const date2 = new Date(this.toDate);
        const diffTime = Math.abs(date2 - date1);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));


        if(this.toDate < this.fromDate){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'From date is greater then to date.',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
        }else if(diffDays >5){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Date range can not be greater then 5 days.',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
        }else if(this.toDate == '' || this.toDate == undefined || this.fromDate == '' || this.fromDate == undefined){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Date range can not empty.',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
        }else{
            getDataInRange({fromDate:this.fromDate, toDate:this.toDate}).then().catch(err=>{
                console.log(err);
            });
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'Be patience! The data will be downloaded in a while.',
                variant : 'success'
            });
            this.dispatchEvent(event);
        }
    }

    fromDateChange(event){
        this.fromDate = event.detail.value;
        
        const date1 = new Date(this.fromDate);
        const date2 = new Date(this.toDate);
        const diffTime = Math.abs(date2 - date1);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));


        if(this.toDate < this.fromDate){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'From date is greater than to date.',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
            this.fromDate = '';
        }else if(diffDays >5){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Date range can not be greater than 5 days.',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
            this.fromDate = '';
        }else if(Math.ceil( Math.abs(new Date() - new Date( this.fromDate)) / (1000 * 60 * 60 * 24))<=0){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Date can not be of future or today',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
            this.fromDate = '';
        }
        
    }

    toDateChange(event){
        this.toDate = event.detail.value;
        
        const date1 = new Date(this.fromDate);
        const date2 = new Date(this.toDate);
        const diffTime = Math.abs(date2 - date1);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));


        if(this.toDate < this.fromDate){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'From date is greater than to date.',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
            this.toDate = '';
        }else if(diffDays >5){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Date range can not be greater than 5 days.',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
            this.toDate = '';
        }else if(Math.ceil( Math.abs(new Date() - new Date( this.toDate)) / (1000 * 60 * 60 * 24))<=0){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Date can not be of future or today',
                variant : 'error'
            });
            this.dispatchEvent(event);
            this.disableSubmit = false;
            this.toDate = '';
        }
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = function (response) {
            // console.log('New message received: ' + JSON.stringify(response.data.payload.csvString__c));
            if(response.data.payload.csvString__c != null){
                if(response.data.payload.isHeader__c){
                    this.caseCsvString = response.data.payload.csvString__c + '\n';
                }else{
                    this.caseCsvString += response.data.payload.csvString__c + '\n';
                }
            }

            if(this.check == undefined){
                this.check = 0 + parseInt(response.data.payload.endCheck__c);
            }
           else{
                this.check = this.check + parseInt(response.data.payload.endCheck__c)
            }

            this.objectName = response.data.payload.ObjectName__c;
            // console.log('isLast----->' + response.data.payload.IsLast__c );
            if(response.data.payload.IsLast__c == true){
               
                // setTimeout(()=>{
                    getCsvFlag().then(res=>{
                        // console.log('res---->' + res);
                        // console.log('check-->' + this.check)
                        if(res == true && this.check == 0){
                            // var hiddenElement = document.createElement('a');  
                            // console.log('when exporting--->'+this.caseCsvString);
                            // console.log(encodeURI(this.caseCsvString).length);
                            // hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(this.caseCsvString);  
                            // hiddenElement.target = '_blank';  
                            // //provide the name for the CSV file to be downloaded  
                            // hiddenElement.download = this.objectName + '.csv';  
                            // hiddenElement.click();  
                           

                            const blob = new Blob([this.caseCsvString], { type: 'text/plain' });
 
                            // Creating an object for downloading url
                            const url = window.URL.createObjectURL(blob)
                         
                            // Creating an anchor(a) tag of HTML
                            const a = document.createElement('a')
                         
                            // Passing the blob downloading url
                            a.setAttribute('href', url)
                         
                            // Setting the anchor tag attribute for downloading
                            // and passing the download file name
                            a.setAttribute('download', this.objectName + '.csv');
                            this.disableSubmit = false;
                            this.isLoading = false;
                         
                            // Performing a download with click
                            a.click()

                           
                        }
                    })
                // },30000)
            }
            // Response contains the payload of the new message received
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
        //    console.log('Its nothing');
        });
    }
}