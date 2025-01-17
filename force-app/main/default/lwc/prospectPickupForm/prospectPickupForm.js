import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ProspectPickupForm extends NavigationMixin(LightningElement) {
    @track loadingval = false;
    @track objectApiName = 'Case';
    //for production
    //@api recordTypeID = '0129B0000004I0DQAU';
    //for sandbox
    @api recordTypeID = '012p0000000Ss6TAAS';
    subtype = null;
    	
    closeModalchild(){
		let ev = new CustomEvent('closemodalchild');
		this.dispatchEvent(ev);  		
	}

    handleSuccess(event){
        //this.accountId = event.detail.id;
        console.log(event.detail.id);
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
                recordId:event.detail.id,
				objectApiName: "Case",
				actionName: "view"
			}
		}); 
    // const inputFields = this.template.querySelectorAll('lightning-input-field');
    // if (inputFields) {
    //     inputFields.forEach((field) => {
	// 		console.log(field.fieldName);
    //         if (field.fieldName!='Type')
	// 		{field.reset();}
    //     });
    // }		
		this.closeModalchild();
    }

    handleError(event){
        this.loadingval = false;
    }

    handleSubmit(event) {
        this.loadingval = true;
		console.log('submit');
	}
}