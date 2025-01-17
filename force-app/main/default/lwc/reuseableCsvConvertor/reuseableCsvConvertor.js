import getCsvData from '@salesforce/apex/ReuseableCsvConvertor.getCsvData';
import { LightningElement, api, track } from 'lwc';

export default class ReuseableCsvConvertor extends LightningElement {
    @api recordId;
    @api disableAttachment = false;
    @api labelToApi;
    @api isContract = 'CUSTOMER CODE';

    csvdata;
    csvDataasObj = [];
    columnOriginal = [];
    headerLabel;


    handleUploadFinished(event){
        this.disableAttachment = true;
        const uploadedFile = event.detail.files;
        getCsvData({ contentVersionId: uploadedFile[0].contentVersionId }).then(res => {
            this.csvdata = res.replaceAll("\r", '');
            this.convertCsvTOObj();
        });
    }

    convertCsvTOObj() {
        //hiding org table
        let lines = this.csvdata.split(/(?:\r\n|\n)+/).filter(function (el) { return el.length != 0 });
        this.headerLabel = lines.splice(0, 1)[0].split(",");
        if(this.isContract.toUpperCase() == this.headerLabel[0]){
            let valuesRegExp = /(?:\"([^\"]*(?:\"\"[^\"]*)*)\")|([^\",]+)/g;
            for (let i = 0; i < lines.length; i++) {
                let element = {};
                let j = 0;
                var matches;
                while (matches = valuesRegExp.exec(lines[i])) {
                    var value = matches[1] || matches[2];
                    value = value.replace(/\"\"/g, "\"");
                    element[this.labelToApi.get(this.headerLabel[j].trim())] = value.trim();
                    j++;
                }

                this.csvDataasObj.push(element);
            }

            this.headerLabel.forEach(element => {
                var temp = {
                    label: element,
                    fieldName: this.labelToApi.get(element).trim(),
                    sortable: true
                }
                this.columnOriginal.push(temp);
            });

            //this.disableAttachment = false;
            const event = new CustomEvent('uploadcomplete', {
                detail: { columnData : this.columnOriginal, tableData : this.csvDataasObj}
            });
            this.dispatchEvent(event);
        }else{
            this.disableAttachment = false;
            const event = new CustomEvent('gettingerror', {
                detail: { errorMessage : 'Please select '+this.headerLabel[0] == 'CONTRACT NUMBER' ? 'Contract' : 'Customer Code'}
            });
            this.dispatchEvent(event);
        }
    }
}