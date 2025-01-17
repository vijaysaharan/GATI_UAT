import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkForButton from '@salesforce/apex/visitStartAndEndController.checkForButton';
import createTodaysVisit from '@salesforce/apex/visitStartAndEndController.createTodaysVisit';
import endTodaysVisit from '@salesforce/apex/visitStartAndEndController.endTodaysVisit';
import getPicklistOptions from '@salesforce/apex/visitStartAndEndController.getPicklistOptions';
import getCustomerConnectData from '@salesforce/apex/visitStartAndEndController.getCustomerConnectData';
import getTravelPriceForCurrentUser from '@salesforce/apex/visitStartAndEndController.getTravelPriceForCurrentUser';
import { getLocationService } from 'lightning/mobileCapabilities';

export default class VisitStartAndEndButton extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;

    @track todayTime;
    @track currentTime;
    @track secondCount;

    @track askForPlace = false;
    @track askForPlaceInEnd = false;
    @track isHomeSelected = false;
    @track AllFilled = true;
    @track isCustomerConnect = true;
    @track visitStartDisable = true;
    isEndContinueClicked = false;

    @track customerConnectList;
    @track visitRecordData;

    visitRecordId;
    isVisitEnd = false;
    isVisitStart = false;
    isDisable = false;

    StartPlaceOptions;
    visitModeOptions;
    travelPriceList;

    createVisit = {
        sobjectType: 'Visit__c',
        Visit_Start_DateTime__c: null,
        Visit_End_DateTime__c: null,
        Visit_Date__c: null,
        Source_Geo_Coordinate__Latitude__s: null,
        Source_Geo_Coordinate__Longitude__s: null,
        Destination_Geo_Coordinate__Latitude__s: null,
        Destination_Geo_Coordinate__Longitude__s: null,
        Employee_Name__c: null,
        Remark__c: null,
        Visit_Start_From__c: 'Office',
        Mode__c: null
    }

    endVisit = {
        Ending_Note__c: null,
        End_Point__c: 'Office',
    }
    connectedCallback() {
        const today = new Date();
        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June', 'July',
            'August', 'September', 'October', 'November', 'December'
        ];
        const month = monthNames[today.getMonth()];
        const day = String(today.getDate()).padStart(2, '0');
        const year = today.getFullYear();
        const formattedDate = `${month} ${day}, ${year}`;
        const currentDayIndex = today.getDay();
        const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const currentDay = daysOfWeek[currentDayIndex];
        this.todayTime = formattedDate + ' ' + currentDay;

        this.updateTime();
        this.intervalId = setInterval(() => {
            this.updateTime();
        }, 1000);

        getPicklistOptions({ objectName: 'Visit__c', fieldName: 'Visit_Start_From__c' }).then(data => {
            this.StartPlaceOptions = data.map(option => {
                return { label: option, value: option };
            });
        });

        getTravelPriceForCurrentUser().then(priceList => {
            this.travelPriceList = JSON.parse(JSON.stringify(priceList));
            getPicklistOptions({ objectName: 'Visit__c', fieldName: 'Mode__c' }).then(data => {
                this.visitModeOptions = data.map(option => {
                    return { label: option, value: option };
                });
                if (this.travelPriceList.TwoWheelerEntitlement__c == 0) {
                    this.visitModeOptions = this.visitModeOptions.filter(mod => mod.label != 'Two wheeler');
                }
                if (this.travelPriceList.FourWheelerEntitlement__c == 0) {
                    this.visitModeOptions = this.visitModeOptions.filter(mod => mod.label != 'Four wheeler');
                }
                if (this.travelPriceList.FourWheelerEntitlement__c == 0 && this.travelPriceList.TwoWheelerEntitlement__c == 0) {
                    this.visitModeOptions = this.visitModeOptions.filter(mod => mod.label != 'Four wheeler' && mod.label != 'Two wheeler');
                }
            }).catch(er => {
                this.showToast('Error', JSON.stringify(er), 'error', 'dismissable');
            });
        }).catch(err => {
            getPicklistOptions({ objectName: 'Visit__c', fieldName: 'Mode__c' }).then(data => {
                this.visitModeOptions = data.map(option => {
                    return { label: option, value: option };
                });
                this.visitModeOptions = this.visitModeOptions.filter(mod => mod.label != 'Four wheeler' && mod.label != 'Two wheeler');
            }).catch(err => {
                this.showToast('Error', JSON.stringify(err), 'error', 'dismissable');
            })
        });

        checkForButton().then(res => {
            if (res != 'visitStart') {
                this.visitRecordId = JSON.parse(JSON.stringify(res));
                this.isVisitEnd = true;
                this.getCustomerConnectRec(true);
            }
            else {
                this.isVisitStart = true;
                this.getCustomerConnectRec(true);
            }
        }).catch(e => {
            this.isVisitStart = true;
        });
    }

    getCustomerConnectRec(visit) {
        getCustomerConnectData().then(cusData => {
            var allData = JSON.parse(JSON.stringify(cusData));
            this.customerConnectList = allData.CustomerRec;
            if (this.customerConnectList.length == 0) {
                this.isCustomerConnect = false;
            } else {
                this.isCustomerConnect = true;
            }
            if (visit) {
                this.visitRecordData = allData.visitRec;
            }
            this.customerConnectList.forEach(el => {
                if (el.Customer_Code__c != undefined && el.Customer_Code__r != null) {
                    el.AccountName = el.Customer_Code__r.Name;
                }
                if (el.Lead__c != undefined && el.Lead__r != null) {
                    el.LeadName = el.Lead__r.Name;
                }
                if (el.Visit_Start_Date__c != undefined && el.Visit_Start_Date__c != null) {
                    const dateObject = new Date(el.Visit_Start_Date__c);
                    console.log(dateObject);
                    const ISTOffset = 0;
                    const ISTTime = new Date(dateObject.getTime() + (ISTOffset * 60 * 1000));
                    const day = String(ISTTime.getDate()).padStart(2, '0');
                    const month = String(ISTTime.getMonth() + 1).padStart(2, '0');
                    const year = ISTTime.getFullYear();
                    const hours = String(ISTTime.getHours()).padStart(2, '0');
                    const minutes = String(ISTTime.getMinutes()).padStart(2, '0');
                    const seconds = String(ISTTime.getSeconds()).padStart(2, '0');
                    let formattedDateTime = `${day}-${month}-${year} ${hours}:${minutes}:${seconds}`;
                    el.StartDateTime = formattedDateTime;
                }
            });
        }).catch(err => {
            console.log(JSON.stringify(err));
        });
    }

    handlevisitStart() {
        this.isVisitStart = false;
        this.askForPlace = true;
        this.visitStartDisable = false;
    }

    handlevisitEnd() {
        this.isVisitEnd = false;
        this.askForPlaceInEnd = true
    }

    handleCancelPopup() {
        this.askForPlace = false;
        this.isVisitStart = true;
    }

    handleCancelPopupEnd() {
        this.askForPlaceInEnd = false;
        this.isVisitEnd = true;
    }

    handleVisitInputChange(event) {
        var currFeild = event.currentTarget.dataset.field;
        console.log(currFeild);
        var currValue = event.detail.value;
        console.log(currValue);

        this.createVisit[currFeild] = currValue;

        if (currFeild == 'Visit_Start_From__c' && currValue == 'Home') {
            this.isHomeSelected = true;
            if (this.createVisit.Remark__c != null && this.createVisit.Remark__c != '') {
                this.AllFilled = true;
            }
            else {
                this.AllFilled = false;
            }
        }
        if (currFeild == 'Visit_Start_From__c' && currValue == 'Office') {
            this.isHomeSelected = false;
            this.createVisit.Remark__c = null;
            this.AllFilled = true;
        }

        if (currFeild == 'Remark__c') {
            if (this.createVisit.Remark__c != null && this.createVisit.Remark__c != '') {
                this.AllFilled = true;
            }
            else {
                this.AllFilled = false;
            }
        }
    }

    handleVisitInputChangeForEnd(event) {
        var currFeild = event.currentTarget.dataset.field;
        var currValue = event.detail.value;

        this.endVisit[currFeild] = currValue;

        if (currFeild == 'End_Point__c' && currValue == 'Home') {
            this.isHomeSelected = true;
            if (this.endVisit.Ending_Note__c != null && this.endVisit.Ending_Note__c != '') {
                this.AllFilled = true;
            }
            else {
                this.AllFilled = false;
            }
        }
        if (currFeild == 'End_Point__c' && currValue == 'Office') {
            this.isHomeSelected = false;
            this.endVisit.Ending_Note__c = null;
            this.AllFilled = true;
        }

        if (currFeild == 'Ending_Note__c') {
            if (this.endVisit.Ending_Note__c != null && this.endVisit.Ending_Note__c != '') {
                this.AllFilled = true;
            }
            else {
                this.AllFilled = false;
            }
        }
    }

    handleContinue() {
        this.visitStartDisable = true;
        const myLocationService = getLocationService();
        if (myLocationService.isAvailable()) {
            //Location Available
            myLocationService.getCurrentPosition({ enableHighAccuracy: true }).then(result => {
                //this.showToast('Success',result?.coords?.latitude + ' '+result?.coords?.longitude , 'success', 'sticky');
                    let obj = {
                        latitude : result?.coords?.latitude,
                        longitude : result?.coords?.longitude
                    }
                    let position = obj;
                    if(position != null){
                        //this.showToast('Success 2',position?.latitude + ' '+position?.longitude , 'success', 'sticky');
                        var latitude = position?.latitude;
                        var longitude = position?.longitude;
                        this.createVisit.Source_Geo_Coordinate__Latitude__s = latitude;
                        this.createVisit.Source_Geo_Coordinate__Longitude__s = longitude;
                        createTodaysVisit({ visitData: this.createVisit }).then(res => {
                            this.isVisitStart = false;
                            this.isVisitEnd = true;
                            this.visitRecordId = JSON.parse(JSON.stringify(res.Id));
                            this.askForPlace = false;
                            this.getCustomerConnectRec(true);
                            window.location.reload();
                            this.showToast('Initiating the Journey', 'Your journey has been successfully initiated!', 'success', 'Sticky');
                        }).catch(err => {
                            this.showToast('Error', 'Error ' + JSON.stringify(err), 'error', 'dismissable');
                            this.visitStartDisable = false;
                        });
                    }
                    else{
                        this.visitStartDisable = false;
                    }
                }).catch(error=>{
                    let errorMessage = '';
                    switch (error.code) {
                    case "LOCATION_SERVICE_DISABLED":
                        errorMessage = "Location service on the device is disabled."; // Android only
                        break;
                    case "USER_DENIED_PERMISSION":
                        errorMessage = "User denied permission to use location service on the device.";
                        break;
                    case "USER_DISABLED_PERMISSION":
                        errorMessage = "Toggle permission to use location service on the device from Settings.";
                        break;
                    case "SERVICE_NOT_ENABLED":
                        errorMessage = "Location service on the device is not enabled.";
                        break;
                    case "UNKNOWN_REASON":
                    default:
                        errorMessage = error.message;
                        break;
                    }
                    this.showToast('Error', errorMessage , 'error', 'dismissable');
                });
        }
        else{
            //Handle location Not Available
            this.showToast('Warnnig', 'Please ensure location services are enabled and connectivity is available!', 'error', 'dismissable');
        }
        /*
        if (navigator.geolocation && this.validateInputs()) {
            navigator.geolocation.getCurrentPosition(position => {
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
                this.createVisit.Source_Geo_Coordinate__Latitude__s = latitude;
                this.createVisit.Source_Geo_Coordinate__Longitude__s = longitude;
                createTodaysVisit({ visitData: this.createVisit }).then(res => {
                    this.isVisitStart = false;
                    this.isVisitEnd = true;
                    this.visitRecordId = JSON.parse(JSON.stringify(res.Id));
                    this.askForPlace = false;
                    this.getCustomerConnectRec(true);
                    window.location.reload();
                    this.showToast('Initiating the Journey', 'Your journey has been successfully initiated!', 'success', 'Sticky');
                }).catch(err => {
                    this.showToast('Error', 'Error ' + JSON.stringify(err), 'error', 'dismissable');
                    this.visitStartDisable = false;
                });
            });
        } else {
            this.visitStartDisable = false;
        }
        */
    }

    handleContinueEnd() {
        const myLocationService = getLocationService();
        if (myLocationService.isAvailable()) {
            //Location Available
            myLocationService.getCurrentPosition({ enableHighAccuracy: true }).then(result => {
                //this.showToast('Success',result?.coords?.latitude + ' '+result?.coords?.longitude , 'success', 'sticky');
                let obj = {
                    latitude : result?.coords?.latitude,
                    longitude : result?.coords?.longitude
                }
                let position = obj;
                if(position != null){
                    var latitude = position?.latitude;
                    var longitude = position?.longitude;
                    if (this.visitRecordId != null && this.validateInputs()) {
                        endTodaysVisit({ latitude: latitude, longitude: longitude, recordId: this.visitRecordId, EndPoint: this.endVisit.End_Point__c, EndingNote: this.endVisit.Ending_Note__c }).then(res => {
                            if (res) {
                                this.isVisitEnd = false;
                                this.isVisitStart = true;
                                //this.isDisable = true;
                                this.showToast('Concluding the Journey', 'Your journey activities for the day have been officially conclude!', 'success', 'dismissable');
                                this.navigateToVisit(this.visitRecordId);
                                this.isEndContinueClicked = false;
                            }else{
                                this.showToast('Error In Concluding the Journey', 'Please check that you check-out on all customer connect of related to current visit!', 'success', 'dismissable');
                                this.isEndContinueClicked = false;
                            }
                        }).catch(err => {
                            this.showToast('Error', 'Error ' + JSON.stringify(err), 'error', 'dismissable');
                            this.isEndContinueClicked = false;
                        });
                    }
                }
            }).catch(error => {
                let errorMessage = '';
                switch (error.code) {
                case "LOCATION_SERVICE_DISABLED":
                    errorMessage = "Location service on the device is disabled."; // Android only
                    break;
                case "USER_DENIED_PERMISSION":
                    errorMessage = "User denied permission to use location service on the device.";
                    break;
                case "USER_DISABLED_PERMISSION":
                    errorMessage = "Toggle permission to use location service on the device from Settings.";
                    break;
                case "SERVICE_NOT_ENABLED":
                    errorMessage = "Location service on the device is not enabled.";
                    break;
                case "UNKNOWN_REASON":
                default:
                    errorMessage = error.message;
                    break;
                }
                this.showToast('Error', errorMessage , 'error', 'dismissable');
            });
        }
        else{
            //Handle location Not Available
            this.showToast('Warnnig', 'Please ensure location services are enabled and connectivity is available!', 'error', 'dismissable');
            return null;
        }
        /*
        if (navigator.geolocation) {
            this.isEndContinueClicked = true;
            navigator.geolocation.getCurrentPosition(position => {
                var latitude = position.coords.latitude;
                var longitude = position.coords.longitude;
                if (this.visitRecordId != null && this.validateInputs()) {
                    endTodaysVisit({ latitude: latitude, longitude: longitude, recordId: this.visitRecordId, EndPoint: this.endVisit.End_Point__c, EndingNote: this.endVisit.Ending_Note__c }).then(res => {
                        if (res) {
                            this.isVisitEnd = false;
                            this.isVisitStart = true;
                            //this.isDisable = true;
                            this.showToast('Concluding the Journey', 'Your journey activities for the day have been officially conclude!', 'success', 'dismissable');
                            this.navigateToVisit(this.visitRecordId);
                            this.isEndContinueClicked = false;
                        }else{
                            this.showToast('Error In Concluding the Journey', 'Please check that you check-out on all customer connect of related to current visit!', 'success', 'dismissable');
                            this.isEndContinueClicked = false;
                        }
                    }).catch(err => {
                        this.showToast('Error', 'Error ' + JSON.stringify(err), 'error', 'dismissable');
                        this.isEndContinueClicked = false;
                    });
                }
            });
        }
        else {
            this.showToast('Warnnig', 'Please ensure location services are enabled and connectivity is available!', 'error', 'dismissable');
        }
        */
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

    updateTime() {
        const now = new Date();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        this.currentTime = `${hours}:${minutes}`;
        this.secondCount = `:${seconds}`;
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    handleCustomerClick(event) {
        var recId = event.currentTarget.dataset.id;
        console.log(JSON.stringify(recId));
        if (recId) {
            this.navigateToCustomer(recId);
        }
    }

    handleVisitClick(event) {
        var visitRecId = event.currentTarget.dataset.id;
        if (visitRecId) {
            this.navigateToVisit(visitRecId);
        }
    }

    navigateToVisit(visitRecId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: visitRecId,
                objectApiName: 'Visit__c',
                actionName: 'view'
            },
        });
    }

    navigateToCustomer(cusId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: cusId,
                objectApiName: 'Customer_Connect__c',
                actionName: 'view'
            },
        });
    }

    validateInputs() {
        var valid = true;
        var inputs = this.template.querySelectorAll('lightning-input');
        inputs.forEach(element => {
            if (!element.reportValidity()) {
                valid = false;
            }
        });
        var comboBoxes = this.template.querySelectorAll('lightning-combobox');
        comboBoxes.forEach(element => {
            if (!element.reportValidity()) {
                valid = false;
            }
        });
        return valid;
    }
}