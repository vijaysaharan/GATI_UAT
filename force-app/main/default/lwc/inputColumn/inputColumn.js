import { LightningElement,api } from 'lwc';

export default class InputColumn extends LightningElement {
    @api inputValue = '';
    @api unique = '';
    @api typeOfField = 'Text';
    @api isdisable = false;
    @api indicator = '';

    handleInputOnChange(event){
        this.inputValue = event.detail.value;
        const ev = new CustomEvent('inputchange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {value:this.inputValue, unique: this.unique, indicator : this.indicator}
        });
        this.dispatchEvent(ev);
    }
}