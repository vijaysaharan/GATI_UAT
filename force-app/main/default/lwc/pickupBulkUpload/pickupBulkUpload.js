import { api, LightningElement, track } from 'lwc';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import { loadScript } from 'lightning/platformResourceLoader';
import CSVData from '@salesforce/apex/PickupBulkUploadController.csvData';
import getOrgnizationData from '@salesforce/apex/PickupBulkUploadController.getOrgnizationData';
import getOrgnizationDataWithDistance from '@salesforce/apex/PickupBulkUploadController.getOrgnizationDataWithDistance';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Bulk_Pickup from '@salesforce/resourceUrl/BulkPickup';

export default class PickupBulkUpload extends NavigationMixin(LightningElement) {

    get records() {
        this.visiblerecords

    }
    get showtable() {
        //console.log(this.dataresults);
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
    instruct = true;
    instructc;
    value = 'pickup';
    pincodesData = [];
    pincodes = [];
    orgnizationData = [];
    errorPincodeData = [];
    isWrongPinCode = false;
    shipperPicnCodes = [];
    isSuccessError = false;


    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    // console.log('parser initialization is done')
                    this.parserInitialized = true;

                })
                .catch(error => console.error(error));
        }
    }

    //added by Ashish
    fetchOrgnizationdata() {
        getOrgnizationData({ pincodes: this.pincodes })
            .then(result => {
                // console.log('--- result data check--', result);
                this.orgnizationData = result;
                if (this.orgnizationData != null && this.orgnizationData.length > 0) {
                    this.isWrongPinCode = true;
                    this.showError = true;
                    //c/accountTeamMemberCSVDownloadthis.dissave = true;
                } else {
                    this.isWrongPinCode = false;
                    this.showError = false;
                    this.dissave = false;
                }

            })
            .catch(error => {
                console.error('-- error checking---', error);
            })
    }


    download(event) {
        var baseUrl = 'https://' + location.host;
        window.open(baseUrl + Bulk_Pickup);

    }
    handlecsvUpload(event) {
        this.instruct = false;
        // console.log(event.detail.files[0])
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
            this.pincodesData = data1.data;
            this.pincodes = [];
            this.pincodesData.forEach(ele => {
                if (ele.Shipper_Pincode__c != '' && ele.Shipper_Pincode__c != null) {
                    this.pincodes.push(ele.Shipper_Pincode__c);
                    this.shipperPicnCodes.push(ele.Shipper_Pincode__c);
                }
                if (ele.Destination_Pincode != null && ele.Destination_Pincode != '') {
                    this.pincodes.push(ele.Destination_Pincode);
                }
            });
            //this.fetchOrgnizationdata();
        })
    }
    updateData(event) {
        let rec = event.detail.records;
        // console.log('data from child ' + JSON.stringify(rec));
        this.visiblerecords = [...rec];
    }

    save(event) {
        this.dissave = true;
        // console.log(this.totaldata.data);
        this.loading = true;
        CSVData({ data: this.totaldata.data, pincodes: this.shipperPicnCodes, shipperAndDestination: this.pincodes }).then(data => {
            this.dataresults = data;
            this.loading = false;
            this.isSuccessError = true;
            // console.log('data is ' + JSON.stringify(data));

        }).catch(error => {
            this.showToast(error, 'Please Correct the CSV Data' + error, 'error');
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
        // console.log('dataresults IN Success LOg',JSON.stringify(this.dataresults, null, 2));
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
        doc += '<th>' + 'Shipper_Name__c' + '</th>';
        doc += '<th>' + 'Customer_Code' + '</th>';
        doc += '<th>' + 'Pickup_Address1__c' + '</th>';
        doc += '<th>' + 'Pickup_Address2__c' + '</th>';
        doc += '<th>' + 'Pickup_Address3__c' + '</th>';
        doc += '<th>' + 'Mobile__c' + '</th>';
        doc += '<th>' + 'Shipper_Pincode__c' + '</th>';
        doc += '<th>' + 'Customer_Email__c' + '</th>';
        doc += '<th>' + 'Destination_Pincode' + '</th>';
        doc += '<th>' + 'Pickup_Date__c' + '</th>';
        doc += '<th>' + 'Actual_Weight__c' + '</th>';
        doc += '<th>' + 'Product__c' + '</th>';
        doc += '<th>' + 'Pickup_City__c' + '</th>';
        doc += '<th>' + 'Volume__c' + '</th>';
        doc += '<th>' + 'No_Of_Packages__c' + '</th>';
        doc += '<th>' + 'Pick_Up_Instructions__c' + '</th>';
        doc += '</tr>';
        // fill data in scv file
        this.dataresults.forEach(element => {
            if (element.done == true) {
                doc += '<tr>';
                doc += '<td>' + element.obj.Id + '</td>';
                doc += '<td>' + element.obj.Shipper_Name__c + '</td>';
                doc += '<td>' + element.obj.Account.Customer_Code__c + '</td>';
                doc += '<td>' + element.obj.Pickup_Address1__c + '</td>';
                doc += '<td>' + element.obj.Pickup_Address2__c + '</td>';
                doc += '<td>' + element.obj.Pickup_Address3__c + '</td>';
                doc += '<td>' + element.obj.Mobile__c + '</td>';
                doc += '<td>' + element.obj.Shipper_Pincode__c + '</td>';
                doc += '<td>' + element.obj.Customer_Email__c + '</td>';
                doc += '<td>' + element.obj.Receiver_Pincode__c + '</td>';
                doc += '<td>' + element.obj.Pickup_Date__c + '</td>';
                doc += '<td>' + element.obj.Actual_Weight__c + '</td>';
                doc += '<td>' + element.obj.Product__c + '</td>';
                doc += '<td>' + element.obj.Pickup_City__c + '</td>';
                doc += '<td>' + element.obj.Volume__c + '</td>';
                doc += '<td>' + element.obj.No_Of_Packages__c + '</td>';
                doc += '<td>' + element.obj.Pick_Up_Instructions__c + '</td>';
                doc += '</tr>';
            }
        });

        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'BulkPickupSuccess.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    // error log creating
    handleErrorLog() {
        // console.log('dataresults IN Error LOg',JSON.stringify(this.dataresults, null, 2));
        let doc = '<table>';
        // Add styles for the table
        doc += '<style>';
        doc += 'table, th, td {';
        doc += '    border: 1px solid black;';
        doc += '    border-collapse: collapse;';
        doc += '}';
        doc += '</style>';
        doc += '<tr>';
        doc += '<th>' + 'Error' + '</th>';
        doc += '<th>' + 'Shipper_Name__c' + '</th>';
        doc += '<th>' + 'Customer_Code' + '</th>';
        doc += '<th>' + 'Pickup_Address1__c' + '</th>';
        doc += '<th>' + 'Pickup_Address2__c' + '</th>';
        doc += '<th>' + 'Pickup_Address3__c' + '</th>';
        doc += '<th>' + 'Mobile__c' + '</th>';
        doc += '<th>' + 'Shipper_Pincode__c' + '</th>';
        doc += '<th>' + 'Customer_Email__c' + '</th>';
        doc += '<th>' + 'Destination_Pincode' + '</th>';
        doc += '<th>' + 'Pickup_Date__c' + '</th>';
        doc += '<th>' + 'Actual_Weight__c' + '</th>';
        doc += '<th>' + 'Product__c' + '</th>';
        doc += '<th>' + 'Pickup_City__c' + '</th>';
        doc += '<th>' + 'Volume__c' + '</th>';
        doc += '<th>' + 'No_Of_Packages__c' + '</th>';
        doc += '<th>' + 'Pick_Up_Instructions__c' + '</th>';

        doc += '</tr>';
        // fill data in scv file
        this.dataresults.forEach(element => {
            if (element.done == false) {
                doc += '<tr>';
                doc += '<td>' + element.title + '</td>';
                doc += '<td>' + element.obj.Shipper_Name__c + '</td>';
                doc += '<td>' + element.obj.Account.Customer_Code__c + '</td>';
                doc += '<td>' + element.obj.Pickup_Address1__c + '</td>';
                doc += '<td>' + element.obj.Pickup_Address2__c + '</td>';
                doc += '<td>' + element.obj.Pickup_Address3__c + '</td>';
                doc += '<td>' + element.obj.Mobile__c + '</td>';
                doc += '<td>' + element.obj.Shipper_Pincode__c + '</td>';
                doc += '<td>' + element.obj.Customer_Email__c + '</td>';
                doc += '<td>' + element.obj.Receiver_Pincode__c + '</td>';
                doc += '<td>' + element.obj.Pickup_Date__c + '</td>';
                doc += '<td>' + element.obj.Actual_Weight__c + '</td>';
                doc += '<td>' + element.obj.Product__c + '</td>';
                doc += '<td>' + element.obj.Pickup_City__c + '</td>';
                doc += '<td>' + element.obj.Volume__c + '</td>';
                doc += '<td>' + element.obj.No_Of_Packages__c + '</td>';
                doc += '<td>' + element.obj.Pick_Up_Instructions__c + '</td>';

                doc += '</tr>';
            }
        });

        doc += '</table>';
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'BulkPickupError.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }


}