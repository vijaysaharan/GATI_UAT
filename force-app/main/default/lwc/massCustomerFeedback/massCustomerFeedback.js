import { LightningElement,track,api } from 'lwc';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OwnerToChange from '@salesforce/resourceUrl/CSAT_Template';
import CSVData from '@salesforce/apex/MassFeedbackController.csvData';

import {subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

var doc;
let dissave;

export default class MassCustomerFeedback extends NavigationMixin(LightningElement) {
    get records() {
        this.visiblerecords
        
    }
    get showtable() {
        if (this.dataresults)
        return true;
        else
        return false;
        
    }
    @track visiblerecords;
    @track loading = false;
    @api strDelimiter = ',';
    @api fileData;
    parserInitialized = false;
    showSave = false;
    @track comboval = 'none';
    headers = [];
    @track rowsTotal = [];
    @track columns;
    @track sho = false;
    @track documents;
    @track dissave = false;
    @track showError = false;
    totaldata;
    isSpninner = false;
    isSuccessError = false;
    isDisabled = false;
    @api recordId;
    /*@track check = {
        TransferOwnedOpenCases: true
    }*/
    @track dataresults = [];
    
    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
            .then(() => {
                console.log('parser initialization is done')
                this.parserInitialized = true;
                
            })
            .catch(error => console.error(error));
        }
    }
    connectedCallback() {
        
    }
    
    handlecsvUpload(event) {
        console.log(event.detail.files[0])
        let file = event.detail.files[0];
        this.dissave = false;
        this.loading = true;
        this.ParseFile(file).then(data1 => {
            this.loading = false;
            this.sho = true;
            this.showSave = true;
            this.columns = data1.meta.fields.reduce((acc, curr) => {
                let temp = {};
                temp["label"] = curr;
                temp["fieldName"] = curr;
                temp["type"] = "text";
                acc.push(temp);
                return acc;
                
            }, []);
            
            this.rowsTotal = data1.data;
            this.totaldata = data1;
            
        })
    }
    updateData(event) {
        let rec = event.detail.records;
        console.log('data from child ' + JSON.stringify(rec));
        this.visiblerecords = [...rec];
    }
    
    save(event) {
        this.isSpninner = true;
        this.dissave = true;
        console.log('Check this.totaldata.data',this.totaldata.data);
        
        CSVData({ data: this.totaldata.data}).then(data => {
            this.isSpninner = false;
            this.isSuccessError = true;
            this.handleSubscribe();
            if(!this.isSpninner){
                this.showToast('Success', 'Email Sent!', 'success');
            }
        }).catch(error => {
            console.log('-- error occcur when csv upload--', error);
            this.showToast(error, 'Please Correct the CSV Data', error);
        })
    }
    ParseFile(file) {
        return new Promise(resolve => {
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true   ',
                skipEmptyLines: true,
                complete: (results) => {
                    resolve(results)
                    
                }
            })
        });
    }
    flatenData(obj, finalobj) {
        
        for (let key in obj) {
            if (typeof(obj[key]) == 'object') {
                this.flatenData(obj[key], finalobj);
            } else {
                finalobj[key] = obj[key];
            }
        }
    }
    showToast(mess, tit, vari) {
        const event = new ShowToastEvent({
            title: tit,
            message: mess,
            variant: vari,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    //back_to_prev_screen
    closeModal() {
        window.history.back();
    }
    
    //re-direct to specific screen or recordpage
    cancel() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Account",
                actionName: "list"
            },
            state: {
                filterName: "Recent"
            }
        })
    }
    
    download(event) {
        var baseUrl = 'https://' + location.host;
        window.open(baseUrl + OwnerToChange);
        
    }
    
    //success log creating
    handleSuccessLog() {
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        doc += '<th>' + 'Id' + '</th>';
        doc += '<th>' + 'Name' + '</th>';
        doc += '<th>' + 'Customer Code' + '</th>';
        doc += '<th>' + 'Contact Name' + '</th>';
        doc += '<th>' + 'Email' + '</th>';
        doc += '<th>' + 'Result' + '</th>';
        doc += '</tr>';
        // fill data in scv file
        console.log('this.dataresults @195:', JSON.stringify(this.dataresults,null,2));
        this.dataresults.forEach(element => {
            if (element.done == true) {
                console.log('element.done',element.done)
                doc += '<tr>';
                doc += '<td>' + element?.Id + '</td>';
                doc += '<td>' + element?.contact.Account?.Name + '</td>';
                doc += '<td>' + element?.contact.Account?.GATI_Customer_Code__c + '</td>';
                doc += '<td>' + element?.contact?.Name + '</td>';
                doc += '<td>' + element?.contact?.Email + '</td>';
                doc += '<td>' + element?.result + '</td>';
                doc += '</tr>';
            }
        });
        
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'MassFeedbackSuccess.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
    
    handleErrorLog() {
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        doc += '<th>' + 'Id' + '</th>';
        doc += '<th>' + 'Name' + '</th>';
        doc += '<th>' + 'Customer Code' + '</th>';
        doc += '<th>' + 'Contact Name' + '</th>';
        doc += '<th>' + 'Email' + '</th>';
        doc += '<th>' + 'Result' + '</th>';
        doc += '</tr>';
        
        // fill data in scv file
        console.log('this.dataresults @232:', JSON.stringify(this.dataresults,null,2));
        this.dataresults.forEach(element => {
            console.log(element.done,element.title);
            if (element.done == false) {
                console.log('Inside IF',element.done,element.title);
                doc += '<tr>';
                doc += '<td>' + element?.Id + '</td>';
                doc += '<td>' + element?.contact.Account?.Name + '</td>';
                doc += '<td>' + element?.contact.Account?.GATI_Customer_Code__c + '</td>';
                doc += '<td>' + element?.contact?.Name + '</td>';
                doc += '<td>' + element?.contact?.Email + '</td>';
                doc += '<td>' + element?.result + '</td>';
                doc += '</tr>';
            }
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'MassFeedbackError.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
    
    channelName = '/event/Customer_Feedback_Email_Status__e';
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            //console.log(JSON.stringify(response.data.payload, null, 2));
            console.log(0);
            let Id = response.data.payload.Account_Id__c;
            console.log(1);
            let done = response.data.payload.done__c;
            console.log(2);
            let contact = JSON.parse(response.data.payload.Contact__c); 
            console.log(3);
            let result = response.data.payload.Result__c;
            console.log(4);
            let title = response.data.payload.Title__c;
            console.log(5);
            let obj = {
                Id, done, contact, result, title
            };
            console.log(JSON.stringify(obj, null, 2));
            if (Array.isArray(this.dataresults)) {
                this.dataresults.push(obj);
                console.log('dataresults', JSON.stringify(this.dataresults, null, 2));
            } else {
                console.error('this.dataresults is not defined or not an array.');
            }
        };
        
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log('Successfully subscribed to channel:', this.channelName);
        }).catch(error => {
            console.error('Error subscribing to channel:', error);
        });
    }
}