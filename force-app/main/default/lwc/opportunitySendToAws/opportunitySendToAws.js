import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import jsZip from '@salesforce/resourceUrl/JsZip';
import jsSaver from '@salesforce/resourceUrl/JsSaver';
import getAllAccounts from '@salesforce/apex/OpportunitySendToAwsController.getAllAccounts';
import getContentVersions from '@salesforce/apex/OpportunitySendToAwsController.getContentVersions';
import sendFileToAWS from '@salesforce/apex/UploadVerificationDocumentsController.sendFileToAWS';

export default class OpportunitySendToAws extends LightningElement {
    @track accountIds = [];
    jsPdfInitialized = false;

    connectedCallback(){
        getAllAccounts({}).then(result => {
            if(result != null && result.length > 0){
                this.accountIds = JSON.parse(JSON.stringify(result));
                console.log('Total Size ', this.accountIds.length);
                if(this.accountIds.length > 0){
                    this.loadChunksInBatches();
                }
            }
        })
        .catch(error => {
            this.showToast('Error In Getting Accounts!', JSON.stringify(error), 'error');
        });
    }

    renderedCallback(){
        loadScript(this, jsZip ).then(() => {});
        loadScript(this, jsSaver ).then(() => {});
        if (this.jsPdfInitialized) {
            return;
        }
        this.jsPdfInitialized = true;
    }

    loadChunksInBatches() {
        const batchSize = 1;
        let index = 0; 
        const processBatch = () => {
            const currentBatch = this.accountIds.slice(index, index + batchSize);
            index += batchSize;
            Promise.all(currentBatch.map(accId =>{
                    let indexCurrent = this.accountIds.indexOf(accId);
                    console.log('indexCurrent ',indexCurrent);
                    console.log('Account Id ',accId);
                    getContentVersions({ accIds: accId })
                    .then(res => {
                        if(Object.keys(res).length > 0){
                            this.sendZipToAws(res);
                        }
                    })
                    .catch(error => {
                        this.showToast('Document Fetching Error In AccountId - '+accId,JSON.stringify(error),'error');
                    });
                })
            )
            .then(() => {
                if (index < this.accountIds.length) {
                    setTimeout(() => {
                        processBatch(); 
                    }, 100);
                }
            })
            .catch(error => {
                this.showToast('Chunk Processing Error!',JSON.stringify(error),'error');
            });
        };
        processBatch();
    }

    sendZipToAws(singleOpportunityData){
        var zip = new JSZip();
        let zipName;
        Object.keys(singleOpportunityData).forEach(el => {
            zipName = el+'.zip';
            let filesDetails = singleOpportunityData[el];
            filesDetails.forEach(file => {
                let decodedData = this.decodeBase64(file.fileData);
                zip.file(file.fileName, decodedData,{binary : true});
            });
        });
        zip.generateAsync({ type: "base64", compression: "DEFLATE", compressionOptions: { level: 9 }})
        .then(content => {
            sendFileToAWS({fileData : content, fileName : zipName}).then(result => {
                if(result){
                    this.showToast('File Upload!','File uploaded to AWS. '+zipName,'success');
                }
            }).catch(error => {
                console.log(JSON.stringify(error+' '+zipName,null,2));
                this.showToast('Error In Sending!',JSON.stringify(error),'error');
            });
        });
    }

    decodeBase64(base64) {
        const binaryString = window.atob(base64);
        const length = binaryString.length;
        const buffer = new ArrayBuffer(length);
        const view = new Uint8Array(buffer);

        for (let i = 0; i < length; i++) {
            view[i] = binaryString.charCodeAt(i);
        }

        return buffer; 
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}