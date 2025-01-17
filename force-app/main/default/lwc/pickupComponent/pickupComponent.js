import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getPickupDetails from '@salesforce/apex/PickupComponentController.getPickupDetails'

export default class PickupComponent extends NavigationMixin(LightningElement) {
    orgId;
    distance;
    errMsg = '';
    @track isError = false;
    @api recordTypeId;
    @api defValue = 'Pick Up';
    @track isDisabled = false;
    pickupDate;

    connectedCallback() {
        console.log('--- record Type id check--', this.recordTypeId);
    }
    pickupChange(event) {
        var pickup = event.target.value;
        this.orgId = pickup;
        this.getOrganizationData();
        //this.pickupDateChange();
    }

    pickupDateChange(event) {
        let today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = new Date(mm + '/' + dd + '/' + yyyy);
        this.pickupDate = event.target.value;

        var temp = this.pickupDate.split('T');
        var tempDate = temp[0].split('-');
        let finalDate = new Date(tempDate[1] + '/' + tempDate[2] + '/' + tempDate[0]);
        console.log('-- diiff---', finalDate);
        let difference = finalDate.getTime() - today.getTime();
        console.log(difference);
        var days_difference = difference / (1000 * 60 * 60 * 24);
        var todayCheck = new Date();
        var dateTimeCheck = new Date(this.pickupDate) - todayCheck;
        console.log('--- check days--', days_difference);
        var diffMins = Math.round(((dateTimeCheck) / 1000) / 60);
        console.log('-- chec 1 minutes--', diffMins);
        var shiftTime = new Date(this.pickupDate).getHours();
        console.log('--- check hours--', shiftTime);
        var shiftTimeMinutes = new Date(this.pickupDate).getMinutes();
        console.log('--- check hours time---', shiftTimeMinutes);
        var selectedDate = new Date(tempDate[1] + '/' + tempDate[2] + '/' + tempDate[0]);
        var selectedDay = selectedDate.getDay();
        console.log('Selected day:', selectedDay);
        if (selectedDay === 0) {
            this.errMsg = 'You can not raise pickup on Sundays.';
        } else if (this.distance >= 0 && this.distance <= 25 && days_difference != 0 && days_difference > 7) {
            this.errMsg = 'You can raise pickup today or within 7 days';
        }else if (days_difference == 0 && (shiftTime <= 9 && shiftTimeMinutes != 0) || (shiftTime >= 16 && shiftTimeMinutes > 30)) {
            this.errMsg = 'Pickup time for today should be in between 9 AM to 4:30 PM';
        }else if ((shiftTime <= 9 && shiftTimeMinutes != 0) || (shiftTime >= 19 && shiftTimeMinutes != 0)) {
            this.errMsg = 'Pickup time should be in between 9AM to 7PM';
        } else if (this.distance >= 0 && this.distance <= 25 && days_difference == 0 && diffMins < 90) {
            this.errMsg = 'Pickup time should be 90 minutes from the current time';
        } else if (this.distance > 25 && this.distance <= 50 && days_difference == 0 || days_difference > 8) {
            this.errMsg = 'Pickup date for the selected pin code is allowed from system date + 1 and for a maximum of 7 days';
        } else if (this.distance > 50 && this.distance <= 200 && (days_difference == 0 || days_difference == 1) || days_difference > 9) {
            this.errMsg = 'Pickup date for the selected pin code is allowed from system date + 2 and for a maximum of 7 days.';
        } else if (this.distance > 200 && this.distance <= 300 && (days_difference == 0 || days_difference == 1 || days_difference == 2) || days_difference > 10) {
            this.errMsg = 'Pickup date for the selected pin code is allowed from system date + 3 and for a maximum of 7 days.';
        } else if (this.distance > 300 && (days_difference == 0 || days_difference == 1 || days_difference == 2 || days_difference == 3) || days_difference > 11) {
            this.errMsg = 'Pickup date for the selected pin code is allowed from system date + 4 and for a maximum of 7 days.';
        } else if (days_difference < 0) {
            this.errMsg = 'You can not raise pickup past date';
        } else {
            this.errMsg = '';
        }

        if (this.errMsg != null && this.errMsg != '' && this.errMsg != undefined) {
            this.isError = true;
            this.isDisabled = true;
        } else {
            this.isError = false;
            this.isDisabled = false;
        }
    }

    getOrganizationData(event) {
        getPickupDetails({ organizationId: this.orgId })
            .then(result => {
                this.distance = result;
                console.log('--- distance--', this.distance);

            })
            .catch(error => {
                console.error('--- error occur when fetch org data--', error);
            })
    }

    onCancel() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Case",
                actionName: "list"
            },
            state: {
                filterName: "Pickup"
            }
        });
    }

    navigateToNewPickupDefaults() {
        if (this.orgId == null || this.orgId == '' || this.orgId == undefined || this.pickupDate == null || this.pickupDate == '' || this.pickupDate == undefined) {
            this.errMsg = 'Please select shipper pin code and Pick up date.';
            this.isError = true;
            this.isDisabled = true;
        } else {
            this.isError = false;
            this.isDisabled = false;
            let defaultValues;
            let defaultArray = {
                    Type: 'Pick Up',
                    Pickup_Date__c: this.pickupDate,
                    Pick_Up_Pincode__c: this.orgId
                }
                //defaultValues = defaultArray;
            console.log('--checking ', defaultArray);
            defaultValues = encodeDefaultFieldValues(defaultArray);
            console.log('--checking ', defaultValues);
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
    }
}