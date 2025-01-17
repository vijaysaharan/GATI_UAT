import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import MCM_actionable__c from '@salesforce/schema/Customer_Connect__c.MCM_actionable__c';
import Customer_Connect__c from '@salesforce/schema/Customer_Connect__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FORM_FACTOR from '@salesforce/client/formFactor'
import uId from '@salesforce/user/Id';
import updateCheckInTime from '@salesforce/apex/CustomerConnectUpdateCheckIn.updateCheckInTime';
import getRevenueDetailsOfAccount from '@salesforce/apex/CustomerConnectUpdateCheckIn.getRevenueDetailsOfAccount';
import getAccountDetails from '@salesforce/apex/CustomerConnectUpdateCheckIn.getAccountDetails';


export default class Customer_Connect extends NavigationMixin(LightningElement) {
    @api accountId;
    @api leadId;

    userId = uId;

    @track isCallTypeSelected = false;
    @track disablebool = false;
    @track disableboolacc = false;
    @track requiredboolr = false;
    @track requiredboolaccr = false;
    @track isRetail = false;
    @track isFullAgreed = false;
    @track recordId = null;
    @track parentid;
    @track Add_actions;
    @track date;
    @track showspinner;
    @track enddate;
    @track StartKM;
    @track EndKM;
    @track leadRecordId;
    @track oppRecordId;
    @track latitudeValue;
    @track longitudeValue;
    @track checkTime;
    @track disdata;
    @track form_factor;
    @track MTDRevenueSurface = 0;
    @track MTDRevenueAir = 0;
    @track keyIndex = 0;
    @track escalatedPercentage = null;
    @track effectiveDate = null;
    
    @track actionables = [{
        Task__c: "",
        MCM_actionable__c: "",
        Include_in_MOM__c: ""
    }];

    isShowModal = false;
    isCheckIn = false;
    isNBD = false;
    isAccount = false;
    isEscalatedPercentage = false;
    
    activeSections = ["details", "actionables", "attendees","additionalInformation"];

    @wire(getObjectInfo, { objectApiName: Customer_Connect__c })
    ObjectInfo;

    @wire(getPicklistValues, {
        fieldApiName: MCM_actionable__c,
        recordTypeId: "$ObjectInfo.data.defaultRecordTypeId"
    })

    wiredRecordTypeInfo({ data, error }) {
        if (data) {
            this.disdata = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            let urlStateParameters = currentPageReference.state;
            this.recordId = urlStateParameters.c__id;
        }
    }
    
    renderedCallback() {
        if (FORM_FACTOR == "Small") {
            this.form_factor = true;
        } else this.form_factor = false;
    }
    clear() {
        //Clear
    }
    connectedCallback() {
        var referrer = document.referrer;
        var referrerParts = referrer.split("/");
        if (referrerParts.length > 6) {
            this.parentid = referrerParts[6];
        }
        if(this.accountId != null){
            this.recordId = this.accountId;
        }
        if(this.leadId != null){
            this.leadRecordId = this.leadId;
        }
    }

    closeModal() {
        window.history.back();
    }

    handlesave(event) {
        var isVal = true;
        this.template.querySelectorAll("lightning-input-field").forEach((element) => {
            isVal = isVal && element.reportValidity();
        });
        let data2 = this.template.querySelector("c-attendees").validate();
        if (!data2) {
            alert("Please Resolve all errors");
            return;
        }
        if (this.Add_actions) {
            let data = this.template.querySelector("c-actionables").validate();
            if (!data) {
                alert("Please resolve all errors");
                return;
            }
        }
        if (!isVal) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error creating record",
                    message: "Please enter all the required fields",
                    variant: "error"
                })
            );
        } 
        else {
            this.template.querySelector("lightning-record-edit-form").submit();
        }
    }

    handleCallTypeChange(event){
        if(event.detail.value == 'Branch / OU Visit'){
            this.isCallTypeSelected = true;
        }
        else{
            this.isCallTypeSelected = false;
        }
    }

    handleSubTypeChange(event) {
        let selectVal = event.target.value;
        if(selectVal == "NBD"){
            this.isNBD = true;
        }
        else{
            this.isNBD = false;
            this.oppRecordId = null;
        }
        if (selectVal == "NBD" || selectVal == "Contract Signoff" || selectVal == "New Customer" || selectVal=="Student Express") {
            this.disablebool = false;
            this.disableboolacc = true;
            this.template.querySelector('[data-accid]').reset();
        } 
        else {
            this.disablebool = true;
            this.disableboolacc = false;
            this.template.querySelector('[data-leadid]').reset();

        }
        if(selectVal == 'Partial Price Increase' || selectVal == 'Agreed Full Price Increase'){
            this.isEscalatedPercentage = true;
        }
        else{
            this.isEscalatedPercentage = false;
            this.escalatedPercentage = null;
            this.effectiveDate = null;
        }
        if(selectVal == 'Agreed Full Price Increase'){
            this.isFullAgreed = true;
            this.escalatedPercentage = this.isRetail ? 15 : 10.2;
        }
        else{
            this.isFullAgreed = false;
            this.escalatedPercentage = 0;
        }
    }

    handleSuccess(event) {
        this.showspinner = true;
        let payload = event.detail;
        let recordId = payload.id;

        this.showToast("Success", "Customer connect successfully created", "success");
        if (this.isCheckIn == true) {
            updateCheckInTime({ recordId: recordId })
                .then(resp => {
                    //Success
                }).catch(error => { 
                   //Error
                });
        }
        if (this.Add_actions) this.template.querySelector("c-actionables").handleSubmit(recordId);
        this.template.querySelector("c-attendees").handleSubmit(recordId);
        this.showspinner = false;
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                objectApiName: "Customer_Connect__c",
                actionName: "view"
            }
        });
    }

    showToast(tit, mess, vari, mod) {
        const event = new ShowToastEvent({
            title: tit,
            message: mess,
            variant: vari
        });
        this.dispatchEvent(event);
    }

    changeHandler(event) {
        if (event.target.name === "Task") {
            console.log(event.target.accessKey);
            this.actionables[event.target.accessKey].Task__c = event.target.value;
        }
        if (event.target.name === "actionable") {
            this.actionables[event.target.accessKey].MCM_actionable__c = event.target.value;
        }
        if (event.target.name === "Include_in_mom") {
            console.log(event.target.accessKey + " values is " + event.target.checked);
            this.actionables[event.target.accessKey].Include_in_MOM__c = event.target.checked;
        }
        if (event.target.name === "add_Actions") {
            this.Add_actions = event.target.checked;
        }
    }

    leadCreation() {
        this.isShowModal = true;
    }

    hideModalBox = () => { this.isShowModal = false; }

    handleSaveLead(event) {
        var leadFormData = [];
        var isVal = true;

        leadFormData = this.template.querySelectorAll("lightning-record-edit-form");
        for (let i = 0; i < leadFormData.length; i++) {
            if (leadFormData[i].dataset.id == 'leadCreation') {
                leadFormData[i].submit();
            }
        }

    }

    handleSuccessLead(event) {
        this.isShowModal = false;
        this.showToast("Success", "Lead successfully created", "success");
        const payload = event.detail;
        this.leadRecordId = payload.id;
    }

    handleSubmitLead(event) {
        //handle Submit Event
    }

    handleError(event) {
        //handle Error Event
    }

    handCheckIn(event) {
        this.isCheckIn = true;
        var geoObj = {};
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                geoObj.latitude = position.coords.latitude;
                geoObj.longitude = position.coords.longitude;
                this.latitudeValue = geoObj.latitude;
                this.longitudeValue = geoObj.longitude
                this.checkTime = new Date();
            });
        }
    }

    handleCustomer360(event){
        let currValue = event?.detail?.value;
        if(currValue.length>0){
            let currAccount = currValue[0];
            getRevenueDetailsOfAccount({accId : currAccount}).then(res => {
                this.MTDRevenueAir = res['AIR EXPRESS'];
                this.MTDRevenueSurface = res['SUR EXPRESS'];
            }).catch(err => {
                //Error
            });
            this.isAccount = true;
            getAccountDetails({accId : currAccount}).then(res => {
                if(res?.Customer_Category__c == 'Retail'){
                    this.isRetail = true;
                }
                if(this.isFullAgreed){
                    this.escalatedPercentage = this.isRetail ? 15 : 10.2;
                }
            }).catch(err => {
                //Error
            });
        }
        else{
            this.isAccount = false;
            this.MTDRevenueSurface = 0;
            this.MTDRevenueAir = 0;
        }
    }
}