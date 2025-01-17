import { LightningElement, api, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HandleLogEvent extends LightningElement {

    subscription = {};
    @api channelName = '/event/ProvideCsv__e';

    connectedCallback() {
        console.log('event subscribe');
        this.handleSubscribe();
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
            console.log(JSON.parse(JSON.stringify(response)))
            var obj = JSON.parse(JSON.stringify(response));
            let objData = obj.data.payload;
            const platformEventData = new CustomEvent('errorrecive', {
                detail: { data : objData.csvString__c }
            });
            this.dispatchEvent(platformEventData);
        };
 
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response));
            this.subscription = response;

        });
    }
}