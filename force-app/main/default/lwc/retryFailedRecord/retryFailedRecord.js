import { LightningElement,api,track } from 'lwc';
import getRelatedFileIds from '@salesforce/apex/RetryFailedRecord.getRelatedFileIds';
import getCsvData from '@salesforce/apex/RetryFailedRecord.getCsvData';
import getBigObjName from '@salesforce/apex/RetryFailedRecord.getBigObjName';
import callbackupBatch from '@salesforce/apex/RetryFailedRecord.callbackupBatch';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class RetryFailedRecord extends LightningElement {
    @api recordId;
    @track listOfCsvIds = [];
    commaSepratedIds = '';
    delayTimeout;
    @track listOfRecordIds = [];
    index = 0;
    bigObjectName;
    
    connectedCallback(){
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            getBigObjName({recordId : this.recordId}).then(res=>{
                this.bigObjectName = res;
            })


            getRelatedFileIds({recordId : this.recordId}).then(res=>{
                this.listOfCsvIds = JSON.parse(res);;
            })
        }, 0);
    }

    getDataOfCsv(){
        getCsvData({csvId : this.listOfCsvIds[this.index].Id}).then(res=>{
            var lines = res.split('\n');
            for(let i in lines){
                if(i!=0){
                    this.listOfRecordIds.push(lines[i].split(',')[0].replace(/"/g,'\''));
                }
            }
            this.index ++;
            if( this.index < this.listOfCsvIds.length){
                this.getDataOfCsv();
            }else{
               callbackupBatch({backupLog : this.bigObjectName, recordIdList : this.listOfRecordIds.filter(ele => ele != '' && ele != null)});
               this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
    }

    okHandel(){
       this.getDataOfCsv();
    }

    cancelHandel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }


}