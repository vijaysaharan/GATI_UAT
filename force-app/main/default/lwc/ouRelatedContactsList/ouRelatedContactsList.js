import { LightningElement, track, api } from 'lwc';
import getRelatedContacts from '@salesforce/apex/OuRelatedContactsListController.getRelatedContacts';

const columns = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, 
        target: '_blank'},
        sortable: true,
        wrapText : true
    },
    { 
        label: 'Staff Code', 
        fieldName: 'StaffCode__c'
    },
    { 
        label: 'Staff Designation', 
        fieldName: 'BANK_BRANCH_NAME__c'
    },
    { 
        label: 'Mobile', 
        fieldName: 'MobilePhone', 
        type: 'phone' 
    },
    { 
        label: 'Email', 
        fieldName: 'Email', 
        type: 'email' 
    },
];

export default class OuRelatedContactsList extends LightningElement {
    @api recordId;
    @track data;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    get isdata(){
        return this.data && this.data.length>0 ? true : false;
    }
   
    get contactListSize(){
        return this.data != null ? this.data.length : '0';
    }

    connectedCallback(){
        getRelatedContacts({recordId : this.recordId}).then(res => {
            console.log('Data=>',JSON.stringify(res,null,2));
            this.data = JSON.parse(JSON.stringify(res)).map(ele =>{
                ele['nameUrl']= '/'+ele.Id;
                return ele;
            });
            console.log('Data After URL=>',JSON.stringify(res,null,2));
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
}