import { LightningElement,track,api } from 'lwc';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OwnerToChange from '@salesforce/resourceUrl/OwnerToChange';
import CSVData from '@salesforce/apex/BulkAccountTeamMember.csvData';

var doc;
let dissave;
export default class AccountTeamMemberLWC extends NavigationMixin(LightningElement) {

    get records() {
        this.visiblerecords

    }
    get showtable() {
        console.log('showtable===>',this.dataresults);
        if (this.dataresults)
            return true;
        else
            return false;

    }
    @track visiblerecords;
    @track loading = false;
    @api strDelimiter = ',';
    @api fileData;
    parserInitialized = false;
    showSave = false;
    @track comboval = 'none';
    headers = [];
    @track rowsTotal = [];
    @track columns;
    @track sho = false;
    @track documents;
    @track dissave = false;
    @track showError = false;
    dataresults;
    totaldata;
    isSpninner = false;
    isSuccessError = false;
    isDisabled = false;
    @api recordId;
    /*@track check = {
        TransferOwnedOpenCases: true
    }*/
    @track dataResults = [];

    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    console.log('parser initialization is done')
                    this.parserInitialized = true;

                })
                .catch(error => console.error(error));
        }
    }
    connectedCallback() {

    }

    handleTransferOwnedOpenCases(event) {
        /*this.selectedAccountIds = [];
        if (event.target.checked) {
            // Get all the Account IDs from the data results
            this.selectedAccountIds = this.dataresults.map(obj => obj.obj.Id);
        }*/
        if (event.target.checked) {
            console.log('Test===============>',this.dataResults)
            CSVData({ data: this.dataResults })
                .then(result => {
                    // Handle the returned result here
                    console.log('check result',result);
                    // Perform the logic to transfer cases related to the account
                    const relatedCases = result.filter(data => data.done && data.obj && data.obj.Id);
                    if (relatedCases.length > 0) {
                        const caseIds = relatedCases.map(caseData => caseData.obj.Id);
                        this.transferCases(caseIds);
                    }
                })
                .catch(error => {
                    // Handle the error here
                    console.error(error);
                });
        }
    }
    

    handlecsvUpload(event) {
        console.log(event.detail.files[0])
        let file = event.detail.files[0];
        this.dissave = false;
        this.loading = true;
        this.ParseFile(file).then(data1 => {
            this.loading = false;
            this.sho = true;
            this.showSave = true;
            this.columns = data1.meta.fields.reduce((acc, curr) => {
                let temp = {};
                temp["label"] = curr;
                temp["fieldName"] = curr;
                temp["type"] = "text";
                acc.push(temp);
                return acc;

            }, []);

            this.rowsTotal = data1.data;
            this.totaldata = data1;

        })
    }
    updateData(event) {
        let rec = event.detail.records;
        console.log('data from child ' + JSON.stringify(rec));
        this.visiblerecords = [...rec];
    }

    save(event) {
        this.isSpninner = true;
        this.dissave = true;
        console.log(this.totaldata.data);

        CSVData({ data: this.totaldata.data}).then(data => {
            this.dataresults = data;
            console.log('data is ' + JSON.stringify(data));
            //this.dataresults =JSON.stringify(data);
            console.log('this.dataresults ' + this.dataresults);
            this.isSpninner = false;
            this.isSuccessError = true;
        }).catch(error => {
            console.log('-- error occcur when csv upload--', error);
            this.showToast(error, 'Please Correct the CSV Data', error);
        })
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
    flatenData(obj, finalobj) {

        for (let key in obj) {
            if (typeof(obj[key]) == 'object') {
                this.flatenData(obj[key], finalobj);
            } else {
                finalobj[key] = obj[key];
            }
        }
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
    //back_to_prev_screen
    closeModal() {
        window.history.back();
    }

    //re-direct to specific screen or recordpage
    cancel() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Account",
                actionName: "list"
            },
            state: {
                filterName: "Recent"
            }
        })
    }

    download(event) {
        var baseUrl = 'https://' + location.host;
        window.open(baseUrl + OwnerToChange);

    }

    //success log creating
    handleSuccessLog() {
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        doc += '<th>' + 'Id' + '</th>';
        doc += '<th>' + 'Name' + '</th>';
        doc += '<th>' + 'GATI_Customer_Code__c' + '</th>';
        doc += '<th>' + 'OwnerService_Resource__c' + '</th>';
        doc += '</tr>';
        // fill data in scv file
        this.dataresults.forEach(element => {
            if (element.done == true) {
                doc += '<tr>';
                doc += '<td>' + element.Id + '</td>';
                doc += '<td>' + element.obj.Name + '</td>';
                doc += '<td>' + element.obj.GATI_Customer_Code__c + '</td>';
                doc += '<td>' + element.obj.Service_Resource__c + '</td>';
                doc += '</tr>';
            }
        });

        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'accountBulkOwnerUploadedSuccess.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

        handleErrorLog() {
            let doc = '<table>';
            // Add styles for the table
            doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        doc += '<th>' + 'Id' + '</th>';
        doc += '<th>' + 'Name' + '</th>';
        doc += '<th>' + 'GATI_Customer_Code__c' + '</th>';
        doc += '<th>' + 'Service_Resource__c' + '</th>';
        doc += '</tr>';
        
        // fill data in scv file
        this.dataresults.forEach(element => {
            if (element.done == false && element.title != 'Account Already Updated..!') {

                doc += '<tr>';
                doc += '<td>' + element.Id + '</td>';
                doc += '<td>' + element.obj.Name + '</td>';
                doc += '<td>' + element.obj.GATI_Customer_Code__c + '</td>';
                doc += '<td>' + element.obj.Service_Resource__c + '</td>';
                doc += '</tr>';
            }
        });
        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'accountBulkOwnerUploadedError.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}