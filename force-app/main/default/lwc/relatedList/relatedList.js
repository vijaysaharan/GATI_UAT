import getColumn from '@salesforce/apex/RelatedListController.getColumn';
import getData from '@salesforce/apex/RelatedListController.getData';
import deleteRecord from '@salesforce/apex/RelatedListController.deleteRecord';
import viewRecord from '@salesforce/apex/RelatedListController.viewRecord';
import getConfigData from '@salesforce/apex/RelatedListController.getConfigData';
import createCsv from '@salesforce/apex/RelatedListController.createCsv';
//import getRestoreMapping from '@salesforce/apex/RelatedListController.getRestoreMapping';
import insertSobject from '@salesforce/apex/RelatedListController.insertSobject';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api, LightningElement, track } from 'lwc';

export default class RelatedList extends LightningElement {

    dataMap = [
        ['address','text'],
        ['anytype','text'],
        ['base64','text'],
        ['boolean','checkbox'],
        ['combobox','text'],
        ['currency','number'],
        ['datacategorygroupreference','text'],
        ['date','date'],
        ['datetime','datetime'],
        ['double','number'],
        ['email','email'],
        ['encryptedstring','text'],
        ['id','text'],
        ['integer','number'],
        ['location','text'],
        ['long','number'],
        ['multipicklist','text'],
        ['percent','text'],
        ['phone','tel'],
        ['picklist','text'],
        ['reference','text'],
        ['string','text'],
        ['textarea','text'],
        ['time','time'],
        ['url','url']
    ];
    dataMapforDatatable = [
        ['address','text'],
        ['anytype','text'],
        ['base64','text'],
        ['boolean','boolean'],
        ['combobox','text'],
        ['currency','currency'],
        ['datacategorygroupreference','text'],
        ['date','date'],
        ['datetime','date'],
        ['double','number'],
        ['email','email'],
        ['encryptedstring','text'],
        ['id','text'],
        ['integer','number'],
        ['location','text'],
        ['long','number'],
        ['multipicklist','text'],
        ['percent','percent'],
        ['phone','phone'],
        ['picklist','text'],
        ['reference','text'],
        ['string','text'],
        ['textarea','text'],
        ['time','time'],
        ['url','url']
    ];
    dataTypes;
    dataTypeForDatatable;




    @api relatedObjectName;
    @api relatedFieldList;
    @api relatedLookup;
    @api recordId;
    @api pageLimit = 5;
    @track columns = [];
    @track data = [];
    @track filteredList = [];
    @track searchedList = [];
    selectedPage = 1;
    noOfPages = 0;
    searchValue = '' ;
    rowOffset = 0;
    disablePrevious = true;
    disableNext = false;
    disableLast = false;
    disableFirst = true;
    isLoading = false;
    totalRecordCount = 0;
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    actions = [
        { label: 'View', name: 'View' },
        { label: 'Delete', name: 'Delete' },
        { label: 'View Related Records', name: 'View Related Records' },
    ];
    @api bigObjectIndex;
    showModel = false;
    @track dataToView = [];
    isBigObj = false;
    @api restoreTo;
    viewRelatedRecord = false;
    idToPass = '';
    childData;
    idField;
    @track selectedRecordsList = [];
    showTable = true;
    disableDownload = false;
    @track activeSections = [];
    



    connectedCallback(){
        if(this.bigObjectIndex != '' && this.bigObjectIndex != undefined){
            this.isBigObj = true;
        }
        this.dataTypes = new Map(this.dataMap);
        this.dataTypeForDatatable = new Map(this.dataMapforDatatable);
        this.getAllData();
       
    }

    // addEventListnerToTable(){
    //     const records = this.template.querySelectorAll('lightning-base-formatted-text') // add a class to your records
    //     // records.forEach(record => {
    //     //     record.addEventListener('click', function(e){
    //     //     e.preventDefault(); // you don't want the default behavior
    //     // // your code goes here
    //     //     console.log({ e })
    //     //     });
    //     // });
    // }

    getAllData(){
        getConfigData({relatedObjectName : this.relatedObjectName , relatedLookup : this.relatedLookup,recordId : this.recordId}).then(resp=>{
            var res = JSON.parse(resp);
            this.data = res.data;
            this.relatedFieldList = res.relatedfieldList;
            var index = 1;
            this.data.forEach(ele =>{
                ele['index'] = index;
                index +=1;
            })
            this.bigObjectIndex = res.indexField;
            this.totalRecordCount = this.data.length;
            this.filteredList = res.data;
            this.searchedList = res.data;
            this.childData = res.childRelation;
            this.idField = res.idField;
            this.createCloumn();
        }).catch(err=>{
            console.log(err);
        })
    }

    createCloumn(){
        getColumn({relatedObjectName: this.relatedObjectName, fieldsApiName: this.relatedFieldList.split(',')}).then(res=>{
            this.columns = JSON.parse(res).map(ele=>{
                var obj = {
                    label : ele.label,
                    fieldName : ele.fieldName,
                    sortable : ele.sortable,
                    type : this.dataTypeForDatatable.get(ele.typeOfField.toLowerCase()) 
                }
                return obj;
            });
            this.columns.push({
                type: 'action',
                typeAttributes: { rowActions: this.actions },
            });
            this.pagination();
        }).catch(err=>{
            console.log(err);
        })
    }

    
    handleSearch(event){
        this.searchValue = event.target.value;
        if(this.searchValue == ''){
            this.rowOffset = 0;
            this.selectedPage = 1;
            this.searchedList = this.data;
            this.pagination();
        }
    }

    // selectElementFunction(){
    //     var selectedList = this.template.querySelector('lightning-datatable').getSelectedRows();
    //     var selectedIndex = [];
    //     selectedIndex = selectedList.map(ele=>{
    //         return ele.index;
    //     })
    //     var notSelectedRowInSearchedList = this.filteredList.filter(ele => !selectedIndex.includes(ele.index));
    //     var notSelectedIndexInSearchedList = notSelectedRowInSearchedList.map(ele=>{
    //         return ele.index;
    //     })
    //     this.showTable = false;
    //     this.selectedRecordsList = this.selectedRecordsList.filter(ele => !notSelectedIndexInSearchedList.includes(ele.index));
    //     this.selectedRecordsList = this.selectedRecordsList.concat(selectedIndex);
    //     // console.log('selectedIndex------->' + selectedIndex);
    //     // console.log('not selected index ------------>' + notSelectedIndexInSearchedList);
    //     // console.log('final list---------->'+ this.selectedRecordsList);
    // }

    handleSearchClick(){
        // this.selectElementFunction();
        if(this.searchValue != ''){
            this.isLoading = true;
            this.searchedList = [];
            this.searchedList = this.data.filter(ele =>{
                if(Object.values(ele).toString().toLowerCase().includes(this.searchValue.toLowerCase())){
                    return true;
                }else{
                    return false;
                }
            });
            this.rowOffset = 0;
            this.selectedPage = 1;
            this.pagination();
        }else{
            this.isLoading = true;
            this.searchedList = this.data;
            this.pagination();
        }
        this.showTable = true;
    }

    pagination(){
        this.noOfPages = Math.ceil(this.data.length/this.pageLimit);
        this.filteredList = this.searchedList.slice(0,this.pageLimit);
        this.isLoading = false;
    }

    handleNext(){
        // this.selectElementFunction();
        if(this.selectedPage != this.noOfPages){
            this.disablePrevious = false;
            this.disableFirst = false;
            this.disableLast = false;
            this.selectedPage++;
            this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
            this.rowOffset = (this.selectedPage-1)*this.pageLimit;
        }else{
            this.disableNext = true;
            this.disableLast = true;
        }
        this.showTable = true;
    }


    handlePrevious(){
        // this.selectElementFunction();
        if(this.selectedPage != 1){
            this.disableNext = false;
            this.disableFirst = false;
            this.disableLast = false;
            this.selectedPage--;
            this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
            this.rowOffset = (this.selectedPage-1)*this.pageLimit;
        }else{
            this.disablePrevious = true;
            this.disableFirst =true;
        }
        this.showTable = true;
    }

    handleFirst(){
        // this.selectElementFunction();
        this.isLoading = true;
        this.disablePrevious = true;
        this.disableFirst = true;
        this.disableNext = false;
        this.disableLast = false;
        this.selectedPage = 1;
        this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
        this.rowOffset = (this.selectedPage-1)*this.pageLimit;
        this.isLoading = false;
        this.showTable = true;
    }

    handleLast(){
        // this.selectElementFunction();
        this.isLoading = true;
        this.disablePrevious = false;
        this.disableFirst = false;
        this.disableNext = true;
        this.disableLast = true;
        this.selectedPage = this.noOfPages;
        this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
        this.rowOffset = (this.selectedPage-1)*this.pageLimit;
        this.isLoading = false;
        this.showTable = true;
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

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.searchedList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.searchedList = cloneData;
        this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
        this.rowOffset = (this.selectedPage-1)*this.pageLimit;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }


    handleRowAction(event){
        this.isLoading = true;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'View':
                this.handleViewRowAction(row);
                break;
            case 'Delete':
                this.handleDeleteRowAction(row);
                break;
            case 'View Related Records':
                this.handleViewRelatedRecord(row);
                break;
            default:
        }
    }

    handleViewRelatedRecord(row){
        this.idToPass = row[this.idField];
        this.viewRelatedRecord = true;
        this.isLoading = false;
    }

    handleViewRelatedRecordCancel(){
        this.viewRelatedRecord = false;
    }

    handleViewRowAction(row){
        viewRecord({bigObjectIndex : this.bigObjectIndex, relatedObjectName : this.relatedObjectName, recordString : JSON.stringify(row)}).then(res=>{
            var temp = JSON.parse(res);
            temp.forEach(ele1 => {
                this.activeSections.push(ele1.sectionLabel);
                ele1.sectionData = ele1.sectionData.map(ele=>{
                    ele.typeOfField = this.dataTypes.get(ele.typeOfField);
                    if(ele.typeOfField == 'checkbox' || ele.data == 'true' || ele.data == 'false' ){
                        ele['isCheck'] = true;
                        ele.data = ele.data == 'true'?true:false;
                    }else{
                        ele['isCheck'] = false;
                    }
                    return ele;
                })
            })
            // cahnges to show layout
            
            this.dataToView = temp;
            this.showModel = true;
            this.isLoading = false;
        }).catch(err=>{
            const event = new ShowToastEvent({
                title: 'Error!',
                message: 'Please contact your System administrator.' ,
                variant: 'error'
            });
            this.dispatchEvent(event);
            this.isLoading = false;
        })
    }

    handleDeleteRowAction(row){
        deleteRecord({relatedFieldList : this.relatedFieldList, recordTodelete : row, relatedObjectName : this.relatedObjectName, bigObjectIndex : this.bigObjectIndex}).then(res=>{
            if(res){
                var objIndex = this.data.findIndex(obj => JSON.stringify(obj) === JSON.stringify(row));
                this.data.splice(objIndex,1);
                this.totalRecordCount = this.data.length;
                this.searchedList = this.data;
                var newNoOfpages = Math.ceil(this.data.length/this.pageLimit);
                if(this.noOfPages != newNoOfpages){
                    this.noOfPages = newNoOfpages;
                    this.selectedPage -=1;
                }
                this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
                this.rowOffset = (this.selectedPage-1)*this.pageLimit;
                this.isLoading = false;
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'record deleted successfully!',
                    variant: 'success'
                });
                this.dispatchEvent(event);
            }
        }).catch(err=>{
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: 'Error!',
                message: err.body.message,
                variant: 'error'
            });
            this.dispatchEvent(event);
        })
    }

    // handleDataTabelClick(event){
    //     console.log(event);
    // }

    handleModelClose(){
        this.showModel = false;
    }

    // handleResote(){
    //     getRestoreMapping({restoreFrom : this.relatedObjectName, restoreTo : this.restoreTo}).then(res=>{
    //         var fieldMapping = new Map(JSON.parse(res.MappingLabelToApi__c));
    //         var record = {
    //             sobjectType : this.restoreTo,
    //         }
    //         this.dataToView.forEach(element => {
    //             if(fieldMapping.has(element.apiName)){
    //                 record[fieldMapping.get(element.apiName)] = element.data;
    //             } 
    //         });
    //         this.insertDataToSobject(record);
    //     }).catch();
    // }


    // insertDataToSobject(record){
    //     insertSobject({s : record}).then(res=>{
    //         if(res){
    //             const event = new ShowToastEvent({
    //                 title: 'Success!',
    //                 message: 'Record restored successfully!',
    //                 variant: 'success'
    //             });
    //             this.dispatchEvent(event);
    //             this.handleModelClose();
    //         }
    //     }).catch(err=>{
    //         const event = new ShowToastEvent({
    //             title: 'Error!',
    //             message: err.message,
    //             variant: 'error'
    //         });
    //     })
    // }

    handleCsvClick(){
        this.disableDownload = true;
        createCsv({parentId : this.recordId, relatedObjectName : this.relatedObjectName}).then(res=>{
            var headerset = Object.keys(res.StoB);
            var csvString =  headerset.join(',')+'\n';
            var bigObjList = res.data;
            if(res.data.length > 0){
                var noOfFields = headerset.length;
                var noOfRecords = bigObjList.length;
                var i = 0;
                var j = 0;
                while (j<noOfFields){
                    if(bigObjList[i][res.StoB[headerset[j]]] != undefined){
                        csvString +=  '"' +(bigObjList[i][res.StoB[headerset[j]]].toString().replace(/[&<>'"]/g, '') )+ '",';
                    }else{
                        csvString +=  '"' + '",';
                    }
                    if(j == noOfFields-1){
                        csvString = csvString + '\n';
                        if(i!=noOfRecords-1){
                            j = 0;
                            i++;
                            continue;
                        }
                    }
                    j++; 
                }

                const blob = new Blob([csvString], { type: 'text/plain' });
 
                // Creating an object for downloading url
                const url = window.URL.createObjectURL(blob)
             
                // Creating an anchor(a) tag of HTML
                const a = document.createElement('a')
             
                // Passing the blob downloading url
                a.setAttribute('href', url)
             
                // Setting the anchor tag attribute for downloading
                // and passing the download file name
                a.setAttribute('download', this.relatedObjectName + '.csv');
                // Performing a download with click
                a.click()
                this.disableDownload = false;
            }
        })
    }
    

}