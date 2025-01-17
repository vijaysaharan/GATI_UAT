import { LightningElement,api } from 'lwc';

export default class ComboboxColumn extends LightningElement {
    @api inputValue = '';
    @api unique = '';
    @api isdisable = false;
    options = [
        { label: 'Ascending', value: 'ASC' },
        { label: 'Descending', value: 'DESC' }
    ]

    handleInputOnChange(event){
        this.inputValue = event.detail.value;
        const ev = new CustomEvent('combochange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {value:this.inputValue, unique: this.unique}
        });
        this.dispatchEvent(ev);
    }
}