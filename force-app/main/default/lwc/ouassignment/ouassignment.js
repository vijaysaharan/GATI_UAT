import { LightningElement,track } from 'lwc';
import getorgmaster from '@salesforce/apex/ouassignment.getorgmaster';

export default class Ouassignment extends LightningElement {
    @track orgMasterRecord;
    searchValue = '';
    
    items = [
        {
            type: 'avatar',
            href: 'https://www.salesforce.com',
            label: 'Avatar Pill 1',
            src: 'https://www.lightningdesignsystem.com/assets/images/avatar1.jpg',
            fallbackIconName: 'standard:user',
            variant: 'circle',
            alternativeText: 'User avatar',
            isLink: true,
        },
        {
            type: 'avatar',
            href: '',
            label: 'Avatar Pill 2',
            src: 'https://www.lightningdesignsystem.com/assets/images/avatar2.jpg',
            fallbackIconName: 'standard:user',
            variant: 'circle',
            alternativeText: 'User avatar',
        },
        {
            type: 'avatar',
            href: 'https://www.google.com',
            label: 'Avatar Pill 3',
            src: 'https://www.lightningdesignsystem.com/assets/images/avatar3.jpg',
            fallbackIconName: 'standard:user',
            variant: 'circle',
            alternativeText: 'User avatar',
            isLink: true,
        },
    ];

     columns = [
        { label: 'Name', fieldName: 'Name' }
       
    ];

  
 
    // update searchValue var when input field value change
    searchKeyword(event) {
        this.searchValue = event.target.value;
        console.log('check ',event.target.value);
    }
 
    // call apex method on button click 
    handleSearchKeyword() {
        
        if (this.searchValue !== '') {
            getorgmaster({
                    searchKey: this.searchValue
                })
                .then(result => {
                    // set @track contacts variable with return contact list from server  
                    this.orgMasterRecord = result;
                    console.log('result--- ',result);
                })
                .catch(error => {
                   
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                    // reset contacts var with null   
                    this.orgMasterRecord = null;
                });

}
    }
}