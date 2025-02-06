import { LightningElement , api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOperationalUnit from '@salesforce/apex/OUAssignController.getOperationalUnit';
import updateAssignedOU from '@salesforce/apex/OUAssignController.updateAssignedOU';

export default class AssigningOprationalUnit extends NavigationMixin(LightningElement) {
    @api recordId;
    @track operations = [];
    @track selectedAssignedOu;
    @track isNoData = false;

    get ouOptions() {
        return this.operations.map(ou => ({
            label: ou.operationName,
            value: ou.operationId
        }));
    }

    get isOperations(){
        return (this.operations != null && this.operations.length > 0) ? true : false;
    }

    connectedCallback(){
        setTimeout(() => {
            getOperationalUnit({leadId : this.recordId}).then(ouList => {
                this.operations = JSON.parse(JSON.stringify(ouList));
                this.isNoData = !this.isOperations;
            }).catch(error => {
                this.showToast('Get Issue !','Some Error In OU fetch.'+JSON.stringify(error),'error');
            });
        }, 500);
    }

    handleSelectionChange(event) {
        this.selectedAssignedOu = event.detail.value;
    }

    handleUpdateAssignedOu(){
        if(this.selectedAssignedOu != null){
            updateAssignedOU({leadId : this.recordId, assignedOuId : this.selectedAssignedOu}).then(result => {
                if(result){
                    this.showToast('Assigned OU Updated !','Operational Unit Updated.','success');
                    this.navigateToRecord();
                }
                else{
                    this.showToast('Update OU Issue !','Some Error In OU Update.','error');
                }
            }).catch(error => {
                this.showToast('Update OU Issue !',JSON.stringify(error),'error');
            });
        }
        else{
            this.showToast('Update OU Issue !','Please select at least one OU.','warning');
        }
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

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}