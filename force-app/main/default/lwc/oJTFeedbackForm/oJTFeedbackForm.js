import { LightningElement, track, wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin, CurrentPageReference  } from 'lightning/navigation';
import OJT_Feedback_Form__c from '@salesforce/schema/OJT_Feedback_Form__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import uId from '@salesforce/user/Id'; 

export default class OJTFeedbackForm extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    @track showspinner = false;
    @track parentid;
    @track form_factor;
    @track recordId = null;
    //form_factor = false;
    activeSections = ['details', 'calls'];
    userId = uId;

    @wire(getObjectInfo, { objectApiName: OJT_Feedback_Form__c })
    ObjectInfo;

    @wire(getRecord, { recordId: '$userId', fields: ['User.Id'] })
    wiredUser({ data, error }) {
        if (data) {
            this.userId = data.fields.Id.value;
        } else if (error) {
            console.error('Error retrieving user Id', error);
        }
    }

    renderedCallback() {
        if (FORM_FACTOR === "Small") {
            this.form_factor = true;
        } else {
            this.form_factor = false;
        }
    }

    connectedCallback() {



        console.log(`user id is ${this.userId}`)
        var referrer = document.referrer;
        var referrerParts = referrer.split("/");
        if (referrerParts.length > 6) {
            console.log(referrerParts);
            console.log("data" + referrerParts[6]);
            this.parentid = referrerParts[6];
        }
    }

    closeModal() {
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.userId,
                objectApiName: 'User',
                actionName: 'view'
            }
        });*/
        window.history.back();
    }

    /*handlesave() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        let isValid = true;

        inputFields.forEach(field => {
            isValid = isValid && field.reportValidity();
        });

        const addCallCmp = this.template.querySelector('c-add-call');
        if (addCallCmp) {
            const addCallValidation = addCallCmp.validate();
            if (!addCallValidation) {
                isValid = false;
            }
        }

        if (!isValid) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please enter all the required fields',
                    variant: 'error'
                })
            );
        } else {
            this.template.querySelector('lightning-record-edit-form').submit();
        }
    }*/

    handlesave(event) {
        var isVal = true;
        //this.showspinner = true;
        this.template.querySelectorAll("lightning-input-field").forEach((element) => {
            isVal = isVal && element.reportValidity();
        });
        let data2 = this.template.querySelector("c-add-call").validate();
        if (!data2) {
            //this.showspinner = false;
            alert("Please Resolve all errors");
            return;
        }
        if (!isVal) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error creating record",
                    message: "Please enter all the required fields",
                    variant: "error"
                })
            );
        } else {

            this.template.querySelector("lightning-record-edit-form").submit();

        }
    }

    handleSuccess(event) {
        this.showspinner = true;
        const payload = event.detail;
        console.log(JSON.stringify(payload));

        console.log(payload.id);
        const recordid = payload.id;
        console.log(recordid);

        this.showToast('Success', 'Record successfully created', 'success');
        this.template.querySelector("c-add-call").handleSubmit(recordid);
        this.showspinner = false;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordid,
                objectApiName: 'OJT_Feedback_Form__c',
                actionName: 'view'
            }
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
}