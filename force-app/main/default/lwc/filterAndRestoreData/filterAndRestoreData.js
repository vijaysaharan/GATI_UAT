import getColumn from '@salesforce/apex/FilterAndRestoreData.getColumn';
import getFilteredData from '@salesforce/apex/FilterAndRestoreData.getFilteredData';
import getObjectName from '@salesforce/apex/FilterAndRestoreData.getObjectName';
import getSearchFields from '@salesforce/apex/FilterAndRestoreData.getSearchFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllFields from '@salesforce/apex/FilterAndRestoreData.getAllFields';
import { api, LightningElement, track } from 'lwc';

export default class FilterAndRestoreData extends LightningElement {

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

    @api fieldToShow;
    @track objNameToShow = [];
    selectedObject = null;
    @track searchFields = []
    showSearchFields = false;
    showDatatable = false;
    @track columns = [];
    selectedPage = 1;
    noOfPages = 0;
    searchValue = '' ;
    rowOffset = 0;
    disablePrevious = true;
    disableNext = false;
    disableLast = false;
    disableFirst = true;
    isLoading = true;
    totalRecordCount = 0;
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    @track data = [];
    @track filteredList = [];
    @track searchedList = [];
    pageLimit = 5;
    selectedRowPageWise = new Map();
    selectedRecordsList = [];
    totalselected = 0;
    

    connectedCallback(){
        this.getTheObjectName();
    }

    getTheObjectName(){
        getObjectName().then(res=>{
            if(res != null){
                var objNameList = res;
                var objList = [{
                    label : '---NONE---',
                    value : null
                }];
                objNameList.forEach(element => {
                    var obj = {
                        label : element,
                        value : element
                    }
                    objList.push(obj);
                });
                this.objNameToShow = objList;
            }else{
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'No record in metadata',
                    variant : 'error'
                });
                this.dispatchEvent(event);
            }
        })
    }

    selectObjectOnChangeHandle(event){
        this.selectedObject = event.detail.value;
        if(this.selectedObject == null){
            this.showSearchFields = false;
        }else{
            this.getSearchFields(this.selectedObject);
        }
    }

    getSearchFields(objectName){
        getSearchFields({objectName : objectName}).then(res=>{
            if(res!=null){
                var typeMap = new Map(this.dataMap);
                var index = 0;
                res.forEach(element => {
                    element.typeOfField = typeMap.get(element.typeOfField);
                    if(element.typeOfField == 'checkbox'){
                        element['isCheck'] = true;
                    }else{
                        element['isCheck'] = false;
                    }
                    element['value'] = '';
                    element['index'] = index;
                    if(index==0){
                        element['isDisable'] = false;
                    }else{
                        element['isDisable'] = true;
                    }
                    index++;
                });
                this.searchFields = res;
                this.showSearchFields = true;
            }else{
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message: 'No filter to Show',
                    variant : 'error'
                });
                this.dispatchEvent(event);
            }
        })
    }

    inputChangeHandle(event){
        var objList = this.searchFields;
        var leng = objList.length;
        var index = event.currentTarget.dataset.id;
        var data = event.detail.value;
        objList[index].value = data;
        if(data == ''){
            for(var i=parseInt(index)+parseInt(1);i<objList.length;i++){
                objList[i].isDisable = true;
            }
        }else{
            for(var i=parseInt(index)+parseInt(1);i<objList.length;i++){
                if(i==parseInt(index)+parseInt(1) && objList[i].value == ''){
                    objList[i].isDisable = false;
                    break;
                }else if(objList[i].value != ''){
                    objList[i].isDisable = false;
                }
                if(i!=parseInt(index)+parseInt(1) && objList[i].value == ''){
                    if(objList[i-1].value != ''){
                        objList[i].isDisable = false;
                    }
                    break;
                }
            }
        }
        this.searchFields = objList;
    }

    handleSearchClick(){
        var listToSend = this.searchFields.filter(ele => ele.isDisable!=true && ele.value!='');
        if(listToSend.length >0){
            console.log(JSON.stringify(listToSend));
            getFilteredData({inputString : JSON.stringify(listToSend) ,objectName: this.selectedObject}).then(res=>{
                if(res.length > 0){
                    this.data = res;
                    var index = 1;
                    this.data.forEach(ele =>{
                        ele['index'] = index;
                        index +=1;
                    })
                    this.totalRecordCount = this.data.length;
                    this.filteredList = res;
                    this.searchedList = res;
                    this.pagination();
                    getColumn({objectName : this.selectedObject}).then(res=>{
                        if(res!=null){
                            this.columns = JSON.parse(res);
                            this.showDatatable = true;
                        }
                    })
                }else{
                    const event = new ShowToastEvent({
                        title: 'Error!',
                        message: 'No record found!',
                        variant : 'error'
                    });
                    this.dispatchEvent(event);
                }
            })
        }
    }

    pagination(){
        this.noOfPages = Math.ceil(this.data.length/this.pageLimit);
        this.filteredList = this.searchedList.slice(0,this.pageLimit);
        this.isLoading = false;
    }

    handleNext(){
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
        this.pageChangeSelectSet();
    }


    handlePrevious(){
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
        this.pageChangeSelectSet();
    }

    handleFirst(){
        this.isLoading = true;
        this.disablePrevious = true;
        this.disableFirst = true;
        this.disableNext = false;
        this.disableLast = false;
        this.selectedPage = 1;
        this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
        this.rowOffset = (this.selectedPage-1)*this.pageLimit;
        this.isLoading = false;
        this.pageChangeSelectSet();
    }

    handleLast(){
        this.isLoading = true;
        this.disablePrevious = false;
        this.disableFirst = false;
        this.disableNext = true;
        this.disableLast = true;
        this.selectedPage = this.noOfPages;
        this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
        this.rowOffset = (this.selectedPage-1)*this.pageLimit;
        this.isLoading = false;
        this.pageChangeSelectSet();
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

    handleSelect(){
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        var indexList = [];
        selectedRecords.forEach(element => {
            indexList.push(element.index.toString());
        });
        this.selectedRowPageWise.set(this.selectedPage,Array.from(indexList));
        var temp = [];
        this.selectedRowPageWise.forEach((value,key) => {
            temp = temp.concat(Array.from(value));
        });    
        this.totalselected = temp.length;
        this.selectedRecordsList = temp;
    }

    pageChangeSelectSet(){
            var temp = [];
            this.selectedRowPageWise.forEach((value,key) => {
            temp = temp.concat(Array.from(value));
            });
            this.selectedRecordsList = temp;
    }

    selectAllHandle(){
        var tempToApply = [];
        var check = 1;
        var forPage = 1;
        var temp =[];
        this.data.forEach(ele=>{
            tempToApply.push(ele.index.toString());
            if(check<this.pageLimit){
                temp.push(ele.index.toString());
                if(ele.index == this.data.length){
                    this.selectedRowPageWise.set(forPage, temp);
                }
                check++;
            }else{
                temp.push(ele.index.toString());
                this.selectedRowPageWise.set(forPage, temp);
                temp = [];
                forPage +=1;
                check = 1;
            }
        });
        this.selectedRecordsList = tempToApply;
        this.totalselected = tempToApply.length;
    }

    deselectAllHandle(){
        this.selectedRecordsList = [];
        this.totalselected = 0;
        this.selectedRowPageWise.clear();
    }

    createAndDownloadCsv(){
        getAllFields({objectName : this.selectedObject}).then(res=>{
            if(this.totalselected>0){
                var csvString = '';
                var colLength = res.length;
                var i = 0;
                res.forEach(element => {
                    if( i != colLength-1){
                        csvString += element.label+',';
                    }else{
                        csvString += element.label+'\n';
                    }
                    i++;
                });
                this.data.forEach(element => {
                    if(this.selectedRecordsList.includes(element.index.toString())){
                        i=0;
                        res.forEach(elementCol => {
                            if( i != colLength-1){
                                csvString += '"'+ (element[elementCol.fieldName]!=undefined?element[elementCol.fieldName]:'') + '"' +',';
                            }else{
                                csvString += '"'+ (element[elementCol.fieldName]!=undefined?element[elementCol.fieldName]:'') + '"' +'\n';
                            }
                            i++; 
                        });
                    }
                });
                var element = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
                let downloadElement = document.createElement('a');
                downloadElement.href = element;
                downloadElement.target = '_self';
                downloadElement.download = 'Restore Data.csv';
                document.body.appendChild(downloadElement);
                downloadElement.click();
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error!',
                    message: 'No record is selected to export!',
                    variant : 'error'
                }));
            }
        })        
    }
}