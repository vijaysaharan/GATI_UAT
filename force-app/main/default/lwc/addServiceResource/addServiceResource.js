import { LightningElement, api, wire } from 'lwc';
import getRoleSubordinateUsers from '@salesforce/apex/AddServiceResource.getRoleSubordinateUsers';
import getAccount from '@salesforce/apex/AddServiceResource.getAccount';
import Id from '@salesforce/user/Id';
import { CloseActionScreenEvent } from 'lightning/actions';
//c/accountTeamMemberCSVDownloadimport saveSerivecresource from '@salesforce/apex/AddServiceResource.saveSerivecresource';
import saveSerivecresource from '@salesforce/apex/AddServiceResource.saveSerivecresource';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddServiceResource extends LightningElement {
    userData;
    selectedUser;
    userId = Id;
    @api recordId;
    accountname;
    isSpninner = false;
    isdabled = false;
    connectedCallback() {
        if (this.recordId) {
            this.fetAccount();
        }

        this.fetchUsersOntheBasesOfRole();
    }

    fetchUsersOntheBasesOfRole() {
        getRoleSubordinateUsers()
            .then(result => {
                this.fetAccount();
                this.userData = result;
                console.log('-- all data--', result);
            })
            .catch(error => {
                console.error('--- error occur when fetch user--', error);
                this.showToasMessage('OOPs-' + error, 'error', 'ERROR');
            })
    }

    handleChange(event) {
        this.selectedUser = event.detail.value;
        console.log('--- selected --', this.selectedUser);
    }

    fetAccount() {
        getAccount({ recordId: this.recordId })
            .then(resp => {
                this.accountname = resp;
            })
            .catch(error => {
                console.error('--- error occur when fetch account--', error);
                this.showToasMessage('OOPs-' + error, 'error', 'ERROR');
            })
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        this.isSpninner = true;
        this.isdabled = true;
        saveSerivecresource({ recordId: this.recordId, userId: this.selectedUser })
            .then(result => {
                console.log('-- result--', result);
                if (result == 'success') {
                    this.showToasMessage('Case is Updating, Wait for a while !', 'success', 'SUCCESS');
                    this.isSpninner = false;
                    this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    this.showToasMessage('OOPs-' + result, 'error', 'ERROR');
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
            .catch(error => {
                //this.showToasMessage('OOPs-' + error, 'error', 'ERROR');
                //this.dispatchEvent(new CloseActionScreenEvent());
                //console.error('--- error occur when save resource--', error);
                if (error.body && error.body.message) {
                    this.showToasMessage('Error: ' + error.body.message, 'error', 'ERROR');
                } else {
                    this.showToasMessage('An unknown error occurred.', 'error', 'ERROR');
                }
                this.dispatchEvent(new CloseActionScreenEvent());
                console.error('--- error occur when save resource--', error);
            })
    }

    showToasMessage(message, variant, title) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);

    }

}