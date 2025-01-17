import { LightningElement, api, wire, track } from 'lwc';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { loadScript } from 'lightning/platformResourceLoader';
import CSVData from '@salesforce/apex/AppointmentDeliveryController.csvData';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import appointmentDeliveryTemplate from '@salesforce/resourceUrl/appointmentDeliveryTemplate';

export default class AppointmentDeliveryLWC extends NavigationMixin(LightningElement) {

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
        window.open(baseUrl + appointmentDeliveryTemplate);

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
            this.isSpninner = false;
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
                objectApiName: "Case",
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
        doc += '<th>' + 'Docket_Number__c' + '</th>';
        doc += '<th>' + 'Appointment_Contact_Number__c' + '</th>';
        doc += '<th>' + 'Appointment_Contact_Person__c' + '</th>';
        doc += '<th>' + 'Appointment_Date__c' + '</th>';
        doc += '</tr>';
        // fill data in scv file
        this.dataresults.forEach(element => {
            if (element.done == true) {
                doc += '<tr>';
                doc += '<td>' + element.Id + '</td>';
                doc += '<td>' + element.obj.Docket_Number__c + '</td>';
                doc += '<td>' + element.obj.Appointment_Contact_Number__c + '</td>';
                doc += '<td>' + element.obj.Appointment_Contact_Person__c + '</td>';
                doc += '<td>' + element.obj.Appointment_Date__c + '</td>';
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
        doc += '<th>' + 'Docket_Number__c' + '</th>';
        doc += '<th>' + 'Appointment_Contact_Number__c' + '</th>';
        doc += '<th>' + 'Appointment_Contact_Person__c' + '</th>';
        doc += '<th>' + 'Appointment_Date__c' + '</th>';
        doc += '<th>' + 'Error' + '</th>';
        doc += '</tr>';
        // fill data in scv file
        this.dataresults.forEach(element => {
            if (element.done == false) {
                doc += '<tr>';
                doc += '<td>' + element.obj.Docket_Number__c + '</td>';
                doc += '<td>' + element.obj.Appointment_Contact_Number__c + '</td>';
                doc += '<td>' + element.obj.Appointment_Contact_Person__c + '</td>';
                doc += '<td>' + element.obj.Appointment_Date__c + '</td>';
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