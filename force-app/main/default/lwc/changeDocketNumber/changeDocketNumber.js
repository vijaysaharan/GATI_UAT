import { LightningElement , api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateDocketNumber from '@salesforce/apex/DocketChangeController.updateDocketNumber';

export default class ChangeDocketNumber extends NavigationMixin(LightningElement) {
    @api recordId;

    docketNumber;
    isLoading = false;
    resultMessage = '';

    get isDisabled(){
        return !(this.docketNumber != null && this.docketNumber != '');
    }
    
    handleDocketChange(event){
        this.docketNumber = event.detail.value;
    }

    handleUpdate(){
        if(!this.isDisabled){
            this.isLoading = true;
            updateDocketNumber({docketNumber: this.docketNumber, caseId: this.recordId})
            .then((result) => {
                this.resultMessage = result;
                this.handleToast();               
            })
            .catch(error => {
                this.resultMessage = error?.body?.message ? error?.body?.message : 'Something went wrong, please contact to your admin.';
                this.handleToast();
            });
        }
    }

    handleToast(){
        if(this.resultMessage == 'Docket Number Changed.'){
            this.handleFinish('Docket Change',this.resultMessage,'success','sticky');
        }
        else{
            this.handleFinish('Docket Change',this.resultMessage,'error','sticky');
        }
    }

    handleFinish(title, msg, variant, mode){
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: mode
        }));
        this.navigateToCase();
    }

    navigateToCase(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });
    }
}