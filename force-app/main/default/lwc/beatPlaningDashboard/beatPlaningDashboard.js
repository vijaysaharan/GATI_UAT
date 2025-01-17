import getAccountData from '@salesforce/apex/BeatPlaningDashboard.getAccountData';
import get360Data from '@salesforce/apex/BeatPlaningDashboard.get360Data';
import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import ACCOUNT_TYPE from "@salesforce/schema/Account.Customer_Category__c";
import GATI_POTENTIAL from "@salesforce/schema/Account.Monthly_Spend_on_Logistic__c";
import UserId from "@salesforce/user/Id";

export default class BeatPlaningDashboard extends NavigationMixin(LightningElement)  {
    @track accountData = [];
    @track filterAccountData = [];
    @track accountType = [];
    @track potential = [];
    @track data360;
    @track selectedAccountFor360;
    userFilters = [
        {label : 'All Account', value : 'ALL'},
        {label : 'My Account', value : UserId }
    ];
    zoanPickListValue = [
        {label : 'All', value : 'ALL'},
        {label : 'DELZ' , value : 'DELZ'},
        {label : 'BLRZ' , value : 'BLRZ'},
        {label : 'BOMZ' , value : 'BOMZ'},
        {label : 'CCUZ' , value : 'CCUZ'},
    ]
    selectedAccountType = 'ALL';
    selectedUserType = 'ALL';
    selectedZone = 'ALL';
    selectedPotential = 'ALL';
    showModal = false;
    showSpinner = false;

    @track sortHandle = {
        DaysSince : 1,
        lastVisitedBy : 1,
        lastVisitedDate : 1,
        GatiPotential : 1,
        ownerName : 1,
        categoryName : 1,
        Name : 1,
        rpoOwnerName : 1,
    }
    

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ACCOUNT_TYPE })
    getType({ data, error }) {
        if (data) {
            this.accountType = data.values;
            this.accountType = this.accountType.filter( pickListValue => (pickListValue.value != 'Partner' && pickListValue.value != 'Retail') );
            this.accountType = [({label : 'ALL', value : 'ALL'}), ...this.accountType ];
        }
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: GATI_POTENTIAL })
    getZone({ data, error }) {
        if (data) {
            this.potential = data.values;
            this.potential = [({label : 'ALL', value : 'ALL'}), ...this.potential ];
        }
    }

    connectedCallback(){
        this.showSpinner = true;
        getAccountData().then( accountDataRes => {
            if ( Object.keys(accountDataRes).length > 0 ) {
                this.accountData = Object.values(accountDataRes);
                this.accountData.forEach(account => {
                    account['ownerName'] = account?.account?.Owner?.Name;
                    account['rpoOwnerName'] = account?.account?.Owner?.Manager?.Name;
                    account['categoryName'] = account?.account?.Customer_Category__c;
                });
                this.handleFilterProcess();
            } else {
                this.accountData = [];
                this.handleFilterProcess();
            } 
            console.log('this.accountData',this.accountData);
        })
    }

    get showAccountData() {
        return this.filterAccountData && this.filterAccountData.length > 0;
    }

    get numberOfAccount() {
        if (this.filterAccountData){
            return this.filterAccountData.length;
        } else {
            return null;
        }
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
            window.open(url, "_blank");
        });
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

    handleZoneFilter(event){
        var selectedValue = event.detail.value;
        this.selectedZone = selectedValue;
        this.handleFilterProcess();
    }

    handleTypeFilter(event){
        var selectedValue = event.detail.value;
        this.selectedAccountType = selectedValue;
        this.handleFilterProcess();
    }

    handleUserFilter(event){
        var selectedValue = event.detail.value;
        this.selectedUserType = selectedValue;
        this.handleFilterProcess();
    }

    handlePotentialFilter(event){
        var selectedValue = event.detail.value;
        this.selectedPotential = selectedValue;
        this.handleFilterProcess();
    }

    handleFilterProcess(){
        var filterViaType = this.accountData.map(account => account.Id);
        if( this.selectedAccountType != 'ALL' )
            filterViaType = this.accountData.filter( account => account.account.Customer_Category__c == this.selectedAccountType).map( account => account.Id);

        var filterViaUser = this.accountData.map(account => account.Id);
        if( this.selectedUserType != 'ALL' )
            filterViaUser = this.accountData.filter( account => account.account.OwnerId == this.selectedUserType).map( account => account.Id);

        var filterViaZone = this.accountData.map(account => account.Id);
        if( this.selectedZone != 'ALL' )
            filterViaZone = this.accountData.filter( account => account.account.Zone_Name__c == this.selectedZone).map( account => account.Id);

        var filterViaPotential = this.accountData.map(account => account.Id);
        if( this.selectedPotential != 'ALL' )
            filterViaPotential = this.accountData.filter( account => account.GatiPotential == this.selectedPotential).map( account => account.Id);
    
        
        this.filterAccountData = this.accountData.filter( account => filterViaType.includes(account.Id) && filterViaUser.includes(account.Id) && filterViaZone.includes(account.Id) && filterViaPotential.includes(account.Id));
        this.filterAccountData = this.filterAccountData.sort(this.sortBy('DaysSince',-1));
        this.showSpinner = false;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    handleSort(event){
        var labelToSort = event.currentTarget.dataset.label;
        this.filterAccountData = this.filterAccountData.sort(this.sortBy(labelToSort,this.sortHandle[labelToSort]));
        this.sortHandle[labelToSort] = this.sortHandle[labelToSort] * -1;
    }

    handleShowCurrentBusiness(event){
        var accountId = event.currentTarget.dataset.id;
        get360Data({accountId : accountId}).then( data360Response => {
            this.data360 = data360Response;
            this.selectedAccountFor360 = this.accountData.filter(account => account.Id == accountId)[0];
            this.showModal = true;
            console.log('this.data360',this.data360);
        })
    }

    handleCloseModel(){
        this.data360 = {};
        this.showModal = false;
    }
}