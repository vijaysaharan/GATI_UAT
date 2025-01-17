import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'
import CASE_OBJECT from '@salesforce/schema/Case';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { decodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import loading from "@salesforce/resourceUrl/loading";
import completed from "@salesforce/resourceUrl/completed";
import docketValidation from '@salesforce/apex/caseComponent.docketValidation';
import fetchCaseBasesOnDocket from '@salesforce/apex/caseComponent.fetchCaseBasesOnDocket';

export default class CaseComponent extends NavigationMixin(LightningElement) {
    loadingicon = loading;
    loadingval = false;
    docketValid = false;
    @track casePage = true;
    @track pickupCase = true;
    totalres;
    completedicon = completed;
    checkvalidation = true;
    docketlength = true;
    invaliddocket = false;
    checkvalidation = true;
    docketcheckcompleted = false;
    docketresponse;
    caserecordtypes;
    activeSections = ["basic", "service"];
    @track recordtypes;
    @track type;
    @track subtype;
    @api recordTypeId;
    @track docket;
    type;
    subtype;
    rtforre;
    caseOpened;
    isError = false;
    @track disableContinue = false;

    @wire(getObjectInfo, { objectApiName: 'Case' })
    getinfos(val) {
        if (val.data) {
            console.log(Object.keys(val.data.recordTypeInfos));
            const rtis = val.data.recordTypeInfos;
            this.caserecordtypes = rtis;
            this.rtforre = rtis[this.recordTypeId].name;
            if (rtis[this.recordTypeId].name == "Email Case") {
                this.navigateToNewCasDefaults();
            } else if (rtis[this.recordTypeId].name == "Prospect Pickup") {
                //this.navigateToNewCasDefaults();
                this.casePage = false;
            } else if (rtis[this.recordTypeId].name == "Pick Up") {
                this.pickupCase = false;
            }

        }
        if (val.error) {
            console.log(error);
        }
    }

    closeModal() {
        this.casePage = true;
    }
    onCancel() {

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




    assigndocket(event) {
        this.docket = event.target.value;
        console.log(this.docket.length);
        if (this.docket.length > 5) {
            this.docketlength = false;
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        this.fetchDocketCases();

       //debugger;
        if (this.caseOpened > 0) {
            this.isError = true;
        } else {
            this.isError = false;
            let val = this.template.querySelector(".docketno");
            if ((this.docket == undefined || this.docket == null) && val) {
                console.log(this.docket + ' ' + val)
                val.setCustomValidity("Please Enter Value");
                val.reportValidity();
                return;
            }
            //val.setCustomValidity("");
            if (this.DocketValidate) {
                this.invaliddocket = false;
                this.docketValid = false;
                this.loadingval = true;
                this.docketlength = true;
                if (!this.docketValid) {
                    this.validateDocket(this.docket);
                } else {
                    console.log("here");
                    this.navigateToNewCasDefaults(true);
                }
            } else if (this.type == "Prospect Pickup") {
                this.casePage = false;
                //this.navigateToNewCaseProspectpick();
            } else {
                this.navigateToNewCasDefaults();
            }
        }

    }
    handlechange(event) {
        console.log(`event is called for ${event.target.name} and value is ${event.target.value}`);
        if (event.target.name == "Type") {
            this.type = event.target.value;
        }
        if (event.target.name == "Sub_Type__c") {
            this.subtype = event.target.value;
        }
    }
    closeTab() {
        let ev = new CustomEvent('closeclicked');
        this.dispatchEvent(ev);
    }
    validateDocket(docketNumber) {
        docketValidation({ docketNo: docketNumber })
            .then((data) => {
                console.log('--- docket json data--', data);
                console.log('this is type', this.type);
                if (data.result == "successful") {
                    this.loadingval = false;
                    this.totalres = data;

                    if (data.response.length < 1) {
                        this.invaliddocket = true;
                        let val = this.template.querySelector(".docketno");
                        val.setCustomValidity("No response received from GEMS system. Please try again.");
                        val.reportValidity();
                    }
                    let docres = data.response[0];
                    this.docketresponse = docres;
                    if(this.docketresponse?.result && this.docketresponse?.result.length > 0){
                        const diffTime = Math.abs(new Date(this.docketresponse.result[0]?.BKG_DT) - new Date());
                        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                        console.log(diffDays);
                        if ((this.docketresponse.result[0]?.DOCKET_TYPE == "CARRIERS RISK" && diffDays > 60) || (this.docketresponse.result[0]?.DOCKET_TYPE == "OWNERS RISK" && diffDays > 90)) {
                            const event = new ShowToastEvent({
                                title: "Failed",
                                message: "You can not Claim this now. Claim period has been expired!",
                                variant: "error",
                                mode: "sticky"
                            });
                            this.dispatchEvent(event);
                            this.onCancel();
                        } 
                        else if (this.rtforre == "Complaint" && this.docketresponse.result[0].PDC_BLOCK == "Y") {//PDC BLOCK
                            //this.invaliddocket = true;
                            console.log('Record Type >>',this.rtforre == "Complaint");
                            let val = this.template.querySelector(".docketno");
                            val.setCustomValidity("Delivery is blocked for this shipment.");
                            val.reportValidity();
                        }
                        else if (docres.sErrMsg == "Invalid Docket No" || docres.sErrMsg.length > 1) {
                            this.invaliddocket = true;
                            let val = this.template.querySelector(".docketno");
                            val.setCustomValidity("Docket Number was not Found in Gems");
                            val.reportValidity();
                        } 
                        else if (this.docketresponse.result[0].DOCKET_STATUS == "REBOOKED" && this.rtforre == "Claim") {
                            let val = this.template.querySelector(".docketno");
                            val.setCustomValidity("Claim cannot be registered for the Rebooked docket");
                            val.reportValidity();
                        } 
                        else if (this.subtype == 'STC COOLING') {
                            if (!this.docketresponse.result[0].STOCK_OU) {
                                let val = this.template.querySelector(".docketno");
                                val.setCustomValidity("You can raise a complaint only if cooling is more than 12 hrs");
                                val.reportValidity();
                            } else if ((this.docketresponse.result[0].STOCK_OU != null && this.docketresponse.result[0].STOCK_OU != '') && this.docketresponse.result[0].DELIVERY_STN != this.docketresponse.result[0].STOCK_OU) {
                                var date1 = new Date(this.docketresponse.result[0].STOCK_IN_DATE_TIME);
                                var date2 = new Date();
                                var Difference_In_Time = date2.getTime() - date1.getTime();
                                var Difference_In_hours = Math.round(Difference_In_Time / (1000 * 3600));
                                var addDate = new Date(this.docketresponse.result[0].ASSURED_DLY_DT);
                                if (addDate > date2 && Difference_In_hours > 12) {
                                    this.navigateToNewCasDefaults(true);
                                } else {
                                    let val = this.template.querySelector(".docketno");
                                    val.setCustomValidity("Either ADD is crossed or Cooling times is less than 12 hours.");
                                    val.reportValidity();
                                }
                            }
                        } 
                        else {
                            let val = this.template.querySelector(".docketno");
                            val.setCustomValidity("");
                            val.readonly = true;
                            this.docketValid = true;
                            this.navigateToNewCasDefaults(true);
                        }
                    }
                    else{
                        const event = new ShowToastEvent({
                            title: "No Results Found",
                            message: this.docketresponse?.sErrMsg,
                            variant: "error",
                            mode: "sticky"
                        });
                        this.dispatchEvent(event);
                    }
                } else {
                    return;
                }
            })
            .catch((err) => {
                console.log(err);
                const event = new ShowToastEvent({
                    title: "Failed",
                    message: err?.body?.message,
                    variant: "error",
                    mode: "sticky"
                });
                this.dispatchEvent(event);
                this.loadingval = false;
            });
    }
    checkError(event) {

    }
    get DocketValidate() {
        if (this.recordTypeId.name != "Email_Case" && this.recordTypeId.name != "Pick Up" && this.type != "ADD Extension" && this.type != "Bill back of Expenses" && this.type != "Appointment Delivery" && this.type != "Exception" && this.type != "UCG Confirmation" && this.type != "Pending Pickup" && this.type != "Prospect Pickup" && this.type != "Call Disposition") { 
            return true;
        }
        return false;
    }
    handlerecordid(event) {
        let recid = event.target.value;
        console.log(recid);
        this.recordTypeId = recid;

        // this.template.querySelector('lightning-record-edit-form').re
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
    navigateToNewCasDefaults(includedefault = false) {

        this.closeTab();
        let defaultValues;
        if (includedefault) {
            let respo = this.docketresponse.result[0];

            //let companycode=this.companyId;
            let delstn = respo.DELIVERY_STN;
            let booking = respo.BOOKING_STN;
            let accId = respo.CUSTOMER_CODE;
            let stockUO = respo.STOCK_OU;
            let defaultArray = {
                    Docket_Number__c: this.docket,
                    Type: this.type,
                    Consignee_Mobile_No__c: respo.CONSIGNEE_MOBILE_NO,
                    //Stock_OU__c: (respo.STOCK_OU!= null && respo.STOCK_OU !='')?totalres[respo.STOCK_OU]:"",
                    Consignee_PinCode__c: respo.CONSIGNEE_PINCODE,
                    Risk_Coverage__c: respo.DOCKET_TYPE,
                    COD_Type__c: this.docketresponse.COD_TYPE,
                    Decl_Cargo_value__c: respo.DECL_CARGO_VAL,
                    Consignor_Name__c: respo.CONSIGNOR_NAME,
                    Booking_OU__c: this.totalres[booking],
                    AccountId: this.totalres[accId],
                    Docket_Status__c: respo.DOCKET_STATUS,
                    No_of_Packages_Delivered__c: respo.NO_OF_PKGS_DELIVERED,
                    //Contract_No__c: respo.CONTRACT_NO,
                    Assured_Delivery_Date__c: respo.ASSURED_DLY_DT,
                    Consignor_Mobile_No__c: respo.CONSIGNOR_MOBILE_NO,
                    Actual_Weight_Booked__c: respo.ACTUAL_WT,
                    Booking_Date__c: respo?.BKG_DT,
                    POD_Type__c: respo.COD_TYPE,
                    COD_Type__c: respo.POD_TYPE,
                    //Customer_Code__c: respo.CUSTOMER_CODE,
                    Delivery_OU__c: this.totalres[delstn],
                    //AccountId: this.totalres[accId],
                    Consignor_Pincode__c: respo.CONSIGNOR_PINCODE,
                    PROD_SERV_CODE__c: respo.PROD_SERV_CODE,
                    Charged_Wt__c: respo.CHARGED_WT,
                    No_Of_Packages_Booked__c: respo.NO_OF_PKGS,
                    Consignee_Name__c: respo.CONSIGNEE_NAME,
                    Actual_delivery_Date__c: respo.APPROVED_DLY_DT,
                    Docket_Validation__c: "Valid",
                    Priority: "Normal",
                    Company_of__c: this.docketresponse.companyId == 'GKE' ? "102" : "101",
                    Sub_Type__c: this.subtype
                }
                // if (this.docketresponse.companyId=='GKE')
                // {
                // 	defaultArray.Company_of__c = '102';
                // }else{
                // 	defaultArray.Company_of__c = '101';
                // }
            if(respo.PDC_BLOCK != null && respo.PDC_BLOCK == 'N'){
                defaultArray.PDC_BLOCK__c = '0';
            }else if(respo.PDC_BLOCK != null && respo.PDC_BLOCK == 'Y'){
                defaultArray.PDC_BLOCK__c = '1';
            }
            if (respo.STOCK_OU != null && respo.STOCK_OU != '') {
                defaultArray.Stock_OU__c = this.totalres[respo.STOCK_OU];
            }
            if (respo.STOCK_RECEIVING_OU != null && respo.STOCK_RECEIVING_OU != '') {
                defaultArray.Stock_Receiving_OU__c = this.totalres[respo.STOCK_RECEIVING_OU];
            }
            if (this.subtype == 'STC COOLING') {
                console.log('---- stockUO--', this.totalres[stockUO]);
                defaultArray.Complaint_Actionable_OU__c = this.totalres[stockUO];
                defaultArray.CCEC_Action_OU__c = this.totalres[stockUO];
                defaultArray.Company_of__c = this.docketresponse.companyId == 'GKE' ? "102" : "101";
            }
            defaultValues = encodeDefaultFieldValues(defaultArray);
        } else {
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
                // alert('result--' + result);
                this.caseOpened = result;
                console.log('This is the result: ', result);
            })
            .catch(error => {
                console.error('--- error occur when get case--', error);
            })
    }
}