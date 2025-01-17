import { LightningElement, track, api, wire } from 'lwc';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { loadScript } from 'lightning/platformResourceLoader';
import CSVData from '@salesforce/apex/BulkUploadLeadController.csvData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BulkLeadTemplate from '@salesforce/resourceUrl/BulkLeadTemplate';



var doc;
let dissave;

export default class LeadBulkUploadLWC extends NavigationMixin(LightningElement) {

    get records() {
        this.visiblerecords

    }
    get showtable() {
        console.log(this.dataresults);
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


    download(event) {
        var baseUrl = 'https://' + location.host;
        window.open(baseUrl + BulkLeadTemplate);

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

        CSVData({ data: this.totaldata.data, casetype: this.comboval }).then(data => {
            this.dataresults = data;
            console.log('data is ' + JSON.stringify(data));
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
                objectApiName: "Lead",
                actionName: "list"
            },
            state: {
                filterName: "Recent"
            }
        })
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
        doc += '<th>' + 'Title' + '</th>';
        doc += '<th>' + 'FirstName' + '</th>';
        doc += '<th>' + 'LastName' + '</th>';
        doc += '<th>' + 'Status' + '</th>';
        doc += '<th>' + 'LeadSource' + '</th>';
        doc += '<th>' + 'Lead_Data__c' + '</th>';
        doc += '<th>' + 'GATI_Company_Code__c' + '</th>';
        doc += '<th>' + 'Product__c' + '</th>';
        doc += '<th>' + 'Customer_Potential__c' + '</th>';
        doc += '<th>' + 'Designation__c' + '</th>';
        doc += '<th>' + 'Company' + '</th>';
        doc += '<th>' + 'Email' + '</th>';
        doc += '<th>' + 'Phone' + '</th>';
        doc += '<th>' + 'MobilePhone' + '</th>';
        doc += '<th>' + 'Street' + '</th>';
        doc += '<th>' + 'City' + '</th>';
        doc += '<th>' + 'State' + '</th>';
        doc += '<th>' + 'PostalCode' + '</th>';
        doc += '<th>' + 'Country' + '</th>';
        doc += '<th>' + 'Cross Sell CFS Locations' + '</th>';
        doc += '<th>' + 'Description' + '</th>';
        doc += '<th>' + 'Cross Sell Lead Status' + '</th>';
        doc += '<th>' + 'Lost Reason' + '</th>';
        doc += '<th>' + 'Cross Sell Description' + '</th>';
        doc += '<th>' + 'Payment Mode' + '</th>';
        doc += '</tr>';
        // fill data in scv file
        this.dataresults.forEach(element => {
            if (element.done == true) {
                doc += '<tr>';
                doc += '<td>' + element.Id + '</td>';
                doc += '<td>' + element.obj.Title + '</td>';
                doc += '<td>' + element.obj.FirstName + '</td>';
                doc += '<td>' + element.obj.LastName + '</td>';
                doc += '<td>' + element.obj.Status + '</td>';
                doc += '<td>' + element.obj.LeadSource + '</td>';
                doc += '<td>' + element.obj.Lead_Data__c + '</td>';
                doc += '<td>' + element.obj.GATI_Company_Code__c + '</td>';
                doc += '<td>' + element.obj.Product__c + '</td>';
                doc += '<td>' + element.obj.Customer_Potential__c + '</td>';
                doc += '<td>' + element.obj.Designation__c + '</td>';
                doc += '<td>' + element.obj.Company + '</td>';
                doc += '<td>' + element.obj.Email + '</td>';
                doc += '<td>' + element.obj.Phone + '</td>';
                doc += '<td>' + element.obj.MobilePhone + '</td>';
                doc += '<td>' + element.obj.Street + '</td>';
                doc += '<td>' + element.obj.City + '</td>';
                doc += '<td>' + element.obj.State + '</td>';
                doc += '<td>' + element.obj.PostalCode + '</td>';
                doc += '<td>' + element.obj.Cross_Sell_CFS_Locations__c + '</td>';
                doc += '<td>' + element.obj.Description + '</td>';
                doc += '<td>' + element.obj.Cross_Sell_Lead_Status__c + '</td>';
                doc += '<td>' + element.obj.Lost_Reason__c + '</td>';
                doc += '<td>' + element.obj.Description__c + '</td>';
                doc += '<td>' + element.obj.Payment_mode__c + '</td>';
                doc += '</tr>';
            }
        });

        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'leadUploadedSuccess.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    // error log creating
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
        doc += '<th>' + 'Title' + '</th>';
        doc += '<th>' + 'FirstName' + '</th>';
        doc += '<th>' + 'LastName' + '</th>';
        doc += '<th>' + 'Status' + '</th>';
        doc += '<th>' + 'LeadSource' + '</th>';
        doc += '<th>' + 'Lead_Data__c' + '</th>';
        doc += '<th>' + 'GATI_Company_Code__c' + '</th>';
        doc += '<th>' + 'Product__c' + '</th>';
        doc += '<th>' + 'Customer_Potential__c' + '</th>';
        doc += '<th>' + 'Designation__c' + '</th>';
        doc += '<th>' + 'Company' + '</th>';
        doc += '<th>' + 'Email' + '</th>';
        doc += '<th>' + 'Phone' + '</th>';
        doc += '<th>' + 'MobilePhone' + '</th>';
        doc += '<th>' + 'Street' + '</th>';
        doc += '<th>' + 'City' + '</th>';
        doc += '<th>' + 'State' + '</th>';
        doc += '<th>' + 'PostalCode' + '</th>';
        doc += '<th>' + 'Country' + '</th>';
        doc += '<th>' + 'Cross Sell CFS Locations' + '</th>';
        doc += '<th>' + 'Description' + '</th>';
        doc += '<th>' + 'Cross Sell Lead Status' + '</th>';
        doc += '<th>' + 'Lost Reason' + '</th>';
        doc += '<th>' + 'Cross Sell Description' + '</th>';
        doc += '<th>' + 'Payment Mode' + '</th>';
        doc += '<th>' + 'Error' + '</th>';
        doc += '</tr>';
        // fill data in scv file
        this.dataresults.forEach(element => {
            if (element.done == false && element.title != 'Lead Already Generated..!') {

                doc += '<tr>';
                doc += '<td>' + element.obj.Title + '</td>';
                doc += '<td>' + element.obj.FirstName + '</td>';
                doc += '<td>' + element.obj.LastName + '</td>';
                doc += '<td>' + element.obj.Status + '</td>';
                doc += '<td>' + element.obj.LeadSource + '</td>';
                doc += '<td>' + element.obj.Lead_Data__c + '</td>';
                doc += '<td>' + element.obj.GATI_Company_Code__c + '</td>';
                doc += '<td>' + element.obj.Product__c + '</td>';
                doc += '<td>' + element.obj.Customer_Potential__c + '</td>';
                doc += '<td>' + element.obj.Designation__c + '</td>';
                doc += '<td>' + element.obj.Company + '</td>';
                doc += '<td>' + element.obj.Email + '</td>';
                doc += '<td>' + element.obj.Phone + '</td>';
                doc += '<td>' + element.obj.MobilePhone + '</td>';
                doc += '<td>' + element.obj.Street + '</td>';
                doc += '<td>' + element.obj.City + '</td>';
                doc += '<td>' + element.obj.State + '</td>';
                doc += '<td>' + element.obj.PostalCode + '</td>';
                doc += '<td>' + element.obj.Country + '</td>';
                doc += '<td>' + element.obj.Cross_Sell_CFS_Locations__c + '</td>';
                doc += '<td>' + element.obj.Description + '</td>';
                doc += '<td>' + element.obj.Cross_Sell_Lead_Status__c + '</td>';
                doc += '<td>' + element.obj.Lost_Reason__c + '</td>';
                doc += '<td>' + element.obj.Description__c + '</td>';
                doc += '<td>' + element.obj.Payment_mode__c + '</td>';
                doc += '<td>' + element.title + '</td>';
                doc += '</tr>';
            }
        });

        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'leadUploadedError.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}