import { LightningElement, track, wire , api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getNotesDetails from '@salesforce/apex/RoleHierarchyUtility.getNotesDetails';
import upsertNotes from '@salesforce/apex/RoleHierarchyUtility.upsertNotes';
import getTradeData from '@salesforce/apex/SalesDashboardController.getTradeData';
import { gql, graphql } from "lightning/uiGraphQLApi";

export default class UpAndDownTradeDashboard extends LightningElement {
    @api dateList;
    @api sortList = 'desc';
    @api heading;

    isSpinner = false;
    isDataAvailable = false;    
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
            label: 'MTD', 
            fieldName: 'Month_Till',
            cellAttributes: { alignment: 'right' },
        },
        { 
            label: 'LMTD', 
            fieldName: 'Last_Month_Till',
            cellAttributes: { alignment: 'right' },
        },
        { 
            label: 'Difference', 
            fieldName: 'Diff_MTD_LMTD',
            cellAttributes: { alignment: 'right' },
        },
        { 
            label: 'MOM%', 
            fieldName: 'MOM%',
            cellAttributes: { alignment: 'right' },
        },
        { 
            label: 'YTD', 
            fieldName: 'Year_Till',
            cellAttributes: { alignment: 'right' },
        }
    ];
        // { 
        //     label: 'Note', 
        //     fieldName: 'Note_body',
        //     editable: true,
        // }

    @track currentMonthYear;
    @track dashBoardData = [];
    @track contractData = [];
    @track userOptionSelected = [];
    @track accountTypesSelected = [];
    @track zoneOptionSelected = ['DELZ','CCUZ','BOMZ','BLRZ'];
    
    get isContractData(){
        return this.contractData.length > 0 ? true : false;
    }

    @api refreshDashboard(){
            this.currentMonthYear = this.getMonthYearFromDate(this.dateList?.currentMonthStart);
            this.userOptionSelected = this.dateList?.userOptionSelected;
            this.zoneOptionSelected = this.dateList?.zoneOptionSelected;
            this.accountTypesSelected = this.dateList?.accountTypesSelected;
            this.handleGetTradeData();
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

    getMonthYearFromDate(dateString){
        let dateValue = new Date(dateString);
        return dateValue.toLocaleString('default', { month: 'short' }).toUpperCase()+'-'+dateValue.getFullYear();
    }

    handleGetTradeData(){
        var whereData = {
          'sortingMethod' : this.sortList,
          'userSelectedIds' : this.userOptionSelected,
          'zoneSelectedList' : this.zoneOptionSelected,
          'accountTypesSelected' : this.accountTypesSelected,
          'monthYear': this.currentMonthYear
        };
        getTradeData({whrClause : whereData}).then(cusData => {
            //console.log('cusData ',JSON.stringify(cusData,null,2));
            let resultData = cusData.map(ele =>{
                return {
                    'Contract_Id' : ele?.ContractName__r?.Id,
                    'Contract_Name' : ele?.ContractName__r?.Name,
                    'Contract_Number' : ele?.ContractName__r?.Contract_Number__c,
                    'Month_Till' : (ele?.RevenueMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0}),
                    'Last_Month_Till' : (ele?.RevenueLMTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0}),
                    'Diff_MTD_LMTD' : (ele?.UpDownTrade__c).toLocaleString('en-IN', {maximumFractionDigits: 0}),
                    'Year_Till' : (ele?.RevenueYTD__c).toLocaleString('en-IN', {maximumFractionDigits: 0}),
                    'MOM%' : ele?.MoM__c,
                    'nameUrl' : '/'+  ele?.ContractName__r?.Id
                }
            });
            this.dashBoardData = JSON.parse(JSON.stringify(resultData));
            this.contractData = JSON.parse(JSON.stringify(resultData));
            //this.dataFormation();
            //this.handleSort();
        }).catch(err => {
          this.toastMessageDispatch('TRADE ERROR',err?.body?.message,'error');
        });
      }

    dataFormation(){
        let contractIds = [];
        let tempContractData = [];
        tempContractData = JSON.parse(JSON.stringify(this.dashBoardData));
        this.dashBoardData.forEach(elm => {
            if(elm.Contract_Id){
                contractIds.push(elm.Contract_Id);
            }
        });
        if(contractIds.length > 0 && contractIds != null){
            getNotesDetails({contractId : contractIds}).then(data => {
                data.forEach(dt => {
                    this.notesRecords[dt.ParentId] = dt;
                });
                tempContractData.forEach(elm => {
                    if(this.notesRecords[elm.Contract_Id]){
                        elm.Note_body = this.notesRecords[elm.Contract_Id].Body;
                    }
                    else{
                        elm.Note_body = '';
                    }
                });
                this.contractData = tempContractData;
                this.isDataAvailable = false;
                this.isSpinner = false;
            }).catch(err => {
                this.toastMessageDispatch('Error In Notes Getting!',err?.body?.message,'error');
            });
        }
        if(this.contractData.length == 0){
            this.isDataAvailable = true;
        }
    }

    handleSave(event){
        let NotesListToUpsert = [];
        event.detail.draftValues.forEach((item) => {
            let tempNote = {
                sobjectType: 'Note'
            };
            if(this.notesRecords[item.Contract_Id]){
                tempNote['Id'] = this.notesRecords[item.Contract_Id].Id;
                tempNote['Title'] = this.notesRecords[item.Contract_Id].Title;
            }
            tempNote['ParentId'] = item.Contract_Id;
            tempNote['Body'] = item.Note_body;
            tempNote['Title'] = 'Comment';
            NotesListToUpsert.push(tempNote);
        });
        if(NotesListToUpsert && NotesListToUpsert.length > 0){
            upsertNotes({notesData : NotesListToUpsert}).then(res => {
                if(res){
                    this.toastMessageDispatch('Note Taken!','Your Note is stored regarding this contract.','success');  
                }
            }).catch(err => {
                this.toastMessageDispatch('Note Not Taken!',err?.body?.message,'error');
            });
        }
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

    handleSort() {
        var sortDirection = 'desc';
        var sortedBy = 'Month_Till';
        var cloneData = [...this.contractData];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.contractData = cloneData;
    }
}