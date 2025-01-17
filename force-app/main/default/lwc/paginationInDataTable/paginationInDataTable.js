import { LightningElement, api, track } from 'lwc';

export default class PaginationInDataTable extends LightningElement {

    @api pageLimit = 5;
    @api columns = [];
    @api forTable = [];
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
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    isLoading = false;
    
    connectedCallback(){
        this.filteredList = this.forTable;
        this.searchedList = this.forTable;
        this.pagination();
    }



    pagination(){
        this.noOfPages = Math.ceil(this.forTable.length/this.pageLimit);
        this.filteredList = this.searchedList.slice(0,this.pageLimit);
        this.showTable = true;
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
        const cloneforTable = [...this.searchedList];

        cloneforTable.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.searchedList = cloneforTable;
        this.filteredList = this.searchedList.slice((this.selectedPage-1)*this.pageLimit,this.selectedPage*this.pageLimit);
        this.rowOffset = (this.selectedPage-1)*this.pageLimit;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}