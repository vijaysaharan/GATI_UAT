import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import jsZip from '@salesforce/resourceUrl/JsZip';
import jsSaver from '@salesforce/resourceUrl/JsSaver';
import AWS_SDK from '@salesforce/resourceUrl/AWS';
import updateOpportunityDetails from '@salesforce/apex/UploadVerificationDocumentsController.updateOpportunityDetails';

export default class UploadVerificationDocuments extends NavigationMixin(LightningElement) {
    @api recordId;
    
    @track documentNumber;
    @track fileName;
    @track fileContent;
    @track documentType;

    documentTypes = [
        {label : 'GSTIN', value : 'GSTIN'},
        {label : 'PAN', value : 'PAN'}
    ];

    isSendDisable = true;
    isUploaderDisable = false;
    jsPdfInitialized = false;
    awsInitialized = false;
    s3 = null;

    get isTypeSelected(){
        return (this.documentType != null && this.documentType != '') ? true : false;
    }

    renderedCallback(){
        loadScript(this, jsZip ).then(() => {});
        loadScript(this, jsSaver ).then(() => {});
        loadScript(this,  AWS_SDK).then(() => {
            this.awsInitialized = true;
            this.initializeAWS();
        });
       if (this.jsPdfInitialized) {
           return;
       }
       this.jsPdfInitialized = true;
   }

   initializeAWS() {
        // Configure AWS credentials
        AWS.config.update({
            region: 'ap-south-1'
        });

        // Initialize S3
        this.s3 = new AWS.S3();
   }

    fileUploadToAWS(fileData, fileName) {
        if (!this.awsInitialized) {
            console.error('AWS SDK not initialized');
            return;
        }

        if (fileData) {
            const params = {
                Bucket: 'Customer-Dev-Identifier-S3-Bucket',
                Key: fileName,
                Body: fileData,
                ACL: 'public-read',
                ContentType: 'application/zip'
            };

            // Upload to S3
            this.s3.upload(params, (err, data) => {
                if (err) {
                    console.error('File upload failed', err);
                } 
                else {
                    console.log('File uploaded successfully', data.Location);
                }
            });
        }
    }

    handleDocumentNumber(event){
        this.documentNumber = event.detail.value;
    }

    handleFileUpload(event){
        if(event?.detail?.files?.length > 0){
            this.fileName = event?.detail?.files[0]?.name;
            this.uploadFileToAWS(event.detail.files[0]);
            this.isUploaderDisable = true;
            this.isSendDisable = false;
        }
    }

    handleTypeChange(event){
        this.documentType = event.detail.value;
        this.documentNumber = null;
        if (this.documentType == 'PAN') {
            this.documentPattern = '[A-Za-z]{5}[0-9]{4}[A-Za-z]{1}';
            this.errorMessage = 'Please enter a valid PAN Number (e.g., ABCDE1234F)';
        } 
        else if (this.documentType == 'GSTIN') {
            this.documentPattern = '[0-9]{2}[A-Za-z]{5}[0-9]{4}[A-Za-z]{1}[1-9A-Za-z]{1}Z[0-9A-Za-z]{1}';
            this.errorMessage = 'Please enter a valid GSTIN (e.g., 27ABCDE1234F1Z5)';
        }
    }

    handleSendToAWS(){
        this.isSendDisable = true;
        if(this.fileContent && this.documentNumber && this.documentNumber != null && this.documentNumber != ''){ 
            var zip = new JSZip();
            zip.file(this.fileName, this.fileContent);
            zip.generateAsync({ type: "base64", compression: "DEFLATE", compressionOptions: { level: 9 }})
            .then(content => {
                /*const presignedUrl = this.s3.getSignedUrl('putObject', {
                    Key: this.fileName,
                    ContentType: 'application/zip',
                    Bucket: 'Customer-Dev-Identifier-S3-Bucket',
                    Metadata: {} // This is optional
                });
                console.log('presignedUrl ',presignedUrl);
                fetch(presignedUrl, {
                    method: "PUT",
                    body: content,
                }).then((response) => {
                if (response.status == 200) {
                    // Success logic here
                    console.log('SUCCESS');
                    
                }
                }).catch(err=> {
                    console.log('Error In AWS ',JSON.stringify(err,null,2));
                    
                });*/
                //this.fileUploadToAWS(content, this.fileName);
                updateOpportunityDetails({fileData : content, fileName : this.fileName, opportunityId : this.recordId, documentNumber : this.documentNumber, fileType : this.documentType}).then(result => {
                    if(result){
                        this.showToast('File Upload!','File uploaded to AWS.','success');
                        this.navigateToRecord();
                    }
                }).catch(error => {
                    this.showToast('Error In Sending!',JSON.stringify(error),'error');
                    this.navigateToRecord();
                });
            });
        }
        else{
            this.showToast('File Not Available!','Please upload file.','warning');
        }
    }

    async uploadFileToAWS(file) {
        this.fileContent = await this.readFileAsBase64(file);
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result.split(',')[1]);
            reader.onerror = error => reject(error);
            reader.readAsDataURL(file);
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    navigateToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
}