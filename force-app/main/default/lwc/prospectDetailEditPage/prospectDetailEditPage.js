import { LightningElement, track, api } from 'lwc';

export default class prospectDetailEditPage extends LightningElement {
    @track isModalOpen = false;
    @api recordId;
    @api recordTypeId;
    @track type = 'Pick Up';
    @track showspinner = false;
    @track prospectToPickup = true;

    handleSubmit(event) {
        event.preventDefault();
        this.showspinner = true;
    }

    handleSuccess(event) {
        this.showspinner = false;
    }
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModalchild() {
        let ev = new CustomEvent('closemodalchild');
        this.dispatchEvent(ev);
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }
}