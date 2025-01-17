import { LightningElement, track, api } from 'lwc';
import getRelatedCases from '@salesforce/apex/DocketNumberRelatedListForCaseController.getRelatedCases';

const columns = [
    {
        label: 'Number',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'CaseNumber' }, 
        target: '_blank'},
        sortable: true,
        wrapText : true
    },
    { 
        label: 'Status', 
        fieldName: 'Status'
    },
    { 
        label: 'Date', 
        fieldName: 'CreatedDate'
    }
    
];

export default class DocketNumberRelatedListForCase extends LightningElement {
    @api recordId;
    @track data;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    get isdata(){
        return this.data && this.data.length>0 ? true : false;
    }
   
    get caseListSize(){
        return this.data != null ? this.data.length : '0';
    }

    connectedCallback(){
        getRelatedCases({recordId : this.recordId}).then(res => {
            console.log('Data=>',JSON.stringify(res,null,2));
            this.data = JSON.parse(JSON.stringify(res)).map(ele =>{
                ele['nameUrl']= '/'+ele.Id;
                ele.CreatedDate = this.convertDateFormat(ele.CreatedDate);
                return ele;
            });
            console.log('Data After URL=>',JSON.stringify(this.data,null,2));
        }).catch(err =>{
            console.log('Error=>',JSON.stringify(err,null,2));
        });
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
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    convertDateFormat(dateString) {
        const date = new Date(dateString);
        const day = date.getDate().toString().padStart(2, '0');
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const year = date.getFullYear();
        return `${day}-${month}-${year}`;
    }
}