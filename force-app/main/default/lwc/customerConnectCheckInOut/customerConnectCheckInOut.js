import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getLocationService } from 'lightning/mobileCapabilities';
import checkForOwnerAndInOrOut from '@salesforce/apex/GeoLocationController.checkForOwnerAndInOrOut';
import UpdateCheckInLocation from '@salesforce/apex/GeoLocationController.UpdateCheckInLocation';
import UpdateCheckInLocationCheckOut from '@salesforce/apex/GeoLocationController.UpdateCheckInLocationCheckOut';

export default class CustomerConnectCheckInOut extends NavigationMixin(LightningElement) {
    @api recordId;
    objectApiName = 'Customer_Connect__c';
    isAccompanied = false;
    isButtonVisible = false;
    isContinueDisable = false;

    OWNER_CHECK;
    LOCATION_CHECK;

    inputData = {
        Accompanied__c : 'No',
        AcompaniedWith__c : null,
        Key_Discussion_Description__c : '',
        Closure_Remarks__c : ''
    };

    connectedCallback(){
        // setTimeout(() => {
            checkForOwnerAndInOrOut({recordId : this.recordId}).then(res => {
                //Handle Result
                this.OWNER_CHECK = res.OWNER_CHECK;
                this.LOCATION_CHECK = res.LOCATION_CHECK;
                if(!this.LOCATION_CHECK && this.OWNER_CHECK){
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
                                    UpdateCheckInLocation({recordId : this.recordId,latitude : latitude,longitude : longitude}).then(returnData => {
                                        this.showToast('Location Captured!!',returnData.message , 'success', 'sticky');
                                        this.navigateToVisit(this.recordId);
                                    }).catch(error => {
                                        this.showToast('Not Updated!!','Location Not Updated On Record.'+error , 'error', 'sticky');
                                    })
                                }
                                else{
                                    //Location Getting Null
                                    this.showToast('Error In Location Capturing!','Please make sure your location is on and you are in good connectivity area,Then Try Again.' , 'error', 'sticky');
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
                }else if(!this.LOCATION_CHECK && !this.OWNER_CHECK){
                    this.showToast('Warning!','You Are Not Authorized Person For do This Action.','warning','dismissable');
                }
            }).catch(error => {
                //Handle Error
                console.log('Res -> ',JSON.stringify(error,null,2));
                this.showToast('Error In Check Owner And Button!',error,'error','dismissable'); 
            });
        // }, 2000);
    }

    handleAccompaniedChange(event){
        if(event.target.fieldName == 'AcompaniedWith__c'){
            this.inputData[event.target.fieldName] = event.detail.value[0];
        }else{
            this.inputData[event.target.fieldName] = event.detail.value;
        }
        let isKeyDiscussion = (this.inputData.Key_Discussion_Description__c == null || this.inputData.Key_Discussion_Description__c == '');
        let isClosureRemarks = (this.inputData.Closure_Remarks__c == null || this.inputData.Closure_Remarks__c == '');
        this.isAccompanied = (this.inputData.Accompanied__c == 'Yes');
        if(this.inputData.Accompanied__c == 'No'){
            this.inputData.AcompaniedWith__c = null;
        }
        this.isButtonVisible = ((!this.isAccompanied && !isKeyDiscussion && !isClosureRemarks) || (!isClosureRemarks && this.isAccompanied && !isKeyDiscussion && (this.inputData.AcompaniedWith__c != '' && this.inputData.AcompaniedWith__c)));
    }

    handleContinueClick(){
        this.isContinueDisable = true;
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
                    UpdateCheckInLocationCheckOut({recordId : this.recordId,latitude : latitude,longitude : longitude,Accompanied:this.inputData.Accompanied__c,AccompaniedWith : this.inputData.AcompaniedWith__c,KeyDiscussion : this.inputData.Key_Discussion_Description__c, ClosureRemarks : this.inputData.Closure_Remarks__c}).then(returnData => {
                        this.showToast('Location Captured!!',returnData.message , 'success', 'sticky');
                        this.navigateToVisit(this.recordId);
                    }).catch(error => {
                        this.showToast('Not Updated!!','Location Not Updated On Record.'+JSON.stringify(error) , 'error', 'sticky');
                        this.isContinueDisable = false;
                    })
                }
                else{
                    //Location Getting Null
                    this.showToast('Error In Location Capturing!','Please make sure your location is on and you are in good connectivity area,Then Try Again.' , 'error', 'sticky');
                    this.isContinueDisable = false;
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
                this.isContinueDisable = false;
            });
        }
        else{
            //Handle location Not Available
            this.showToast('Warnnig', 'Please ensure location services are enabled and connectivity is available!', 'error', 'dismissable');
            this.isContinueDisable = false;
        }
    }

    navigateToVisit(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Customer_Connect__c',
                actionName: 'view'
            },
        });
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
}