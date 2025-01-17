import { LightningElement,api} from 'lwc';

export default class CheckBoxColumn extends LightningElement {
    @api inputValue = false;
    @api unique = '';

    handleInputOnChange(event){
        this.inputValue = event.detail.checked;
        const ev = new CustomEvent('checkboxchange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {value:this.inputValue, unique: this.unique}
        });
        this.dispatchEvent(ev);
    }
}