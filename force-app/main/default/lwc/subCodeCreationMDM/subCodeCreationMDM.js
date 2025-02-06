import { LightningElement , api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import SendSubCodeToMDM from '@salesforce/apex/CreateSubcodeController.SendSubCodeToMDM';

export default class SubCodeCreationMDM extends LightningElement {
    @api channelName = '/event/IntegrationResponse__e';
    @api recordId;

    @track responseStatus;
    get isSuccess(){
        return this.responseStatus == '200' ? true : false;
    }

    connectedCallback(){
        setTimeout(() => {
            this.handleSubscribe();
            this.registerErrorListener();
            SendSubCodeToMDM({recordId: this.recordId}).then(result => {
                console.log('API Callout Done!');
            });
        }, 5000);
    }
    handleSubscribe() {
        subscribe(this.channelName, -1, (response) => {
            this.responseStatus = response?.data?.payload?.StatusCode__c;
            console.log('Response Code:', this.responseStatus);
        }).then(response => {
            console.log('Subscription successful:', response);
        }).catch(error => {
            console.error('Subscription error:', error);
        });
    }
    registerErrorListener() {
        onError(error => {
            console.log('Server Error: ', JSON.stringify(error));
        });
    }
}