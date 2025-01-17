import LightningDatatable from 'lightning/datatable';
import customInput from './customInput.html';
import customCheckbox from './customCheckbox.html';
import customCombobox from './customCombobox.html';

export default class CustomDataTableType extends LightningDatatable {

    // connectedCallback() {
    //     const {
    //         handleResizeColumn,
    //         handleUpdateColumnSort,
    //         handleCellFocusByClick,
    //         handleFalseCellBlur
    //     } = this;
    //     this.template.addEventListener('selectallrows', handleSelectAllRows.bind(this));
    //     this.template.addEventListener('deselectallrows', handleDeselectAllRows.bind(this));
    //     this.template.addEventListener('selectrow', handleSelectRow.bind(this));
    //     this.template.addEventListener('deselectrow', handleDeselectRow.bind(this));
    //     this.addEventListener('rowselection', handleRowSelectionChange.bind(this));
    // }

    static customTypes = {
        inputColumn: {
            template: customInput,
            typeAttributes: ['inputValue','inputId','typeOfField','isdisable','indicator']
        },
        checkboxColumn: {
            template: customCheckbox,
            typeAttributes: ['inputValue','inputId']
        },
        comboboxColumn: {
            template: customCombobox,
            typeAttributes: ['inputValue','inputId','isdisable']
        }
    };
}