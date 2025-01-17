import getAccountData from '@salesforce/apex/BeatPlaningDashboard.getAccountData';
import { LightningElement, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_TYPE from "@salesforce/schema/Account.Customer_Category__c";
import UserId from "@salesforce/user/Id";

export default class BeatPlaningAgeingAnalysis extends LightningElement {
    @track accountData = [];
    @track filterAccountData = [];
    @track accountAnalysis = [];
    @track accountType = [];
    @track accountToPass = [];
    userFilters = [
        {label : 'All Account', value : 'ALL'},
        {label : 'My Account', value : UserId }
    ]
    zoanPickListValue = [
        {label : 'All', value : 'ALL'},
        {label : 'DELZ' , value : 'DELZ'},
        {label : 'BLRZ' , value : 'BLRZ'},
        {label : 'BOMZ' , value : 'BOMZ'},
        {label : 'CCUZ' , value : 'CCUZ'},
    ]
    selectedZone = 'ALL';
    selectedAccountType = 'ALL';
    selectedUserType = 'ALL';
    searchedText = '';
    showModal = false;
    selectedOwnerName = '';
    showSpinner = false;

    @track sortHandle = {
        ownerId : 1,
        rpoName : 1,
        ownerName : 1,
        total: 1,
        zeroToFifteen : 1,
        sixteenToThirty : 1,
        thirtyOneToFortyfive: 1,
        fortySixToSixty: 1,
        greaterThanSixty : 1,
    }
    

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: ACCOUNT_TYPE })
    getShipmentType({ data, error }) {
        if (data) {
            this.accountType = data.values;
            this.accountType = this.accountType.filter( pickListValue => pickListValue.value != 'Partner' );
            this.accountType = [({label : 'ALL', value : 'ALL'}), ...this.accountType ];
        }
    }

    connectedCallback(){
        this.showSpinner = true;
        getAccountData().then( accountDataRes => {
            if ( Object.keys(accountDataRes).length > 0 ) {
                this.accountData = Object.values(accountDataRes);
                this.filterAccountData = JSON.parse(JSON.stringify(this.accountData));
            } else {
                this.accountData = [];
                this.filterAccountData = [];
            } 
            this.applyAccountAnalysis();
            console.log(this.accountData);
        })
    }

    get showAccountData() {
        return this.accountAnalysis && this.accountAnalysis.length > 0;
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

    handleOwnerFilter(event){
        this.searchedText = event.detail.value;
        this.handleFilterProcess();
    }

    handleZoneFilter(event){
        var selectedValue = event.detail.value;
        this.selectedZone = selectedValue;
        this.handleFilterProcess();
    }

    handleFilterProcess(){
        var filterViaType = this.accountData.map(account => account.Id);
        if( this.selectedAccountType != 'ALL' )
            filterViaType = this.accountData.filter( account => account.account.Customer_Category__c == this.selectedAccountType).map( account => account.Id);

        var filterViaUser = this.accountData.map(account => account.Id);
        if( this.selectedUserType != 'ALL' )
            filterViaUser = this.accountData.filter( account => account.account.OwnerId == this.selectedUserType).map( account => account.Id);

        var filterViaUserName = this.accountData.map(account => account.Id);
        if( this.searchedText )
            filterViaUserName = this.accountData.filter( account => account.account.Owner.Name.toLowerCase().includes(this.searchedText.toLowerCase())).map( account => account.Id);
        
        var filterViaZone = this.accountData.map(account => account.Id);
        if( this.selectedZone != 'ALL' )
            filterViaZone = this.accountData.filter( account => account.account.Zone_Name__c == this.selectedZone).map( account => account.Id);
    
        this.filterAccountData = this.accountData.filter( account => filterViaType.includes(account.Id) && filterViaUser.includes(account.Id) && filterViaUserName.includes(account.Id) && filterViaZone.includes(account.Id));
        this.applyAccountAnalysis();
    }

    applyAccountAnalysis(){

        if (this.filterAccountData && this.filterAccountData.length > 0) {
            var ownerList = this.filterAccountData.map(account => account.account.OwnerId);
            var ownerToAccountAnalysis = {};
            ownerList.forEach(ownerId => {
                ownerToAccountAnalysis[ownerId] = {
                    ownerId,
                    ownerName : '',
                    rpoName : '',
                    total: 0,
                    zeroToFifteen : 0,
                    sixteenToThirty : 0,
                    thirtyOneToFortyfive: 0,
                    fortySixToSixty: 0,
                    greaterThanSixty : 0,
                    // totalShowAccount: false,
                    // zeroToFifteenShowAccount: false,
                    // sixteenToThirtyShowAccount: false,
                    // thirtyOneToFortyfiveShowAccount: false,
                    // fortySixToSixtyShowAccount: false,
                    // greaterThanSixtyShowAccount: false,
                }
            });
    
            this.filterAccountData.forEach(account => {
                ownerToAccountAnalysis[account.account.OwnerId].ownerName = account.account.Owner.Name;
                ownerToAccountAnalysis[account.account.OwnerId].rpoName = account.account?.Owner?.Manager?.Name;
                ownerToAccountAnalysis[account.account.OwnerId].total += 1;
                if (account.DaysSince <= 15) {
                    ownerToAccountAnalysis[account.account.OwnerId].zeroToFifteen += 1;
                } else if (account.DaysSince > 15 && account.DaysSince <= 30) {
                    ownerToAccountAnalysis[account.account.OwnerId].sixteenToThirty += 1;
                } else if (account.DaysSince > 30 && account.DaysSince <= 45) {
                    ownerToAccountAnalysis[account.account.OwnerId].thirtyOneToFortyfive += 1;
                } else if (account.DaysSince > 45 && account.DaysSince <= 60) {
                    ownerToAccountAnalysis[account.account.OwnerId].fortySixToSixty += 1;
                } else {
                    ownerToAccountAnalysis[account.account.OwnerId].greaterThanSixty += 1;
                }
            });

            this.accountAnalysis = Object.values(ownerToAccountAnalysis);
            this.accountAnalysis = this.accountAnalysis.sort(this.sortBy('ownerName',1));
        } else {
            this.accountAnalysis = [];
        }
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
        this.accountAnalysis = this.accountAnalysis.sort(this.sortBy(labelToSort,this.sortHandle[labelToSort]));
        this.sortHandle[labelToSort] = this.sortHandle[labelToSort] * -1;
    }

    handleOpenPopover(event){
        var popoverToShow = event.currentTarget.dataset.label + 'ShowAccount';
        var ownerId = event.currentTarget.dataset.id;

        this.accountToPass = [];
        switch (popoverToShow) {
            case 'totalShowAccount':
                this.accountToPass = this.accountData.filter(account => account.account.OwnerId == ownerId);
                break;
            case 'zeroToFifteenShowAccount':
                this.accountToPass = this.accountData.filter(account => account.account.OwnerId == ownerId && account.DaysSince <= 15);
                break;
            case 'sixteenToThirtyShowAccount':
                this.accountToPass = this.accountData.filter(account => account.account.OwnerId == ownerId && account.DaysSince > 15 && account.DaysSince <= 30);
                break;
            case 'thirtyOneToFortyfiveShowAccount':
                this.accountToPass = this.accountData.filter(account => account.account.OwnerId == ownerId && account.DaysSince > 30 && account.DaysSince <= 45);
                break;
            case 'fortySixToSixtyShowAccount':
                this.accountToPass = this.accountData.filter(account => account.account.OwnerId == ownerId && account.DaysSince > 45 && account.DaysSince <= 60);
                break;
            case 'greaterThanSixtyShowAccount':
                this.accountToPass = this.accountData.filter(account => account.account.OwnerId == ownerId && account.DaysSince > 60);
                break;
            default:
                break;
        }
        console.log('accountToPass',this.accountToPass);
        // var indexToChange = this.accountAnalysis.findIndex(data => data.ownerId == ownerId);
        // this.accountAnalysis[indexToChange][popoverToShow] = true;
        // console.log(this.accountAnalysis[indexToChange][popoverToShow]);
        // setTimeout(() => {
        //     this.handleDropdownPosition();
        // }, 100);
        var indexToChange = this.accountAnalysis.findIndex(data => data.ownerId == ownerId);
        this.selectedOwnerName =  this.accountAnalysis[indexToChange]['ownerName'];
        this.showModal = true;
    }

    handleDropdownPosition() {
        const screenPadding = 16;
    
        const placeholderRect = this.refs.placeHolder.getBoundingClientRect();
        const dropdownRect = this.template.querySelector('c-beat-planing-ageing-analysis-popover').getBoundingClientRect();
        var dropdown = this.template.querySelector('c-beat-planing-ageing-analysis-popover');

        console.log('dropdownRect',dropdownRect);
    
        const dropdownRightX = dropdownRect.x + dropdownRect.width;
        const placeholderRightX = placeholderRect.x + placeholderRect.width;
    
        if (dropdownRect.x < 0) {
          dropdown.style.left = '0';
          dropdown.style.right = 'auto';
          dropdown.style.transform = `translateX(${-placeholderRect.x + screenPadding}px)`;
        } else if (dropdownRightX > window.outerWidth) {
          dropdown.style.left = 'auto';
          dropdown.style.right = '0';
          dropdown.style.transform = `translateX(${(window.outerWidth - placeholderRightX) - screenPadding}px)`;
        }
      }

      handleCloseModel(){
        this.accountToPass = [];
        this.selectedOwnerName = '';
        this.showModal = false;
      }
}