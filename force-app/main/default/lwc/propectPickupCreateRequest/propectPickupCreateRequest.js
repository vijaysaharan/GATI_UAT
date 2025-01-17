import { LightningElement , api,wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';


export default class PropectPickupCreateRequest extends NavigationMixin(LightningElement)  {
    @api defValue ='Prospect Pickup';
	loadingval = false;
	@api recordTypeId;
	isReadOnly = false; 
	isDisable = false;
	
    handleSuccess(event){
        //this.accountId = event.detail.id;
        console.log(event.detail.id);
		this.loadingval = false;
		debugger;
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
                recordId:event.detail.id,
				objectApiName: "Case",
				actionName: "view"
			}
		}); 
    const inputFields = this.template.querySelectorAll('lightning-input-field');
    if (inputFields) {
        inputFields.forEach((field) => {
			console.log(field.fieldName);
            if (field.fieldName!='Type')
			{field.reset();}
        });
    }		
		this.closeModalchild();
    }

	handleSubmit(event) {
		event.preventDefault();
		this.loadingval = true;
	}
	
	closeModalchild(){
		let ev = new CustomEvent('closemodalchild');
		this.dispatchEvent(ev);  		
	}

	handlechange(event) {
		if(event.target.value == "COD/DOD" || event.target.value == "--None--" )
		{
			this.isReadOnly = false;
			this.isDisable = false;
		}
		else
		{
			this.isReadOnly = true;
			this.isDisable = true;
			const inputFields = this.template.querySelectorAll('lightning-input-field');
    		if (inputFields) {
        	inputFields.forEach((field) => {
			console.log(field.fieldName);
            if (field.fieldName=='COD_Amt__c' || field.fieldName=='COD__c')
			{field.reset();}
			});
    		}		
		}
	}
}