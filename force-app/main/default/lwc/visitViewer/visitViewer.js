import { LightningElement, api, track } from 'lwc';
import getLocations from '@salesforce/apex/visitViewerController.getLocations';
import getRoleSubordinateUsers from '@salesforce/apex/visitViewerController.getRoleSubordinateUsers';
import getPicklistOptions from '@salesforce/apex/visitViewerController.getPicklistOptions';

export default class VisitViewer extends LightningElement {
    @track isData = false;
    @track isAccount = false;

    whereString = '';
    @track userList = '';
    @track whereClauseData = {
        startDate  : null,
        endDate  : null,
        accLead : null,
        category : null,
    };

    comboValue;
    selectedMarkerValue;
    userOptionList;
    customerCategoryOptions;

    mapMarkers = [
        {
            location: {
                Latitude: '28.6294016',
                Longitude: '77.398016',
                City: 'Noida'
            },
            value: 'SF1',
            icon: 'standard:account',
            title: 'Noida',
            description: 'This is a long description',
        },
    ];

    accountLeadOption = [
        {label : 'Account', value : 'Account'},
        {label : 'Lead', value : 'Lead'}
    ]

    connectedCallback() {
        getRoleSubordinateUsers().then(data=>{
            this.userOptionList = data.map(option => {
                return { label: option.userName, value: option.userId };
            });
            this.isData  = true;
        });
        getPicklistOptions({objectName : 'Account', fieldName : 'Customer_Category__c'}).then(data=>{
            this.customerCategoryOptions = data.map(option => {
                return { label: option, value: option };
            });
        })
        
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        this.whereClauseData.startDate = `${year}-${month}-${day}`;
        this.whereClauseData.endDate = `${year}-${month}-${day}`;

        this.createWhereQuery();
    }

    handleMarkerSelect = (event) => {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
    };

    center = {
        location: this.mapMarkers[0].location,
    };

    createWhereQuery(){
        this.whereString = ' Where Check_In_Time__c != null';
        if(this.whereClauseData.startDate != null){
            this.whereString = this.whereString + ' And Visit_Date__c >= '+this.whereClauseData.startDate;
        }
        if(this.whereClauseData.endDate != null){
            this.whereString = this.whereString + ' And Visit_Date__c <= '+this.whereClauseData.endDate;
        }
        if(this.whereClauseData.category != null){
            this.whereString = this.whereString + ' And Customer_Code__r.Customer_Category__c = \''+this.whereClauseData.category +'\'';
        }
        if(this.whereClauseData.accLead != null){
            if(this.whereClauseData.accLead == 'Account'){
                this.whereString = this.whereString + ' And Customer_Code__c != null';
            }
            if(this.whereClauseData.accLead == 'Lead'){
                this.whereString = this.whereString + ' And Lead__c != null';
            }
        }
        console.log(JSON.stringify(this.whereString));
        this.getAllLocations();
    }

    getAllLocations(){
        getLocations({ whereClause: this.whereString,userList : this.userList}).then(res => {
            console.log('######'+JSON.stringify(res));
            this.mapMarkers = JSON.parse(JSON.stringify(res));
            this.selectedMarkerValue = this.mapMarkers[0].value;
        }).catch(err => {
            console.log('Error In set mapMaker' + JSON.stringify(err));
        });
    }

    handleInputChange(event){
        var fieldChange = event.currentTarget.dataset.name;
        var valueChange = event.detail.value;
        this.whereClauseData[fieldChange] = valueChange;
        if(this.validateAllInputs()){
            this.createWhereQuery();
        }
    }

    handleUserChange(event){
        this.userList = event.detail.value;
        this.createWhereQuery();
    }

    handleAccountLeadChange(event){
        this.whereClauseData.accLead = event.detail.value;
        if(this.whereClauseData.accLead == 'Account'){
            this.isAccount = true;
        }
        else{
            this.isAccount = false;
            this.whereClauseData.category = null;
        }
        this.createWhereQuery();
    }

    handleClear(event){
        console.log('!11111111');
        var fieldId = event.currentTarget.dataset.id;
        console.log(JSON.stringify(fieldId));
        this.whereClauseData[fieldId] = null;
        console.log(JSON.stringify(this.whereClauseData));
        if(this.validateAllInputs()){
            this.createWhereQuery();
        }
    }

    handleUserClear(event){
        this.userList = '';
        this.createWhereQuery();
    }

    validateAllInputs() {
        var returnVariable = true;
        var inputList = this.template.querySelectorAll('lightning-input');
        for (let index = 0; index < inputList.length; index++) {
          const element = inputList[index];
          var validateElement = element.reportValidity();
          if (!validateElement) {
            returnVariable = false;
          }
        }
        var comboList = this.template.querySelectorAll('lightning-combobox');
        for (let index = 0; index < comboList.length; index++) {
          const element = comboList[index];
          var validateElement = element.reportValidity();
          if (!validateElement) {
            returnVariable = false;
          }
        }
        return returnVariable;
      }

}