import { LightningElement, track, wire , api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { gql, graphql } from "lightning/uiGraphQLApi";

export default class InactiveAccountsDashboard extends LightningElement {
    @api dateList;
    @api rangeValue = 30;
    @api heading;

    isSpinner = false;
    isDataAvailable = false;
    startRange;
    endRange;
    first = `first : 10
    `;
    whereString = `where : {}
    `;
    orderBy = `orderBy: { X3190Revenue__c: { order: DESC } }
    `;
    draftValues = [];
    notesRecords = {};
    columnsContract = [
        {
            label: 'Contract Name',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Contract_Name' }, 
            target: '_blank'}
        },
        { 
            label: 'Contract Number', 
            fieldName: 'Contract_Number'
        },
        { 
            label: 'Last Trading Date', 
            fieldName: 'Last_Trade'
        },
        { 
            label: 'Last Trading Month Amount', 
            fieldName: 'Last_Amount',
            cellAttributes: { alignment: 'right' }
        },
        { 
            label: 'Revenue(In last 365 days)', 
            fieldName: 'RevenueValue',
            cellAttributes: { alignment: 'right' },
        },
        
    ];

    @track dashBoardData = [];
    @track contractData = [];
    @track userOptionSelected = [];
    @track accountTypesSelected = [];
    @track zoneOptionSelected = ['DELZ','CCUZ','BOMZ','BLRZ'];

    get isContractData(){
        return this.contractData.length > 0 ? true : false;
    }

    connectedCallback(){
        var range = this.getLastTradeDateRange(parseInt(this.rangeValue));
        this.startRange = range.start;
        this.endRange = range.end;
        if(parseInt(this.rangeValue) == 30){
            this.orderBy = `orderBy: { X3190Revenue__c: { order: DESC } }
            `;
        }
        else if(parseInt(this.rangeValue) == 90){
            this.orderBy = `orderBy: { X91180Revenue__c: { order: DESC } }
            `;
        }
        else if(parseInt(this.rangeValue) == 180){
            this.orderBy = `orderBy: { X181365Revenue__c: { order: DESC } }
            `;
        }
    }

    getLastTradeDateRange(NoOfDays){
        const today = new Date();
        var startDate = this.formatDate(new Date(today.getFullYear(),today.getMonth(),today.getDate() - NoOfDays));
        var endDate;
        if(NoOfDays == 30){
            endDate = this.formatDate(new Date(today.getFullYear(),today.getMonth(),today.getDate() - 90));
        }
        else if(NoOfDays == 90){
            endDate = this.formatDate(new Date(today.getFullYear(),today.getMonth(),today.getDate() - 180));
        }
        else if(NoOfDays == 180){
            endDate = this.formatDate(new Date(today.getFullYear(),today.getMonth(),today.getDate() - 360));
        }
        return {
            'start' : startDate,
            'end' : endDate
        };
    }

    formatDate(date) {
        const year = date.getFullYear();
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        return `${year}-${month}-${day}`;
    }

    @api refreshDashboard(){
            this.userOptionSelected = this.dateList?.userOptionSelected;
            this.zoneOptionSelected = this.dateList?.zoneOptionSelected;
            this.accountTypesSelected = this.dateList?.accountTypesSelected;
            this.makeDynamicForCustomerDashboard();
        }

    toastMessageDispatch(title,message,vari){
        const toastMessage = new ShowToastEvent({
            title: title,
            message: message ,
            variant: vari,
            mode: 'dismissable'
        });
        this.dispatchEvent(toastMessage);
    }

    makeDynamicForCustomerDashboard(){
        var temp = `where : {
            LastTradeAmount__c : {gt: 0}
            `;
        if((this.userOptionSelected.length > 0 && this.userOptionSelected[0] != '') || (this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != '') || (this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != '')){
            temp += `AccountName__r : {`;
            if((this.userOptionSelected.length > 0 && this.userOptionSelected[0] != '')){
                temp += `OwnerId : {in : [`;
                this.userOptionSelected.forEach(elm => {
                    temp += `"`+elm+`" ,`;
                });
                temp = temp.slice(0,-1)+`]}
                `;
            }
            if((this.accountTypesSelected.length > 0 && this.accountTypesSelected[0] != '')){
                temp += `Customer_Category__c : {in : [`;
                this.accountTypesSelected.forEach(elm => {
                    temp +=  `"`+elm+`" ,`;
                });
                temp = temp.slice(0, -1) + `]}
                `;
            }
            if((this.zoneOptionSelected.length > 0 && this.zoneOptionSelected[0] != '')){
                temp += `Zone_Name__c : {in : [`;
                this.zoneOptionSelected.forEach(elm => {
                    temp += `"`+elm+`" ,`;
                });
                temp = temp.slice(0, -1) + `]}
                `;
            }
            temp += `}
            `;
        }
        if(this.startRange && this.endRange){
            temp += `and : [
                    {LastTradeDate__c : {gte : {value : "`+this.endRange+`"}}},
                    `;
            temp += `{LastTradeDate__c : {lte : {value : "`+this.startRange+`"}}},
                ]`;
        }
        temp += `}
        `;
        this.whereString = temp;
    }

    @wire(graphql, { query: '$dynamicQueryCustomer' })
    resultOfCustomerDashboard({data, error}){
        if(data && this.userOptionSelected.length > 0){
            let resultData = data.uiapi?.query?.CustomerDashboard__c?.edges.map(ele =>{
                return {
                    'Contract_Id' : ele?.node?.AccountName__r?.Id,
                    'Contract_Name' : ele?.node?.AccountName__r?.Name?.value,
                    'Contract_Number' : ele?.node?.AccountName__r?.Contract_Number__c?.value,
                    'nameUrl' : '/'+  ele?.node?.AccountName__r?.Id,
                    'Last_Trade' : ele?.node?.LastTradeDate__c?.value,
                    'Last_Amount' : (ele?.node?.LastTradeAmount__c?.value).toLocaleString('en-In', {maximumFractionDigits: 0}),
                    'X_31_90_Days_Revenue' : (ele?.node?.X3190Revenue__c?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}),
                    'X_91_180_Days_Revenue' : (ele?.node?.X91180Revenue__c?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}),
                    'X_181_365_Days_Revenue' : (ele?.node?.X181365Revenue__c?.value).toLocaleString('en-IN', {maximumFractionDigits: 0}),
                }
            });
            this.dashBoardData = JSON.parse(JSON.stringify(resultData));
            this.dataFormation();
        }
        if(data){
            this.isSpinner = false;
        }
    }

    get dynamicQueryCustomer() {
        this.isSpinner = true;
        //console.log('customerDashboardQuery ',this.customerDashboardQuery);
        return gql`${this.customerDashboardQuery}`;
    }

    get customerDashboardQuery(){
        return `query getData{
            uiapi{
              query{
                CustomerDashboard__c(`+
                this.first+
                this.whereString+
                this.orderBy+
                `){
                  totalCount
                  edges{
                    node{
                      AccountName__r {
                        Id
                        Name {
                          value
                        }
                        Contract_Number__c{
                          value
                        }
                        Customer_Category__c{
                          value
                        }
                      }
                      LastTradeDate__c {
                        value
                      }
                      LastTradeAmount__c {
                        value
                      }
                      X3190Revenue__c {
                        value
                      }
                      X91180Revenue__c {
                        value
                      }
                      X181365Revenue__c {
                        value
                      }
                    }
                  }
                }
              }
            }
          }`;
    }

    dataFormation(){
        this.dashBoardData.forEach(elm => {
            if(parseInt(this.rangeValue) == 30){
                elm.RevenueValue = elm?.X_31_90_Days_Revenue;
            }
            else if(parseInt(this.rangeValue) == 90){
                elm.RevenueValue = elm?.X_91_180_Days_Revenue;
            }
            else if(parseInt(this.rangeValue) == 180){
                elm.RevenueValue = elm?.X_181_365_Days_Revenue;
            }
        });
        this.contractData = JSON.parse(JSON.stringify(this.dashBoardData));
        this.isDataAvailable = false;
        this.isSpinner = false;
        if(this.contractData.length == 0){
            this.isDataAvailable = true;
        }
    }
}