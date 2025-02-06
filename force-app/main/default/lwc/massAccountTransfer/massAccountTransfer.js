import { LightningElement, wire, track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import OwnerToChange from '@salesforce/resourceUrl/OwnerToChange';
import getAllUsers from '@salesforce/apex/ApexJobController.getAllUsers';
import OwnerToChangeFromContract from '@salesforce/resourceUrl/OwnerToChangeFromContract';
import MassBatchCallForTransfer from '@salesforce/apex/ApexJobController.MassBatchCallForTransfer';

export default class MassAccountTransfer extends NavigationMixin(LightningElement) {
    @api channelName = '/event/ProvideCsv__e';

    @track selectedUserIdforTransfer = '';
    @track selectedUserIdToTransfer = '';
    @track errorCsv = '"Customer Code","Error"\n';
    @track tableData;
    @track columnData;
    @track showProgressChart = false;
    @track check = {
        EnforceNewOwnerHasReadAccess: true,
        KeepAccountTeam: true,
        KeepSalesTeam: true,
        TransferContacts: true,
        TransferContracts: true,
        TransferNotesAndAttachments: true,
        TransferOpenActivities: true,
        TransferOrders: true,
        TransferOwnedOpenCases: true,
        TransferOwnedOpenOpportunities: true
    }

    subscription = {};
    labelToApi = new Map();
    showTabe = false;
    isSuccessError = false;
    showErrorButton = false;
    isDisabled = false;
    BatchJobId;
    userOptions = [];
    accountTypeValue = 'Customer Code';
    accountTypeList = [
        {
            label : 'Customer Code',
            value : 'Customer Code'
        },
        {
            label : 'Contract',
            value : 'Contract Number'
        }
    ];

    @wire(getAllUsers)
    usersResult({ error, data }) {
        if (data) {
            this.userOptions = data.map(user => ({
                label: user.Name,
                value: user.Id
            }));
        } 
        else if (error) {
            this.showToast('Error', error.body.message, 'error');
        }
    }

    connectedCallback(){
        if(this.accountTypeValue == 'Contract Number'){
            this.labelToApi.set('CONTRACT NUMBER', 'customerCode');
        }else{
            this.labelToApi.set('CUSTOMER CODE', 'customerCode');
        }
        this.labelToApi.set('NEWUSER', 'newUser');
        this.handleSubscribe();
        this.registerErrorListener();
    }

    handleAccountTypeChange(event){
        this.accountTypeValue = event.detail.value;
        if(this.accountTypeValue == 'Contract Number'){
            this.labelToApi.set('CONTRACT NUMBER', 'customerCode');
        }
        else{
            this.labelToApi.set('CUSTOMER CODE', 'customerCode');
        }
    }
    handleCsvError(event){
        this.showToast('Error', event.detail.errorMessage, 'error');
    }
    handleSubscribe() {
        const self = this;
        const messageCallback = function (response) {
            self.errorCsv = self.errorCsv+response.data.payload.csvString__c+','+'\n';
            self.showErrorButton = true;
        };
        subscribe(this.channelName, -1, messageCallback).then(response => {
            this.subscription = response;
        });
    }
    registerErrorListener() {
        onError(error => {
            console.log('Server Error: ', JSON.stringify(error));
        });
    }
    download() {
        var baseUrl = 'https://' + location.host;
        if(this.accountTypeValue == 'Contract Number'){
            window.open(baseUrl + OwnerToChangeFromContract);
        }
        else{
            window.open(baseUrl + OwnerToChange);
        }
    }
    handleFileUpload(event){
        this.tableData = event.detail.tableData;
        this.columnData = event.detail.columnData;
        this.showTabe = true;
    }
    handleValueSelectedFromUser(event) {
        this.selectedUserIdforTransfer = event.detail.Id;
    }
    handleValueSelectedToUser(event) {
        this.selectedUserIdToTransfer = event.detail.Id;
    }
    handleRecordSelectionFirst(event) {
        this.checkboxFirst = event.detail.value;
        this.check['EnforceNewOwnerHasReadAccess'] = this.checkboxFirst;
    }
    handleRecordSelectionSecond(event) {
        this.checkboxSecond = event.detail.value;
        this.check['KeepAccountTeam'] = this.checkboxFirst;
    }
    handleRecordSelectionThird(event) {
        this.checkboxThird = event.detail.value;
        this.check['KeepSalesTeam'] = this.checkboxFirst;
    }
    handleRecordSelectionFourth(event) {
        this.checkboxFourth = event.detail.value;
        this.check['TransferContacts'] = this.checkboxFirst;
    }
    handleRecordSelectionSixth(event) {
        this.checkboxSixth = event.detail.value;
        this.check['TransferNotesAndAttachments'] = this.checkboxFirst;
    }
    handleRecordSelectionSeventh(event) {
        this.checkboxSeventh = event.detail.value;
        this.check['TransferOpenActivities'] = this.checkboxFirst;
    }
    handleRecordSelectionTenth(event) {
        this.checkboxTenth = event.detail.value;
        this.check['TransferOwnedOpenOpportunities'] = this.checkboxFirst;
    }

    handleTransfer() {
        this.isSuccessError = true;
        //var tabset = this.template.querySelector('lightning-tabset');
        var mapTosend = {};
        this.tableData.forEach(element => {
            if(mapTosend[element.newUser] == undefined){
                mapTosend[element.newUser] = [element.customerCode];
            }
            else{
                mapTosend[element.newUser] = [ ...mapTosend[element.newUser],element.customerCode];
            }
        });
        MassBatchCallForTransfer({wrapp : this.check, ownerData : mapTosend,isContract : this.accountTypeValue })
        .then((res)=>{
            this.BatchJobId = res;
            this.isDisabled = true;
            this.showProgressChart = false;
            setTimeout(() => {
                this.showProgressChart = true;
                this.showToast('Batch Called','Your Batch Called Successfully','Success');
            }, 100);
        });
        /*if(tabset.activeTabValue == 'tab-1'){
            //Above Code
        }
        else{
            if(this.selectedUserIdforTransfer !== this.selectedUserIdToTransfer){
                var obj = {
                    newUser : this.selectedUserIdToTransfer,
                    oldUser : this.selectedUserIdforTransfer
                }
                MassBatchCallForTransfer({wrapp : this.check, ownerData : [obj], isContract : this.accountTypeValue})
                .then((res)=>{
                this.BatchJobId = res;
                this.isDisabled = true;
                this.showProgressChart = false;
                setTimeout(() => {
                    this.showProgressChart = true;
                    // this.isDisabled = false;
                    this.showToast('Batch Called','Your Batch Called Successfully','Success');
                }, 100)
                })

            }
        }*/
    }
    handlecomplete(){
        this.isDisabled = false;
    }

    handleCancel() {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'home'
                },
            });
    }

    handleErrorCsv(event){
        this.errorCsv += event.data;
    }

    handleDownloadErrorCSV(){
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(this.errorCsv);
        downloadElement.target = '_self';
        downloadElement.download = 'Error.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}