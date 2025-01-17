import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import get360Data from '@salesforce/apex/BeatPlaningDashboard.get360Data';

export default class BeatPlaningAgeingAnalysisPopover extends NavigationMixin(LightningElement) {
    @api accountListApi;
    @track accountList;
    showModal = false;
    @track data360;
    @track selectedAccountFor360;

    connectedCallback(){
        console.log('pop up log');
        this.accountList = JSON.parse(JSON.stringify(this.accountListApi));
        this.accountList = this.accountList.map(ele => {
            ele['rpoOwnerName'] = ele?.account?.Owner?.Manager?.Name;
            return ele;
        })
    }

    get showAccountData() {
        return this.accountList && this.accountList.length > 0;
    }


    handleAccountRedirect(event){
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId : event.currentTarget.dataset.id,
                objectApiName: 'Account',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    handleRedirectCustomerConnect(event){
        this[NavigationMixin.GenerateUrl]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: 'Customer_Connect__c',
                actionName: 'new'
            },
            state: {
                nooverride : 1,
                defaultFieldValues : encodeDefaultFieldValues({Customer_Code__c : event.currentTarget.dataset.id})
            }
        }).then(url => {
            console.log(url);
            window.open(url, "_blank");
        });
    }

    handleShowCurrentBusiness(event){
        var accountId = event.currentTarget.dataset.id;
        get360Data({accountId : accountId}).then( data360Response => {
            this.data360 = data360Response;
            this.selectedAccountFor360 = this.accountList.filter(account => account.Id == accountId)[0];
            this.showModal = true;
            console.log('this.data360',this.data360);
        })
    }

    handleCloseModel(){
        this.data360 = {};
        this.showModal = false;
    }
}