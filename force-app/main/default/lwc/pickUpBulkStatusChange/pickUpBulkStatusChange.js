import { LightningElement, track, wire , api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import PICKUP_CASES from '@salesforce/resourceUrl/BulkPickupCaseTemplate';
import { loadScript } from 'lightning/platformResourceLoader';
import CsvDataHandler from '@salesforce/apex/BulkPickupCaseStatusChangeController.csvDataHandler';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PickUpBulkStatusChange extends NavigationMixin(LightningElement) {
    parserInitialized = false;
    isloading = false;

    @track columns;
    @track rowsTotal = [];
    @track dataresults = [];
    @track dataForResult = [];
    errorList;
    successList;
   
    get isDataUploaded(){
        return this.rowsTotal.length > 0 ? true : false;
    }
    get saveDisabled(){
        return this.rowsTotal.length > 0 && this.dataForResult.length == 0 ? false : true;
    }
    get isDataProcessed(){
        return ((this.errorList != null && this.errorList != '') || (this.successList != null && this.successList != '')) ? true : false;
    }

    columnsForResult = [
        {
            label: 'Case Number',
            fieldName: 'CaseNumber'
        },
        {
            label: 'Docket Number',
            fieldName: 'DocketNumber'
        },
        {
            label: 'Pickup Status',
            fieldName: 'PickupStatus'
        },
        {
            label: 'Pickup Date',
            fieldName: 'PickupDate'
        },
        {
            label: 'Case Status',
            fieldName: 'Status'
        },
        {
            label: 'Message',
            fieldName: 'Message'
        }       
    ];

    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
            .then(() => {
                this.parserInitialized = true;
            })
            .catch(error => console.error(error));
        }
    }

    downloadDummy(){
        var baseUrl = 'https://' + location.host;
        window.open(baseUrl + PICKUP_CASES);
    }
    cancel(){
        this.rowsTotal = [];
        this.dataForResult = [];
        this.successList = '';
        this.errorList = '';
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Case",
                actionName: "list"
            },
            state: {
                filterName: "Recent"
            }
        });
    }

    handlecsvUpload(event){
        let file = event.detail.files[0];
        this.ParseFile(file).then(data1 => {
            this.columns = data1.meta.fields.reduce((acc, curr) => {
                let temp = {};
                temp["label"] = curr;
                temp["fieldName"] = curr;
                temp["type"] = "text";
                acc.push(temp);
                return acc;                
            }, []);
            this.rowsTotal = data1.data;
        });

    }

    ParseFile(file) {
        return new Promise(resolve => {
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true   ',
                skipEmptyLines: true,
                complete: (results) => {
                    resolve(results)
                }
            })
        });
    }

    handleSave(event){
        this.isloading = true;
        CsvDataHandler({csvDataList : JSON.stringify(this.rowsTotal)}).then(res => {
            if(res){
                this.successList = res?.successHeader+res?.successData;
                this.errorList = res?.errorHeader+res?.errorData;
                let listOfDataSuccess = res?.successData?.split('\n');
                if(listOfDataSuccess){
                    delete listOfDataSuccess[listOfDataSuccess?.length-1];
                }
                let listOfDataError = res?.errorData?.split('\n');
                if(listOfDataError){
                    delete listOfDataError[listOfDataError?.length-1];
                }
                let data = ['CaseNumber','DocketNumber','PickupStatus','PickupDate','Status','Message'];
                listOfDataSuccess?.forEach(ele => {
                    let listOfEveryRow = ele?.split(',');
                    let tempObj = {};
                    for(var i=0;i<data.length;i++){
                        tempObj[data[i]] = listOfEveryRow[i];
                    }
                    this.dataForResult.push(tempObj);
                });
                listOfDataError?.forEach(ele => {
                    let listOfEveryRow = ele?.split(',');
                    let tempObj = {};
                    for(var i=0;i<data.length;i++){
                        tempObj[data[i]] = listOfEveryRow[i];
                    }
                    this.dataForResult.push(tempObj);
                });
                this.isloading = false;
            }          
        }).catch(err=>{
            console.log('ERROR',JSON.stringify(err,null,2));
            this.showToast(err,'Error In CSV Process Or Making CSV For Success And Failed.', 'error');
            this.isloading = false;
        });
    }

    handleDownload(event){
        var currentName = event.target.name;
        let data = '';
        if(currentName == 'Failed'){
            data = this.errorList;
        }else if(currentName == 'Success'){
            data = this.successList;
        }
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(data);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'PickupCase'+currentName+'.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    showToast(mess, tit, vari) {
        const event = new ShowToastEvent({
            title: tit,
            message: mess,
            variant: vari,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}