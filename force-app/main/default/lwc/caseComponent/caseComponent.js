import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import LOADING_ICON from "@salesforce/resourceUrl/loading";
import COMPLETED_ICON from "@salesforce/resourceUrl/completed";
import docketValidation from '@salesforce/apex/caseComponent.docketValidation';
import fetchCaseBasesOnDocket from '@salesforce/apex/caseComponent.fetchCaseBasesOnDocket';

export default class CaseComponent extends NavigationMixin(LightningElement) {
    @api recordTypeId;
    
    @track docket;
    @track disableContinue = false;

    isLoading = false;
    docketValid = false;
    casePage = true;
    pickupCase = true;
    docketLength = true;
    invalidDocket = false;
    isError = false;
    
    docketResponse;
    totalRes;
    caseRecordTypes;
    type;
    subtype;
    rtForRe;
    caseOpened;

    loadingIcon = LOADING_ICON;
    completedIcon = COMPLETED_ICON;
    activeSections = ["basic", "service"]; 
    
    get DocketValidate() {
        if (this.recordTypeId?.name != "Email_Case" && this.recordTypeId?.name != "Pick Up" && this.type != "ADD Extension" && this.type != "Bill back of Expenses" && this.type != "Appointment Delivery" && this.type != "Exception" && this.type != "UCG Confirmation" && this.type != "Pending Pickup" && this.type != "Prospect Pickup" && this.type != "Call Disposition") { 
            return true;
        }
        return false;
    }

    @wire(getObjectInfo, {objectApiName: 'Case'})
    getInfo(result){
        if(result.data){
            let recordTypeInfo = result.data.recordTypeInfos;            
            if(!this.recordTypeId){
                this.recordTypeId = '0125g000000F3cmAAC';	
            }
            this.caseRecordTypes = recordTypeInfo;
            this.rtForRe = recordTypeInfo[this.recordTypeId].name;
            if (recordTypeInfo[this.recordTypeId].name == "Email Case") {
                this.navigateToNewCasDefaults();
            } 
            else if (recordTypeInfo[this.recordTypeId].name == "Prospect Pickup") {
                this.casePage = false;
            } 
            else if (recordTypeInfo[this.recordTypeId].name == "Pick Up") {
                this.pickupCase = false;
            }
        }
        if(result.error){
            //Handle Error
        }
    }

    closeModal(){
        this.casePage = true;
    }

    assignDocket(event){
        this.docket = event.target.value;        
        if(this.docket.length > 5){
            this.docketLength = false;
        }
    }

    handleSubmit(event){
        event.preventDefault();
        this.fetchDocketCases();

        if(this.caseOpened > 0){
            this.isError = true;
        } 
        else{
            this.isError = false;
            let docketInput = this.template.querySelector(".docketNumber");

            if ((this.docket == undefined || this.docket == null) && docketInput) {                
                docketInput.setCustomValidity("Please Enter Value");
                docketInput.reportValidity();
                return;
            }
            if(this.DocketValidate){
                this.invalidDocket = false;
                this.docketValid = false;
                this.isLoading = true;
                this.docketLength = true;
                if(!this.docketValid){
                    this.validateDocket(this.docket);
                }
                else{                    
                    this.navigateToNewCasDefaults(true);
                }
            } 
            else if(this.type == "Prospect Pickup"){
                this.casePage = false;
            }
            else{
                this.navigateToNewCasDefaults();
            }
        }
    }

    handleChange(event){
        if(event.target.name == "Type"){
            this.type = event.target.value;
        }
        if(event.target.name == "Sub_Type__c"){
            this.subtype = event.target.value;
        }
    }

    closeTab(){
        this.dispatchEvent(new CustomEvent('closeclicked'));
    }

    validateDocket(docketNumber){
        docketValidation({ docketNo: docketNumber })
            .then((data) => {
                if(data.result == "successful"){
                    this.isLoading = false;
                    this.totalRes = data;

                    if(data.response.length < 1){
                        this.invalidDocket = true;
                        let docketInput = this.template.querySelector(".docketNumber");
                        docketInput.setCustomValidity("No response received from GEMS system. Please try again.");
                        docketInput.reportValidity();
                    }

                    let docketApiResult = data.response[0];
                    this.docketResponse = docketApiResult;
                    let diffTime = Math.abs(new Date(this.docketResponse.result[0]?.BKG_DT) - new Date());
                    let diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                    
                    if(((this.docketResponse.result[0]?.DOCKET_TYPE == "CARRIERS RISK" && diffDays > 60) || (this.docketResponse.result[0]?.DOCKET_TYPE == "OWNERS RISK" && diffDays > 90)) && (this.docketResponse.result[0]?.CLAIM_EXCEP != "Y")){
                        const event = new ShowToastEvent({
                            title: "Failed",
                            message: "You can not Claim this now. Claim period has been expired!",
                            variant: "error",
                            mode: "sticky"
                        });
                        this.dispatchEvent(event);
                        this.handleCancel();
                    } 
                    else if (this.rtForRe == "Complaint" && this.docketResponse.result[0]?.PDC_BLOCK == "Y") {
                        let docketInput = this.template.querySelector(".docketNumber");
                        docketInput.setCustomValidity("Delivery is blocked for this shipment.");
                        docketInput.reportValidity();
                    }
                    else if (docketApiResult?.sErrMsg == "Invalid Docket No" || docketApiResult?.sErrMsg.length > 1) {
                        this.invalidDocket = true;
                        let docketInput = this.template.querySelector(".docketNumber");
                        docketInput.setCustomValidity("Docket Number was not Found in Gems");
                        docketInput.reportValidity();
                    } 
                    else if (this.docketResponse.result[0]?.DOCKET_STATUS == "REBOOKED" && this.rtForRe == "Claim") {
                        let docketInput = this.template.querySelector(".docketNumber");
                        docketInput.setCustomValidity("Claim cannot be registered for the Rebooked docket");
                        docketInput.reportValidity();
                    } 
                    else if (this.subtype == 'STC COOLING') {
                        if (!this.docketResponse.result[0]?.STOCK_OU) {
                            let docketInput = this.template.querySelector(".docketNumber");
                            docketInput.setCustomValidity("You can raise a complaint only if cooling is more than 12 hrs");
                            docketInput.reportValidity();
                        } 
                        else if ((this.docketResponse.result[0]?.STOCK_OU != null && this.docketResponse.result[0]?.STOCK_OU != '') && this.docketResponse.result[0]?.DELIVERY_STN != this.docketResponse.result[0]?.STOCK_OU) {
                            let date1 = new Date(this.docketResponse.result[0]?.STOCK_IN_DATE_TIME);
                            let date2 = new Date();
                            let Difference_In_Time = date2.getTime() - date1.getTime();
                            let Difference_In_hours = Math.round(Difference_In_Time / (1000 * 3600));
                            let addDate = new Date(this.docketResponse.result[0]?.ASSURED_DLY_DT);
                            if (addDate > date2 && Difference_In_hours > 12) {
                                this.navigateToNewCasDefaults(true);
                            } 
                            else {
                                let docketInput = this.template.querySelector(".docketNumber");
                                docketInput.setCustomValidity("Either ADD is crossed or Cooling times is less than 12 hours.");
                                docketInput.reportValidity();
                            }
                        }
                    } 
                    else {
                        let docketInput = this.template.querySelector(".docketNumber");
                        docketInput.setCustomValidity("");
                        docketInput.readonly = true;
                        this.docketValid = true;
                        this.navigateToNewCasDefaults(true);
                    }
                }
                else {
                    return;
                }
            })
            .catch((error) => {                
                const event = new ShowToastEvent({
                    title: "Failed",
                    message: error?.body?.message,
                    variant: "error",
                    mode: "sticky"
                });
                this.dispatchEvent(event);
                this.isLoading = false;
            });
    }
    
    checkError(event){}    

    /*
    handlerecordid(event) {
        let recid = event.target.value;        
        this.recordTypeId = recid;
    }
    
    navigateToNewCaseProspectpick() {
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__ProspectPickupCreation"
            },
            state: {
                c__counter: '7'
            }
        });
    }
    */

    navigateToNewCasDefaults(includeDefault = false){
        this.closeTab();
        let defaultValues;

        if (includeDefault) {
            let docketResult = this.docketResponse.result[0];
            let delSTN = docketResult?.DELIVERY_STN;
            let booking = docketResult?.BOOKING_STN;
            let accId = docketResult?.CUSTOMER_CODE;
            let stockUO = docketResult?.STOCK_OU;
            let defaultArray = {
                    Docket_Number__c: this.docket,
                    Type: this.type,
                    Consignee_Mobile_No__c: docketResult?.CONSIGNEE_MOBILE_NO,
                    Consignee_PinCode__c: docketResult?.CONSIGNEE_PINCODE,
                    Risk_Coverage__c: docketResult?.DOCKET_TYPE,
                    COD_Type__c: this.docketResponse.COD_TYPE,
                    Decl_Cargo_value__c: docketResult?.DECL_CARGO_VAL,
                    Consignor_Name__c: docketResult?.CONSIGNOR_NAME,
                    Booking_OU__c: this.totalRes[booking],
                    AccountId: this.totalRes[accId],
                    Docket_Status__c: docketResult?.DOCKET_STATUS,
                    No_of_Packages_Delivered__c: docketResult?.NO_OF_PKGS_DELIVERED,
                    Assured_Delivery_Date__c: docketResult?.ASSURED_DLY_DT,
                    Consignor_Mobile_No__c: docketResult?.CONSIGNOR_MOBILE_NO,
                    Actual_Weight_Booked__c: docketResult?.ACTUAL_WT,
                    Booking_Date__c: docketResult?.BKG_DT,
                    POD_Type__c: docketResult?.COD_TYPE,
                    COD_Type__c: docketResult?.POD_TYPE,
                    Delivery_OU__c: this.totalRes[delSTN],
                    Consignor_Pincode__c: docketResult?.CONSIGNOR_PINCODE,
                    PROD_SERV_CODE__c: docketResult?.PROD_SERV_CODE,
                    Charged_Wt__c: docketResult?.CHARGED_WT,
                    No_Of_Packages_Booked__c: docketResult?.NO_OF_PKGS,
                    Consignee_Name__c: docketResult?.CONSIGNEE_NAME,
                    Actual_delivery_Date__c: docketResult?.APPROVED_DLY_DT,
                    Docket_Validation__c: "Valid",
                    Priority: "Normal",
                    Company_of__c: this.docketResponse.companyId == 'GKE' ? "102" : "101",
                    Sub_Type__c: this.subtype
            }

            if(docketResult?.PDC_BLOCK != null && docketResult?.PDC_BLOCK == 'N'){
                defaultArray.PDC_BLOCK__c = '0';
            }
            else if(docketResult?.PDC_BLOCK != null && docketResult?.PDC_BLOCK == 'Y'){
                defaultArray.PDC_BLOCK__c = '1';
            }
            if (docketResult?.STOCK_OU != null && docketResult?.STOCK_OU != '') {
                defaultArray.Stock_OU__c = this.totalRes[docketResult?.STOCK_OU];
            }
            if (docketResult?.STOCK_RECEIVING_OU != null && docketResult?.STOCK_RECEIVING_OU != '') {
                defaultArray.Stock_Receiving_OU__c = this.totalRes[docketResult?.STOCK_RECEIVING_OU];
            }
            if (this.subtype == 'STC COOLING') {                
                defaultArray.Complaint_Actionable_OU__c = this.totalRes[stockUO];
                defaultArray.CCEC_Action_OU__c = this.totalRes[stockUO];
                defaultArray.Company_of__c = this.docketResponse.companyId == 'GKE' ? "102" : "101";
            }
            defaultValues = encodeDefaultFieldValues(defaultArray);
        } 
        else {
            defaultValues = encodeDefaultFieldValues({
                Docket_Number__c: this.docket,
                Type: this.type,
                Sub_Type__c: this.subtype,
                Docket_Validation__c: "Valid",
                Company_of__c: '102'
            });
        }

        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Case",
                actionName: "new"
            },
            state: {
                recordTypeId: this.recordTypeId,
                nooverride: "1",
                defaultFieldValues: defaultValues
            }
        });
    }

    fetchDocketCases() {
        fetchCaseBasesOnDocket({ subType: this.subtype, docket: this.docket })
        .then(result => {
            this.caseOpened = result;                
        })
        .catch(error => {
            console.error('Error occur when fetching Case - ', error);
        });
    }

    handleCancel() {
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
}