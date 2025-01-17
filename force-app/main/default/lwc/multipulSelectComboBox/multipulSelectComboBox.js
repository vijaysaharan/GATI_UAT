import { LightningElement,track, api } from 'lwc';

export default class MultipulSelectComboBox extends LightningElement {
    @api width = 100;
    @api variant = '';
    @api label = 'Test Multiselect';
    @api name = '';
    @api dropdownLength = 5;
  
    @api options = [
        {label:'Label1',value:'Value1'},
        {label:'Label2',value:'Value2'},
        {label:'Label3',value:'Value3'},
        {label:'Label4',value:'Value4'},
        {label:'Label5',value:'Value5'},
        {label:'Label6',value:'Value6'},
        {label:'Label7',value:'Value7'},
      ];
    @api value = '';
    @track value_ = ''; 
    @track isOpen = false;
    @track options_ = [];
    @api selectedPills = []; 
  
    rendered = false;
    customStyle='';
  
    connectedCallback(){
       if(this.options != undefined)
        this.options_ = JSON.parse(JSON.stringify(this.options));
  
       if(this.value != undefined){
        this.value_ = JSON.parse(JSON.stringify(this.value));
       }
        
      //  if(this.value != undefined && this.options != undefined){
      //   this.parseValue(this.value_);
      //  } 
    }
  
    parseValue(value){
      if (!value || !this.options_ || this.options_.length < 1){
        return;
      }
      var values = value;
      var valueSet = new Set(values);
  
      this.options_ = this.options_.map(function(option) {
        if (valueSet.has(option.value)){
          option.selected = true;
        }
        return option;
      });
      this.selectedPills = this.getPillArray();
    }

    getPillArray(){
      var pills = [];
      this.options_.forEach(function(element) {
        var interator = 0;
        if (element.selected) {
          pills.push({label:element.label, name:element.value, key: interator++});
        }
      });
      return pills;
    }
  
    // parseOptions(options){
    //   if (options != undefined && Array.isArray(options)){
    //     this.options_ = JSON.parse(JSON.stringify(options)).map( (option,i) => {
    //       option.key = i;
    //       return option;
    //     });
    //   }
    // }
  
    get labelStyle() {
      return this.variant === 'label-hidden' ? ' slds-hide' : ' slds-form-element__label ' ;
    }
  
    get dropdownOuterStyle(){
      return 'slds-dropdown slds-dropdown_fluid slds-dropdown_length-5';
    }
  
    get mainDivClass(){
      var style = ' slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
      return this.isOpen ? ' slds-is-open ' + style : style;
    }
    get hintText(){
      const selectedCount = this.selectedPills.length;
    if (selectedCount === 0) {
      return "Select an option...";
    } else {
      return `${selectedCount} option${selectedCount > 1 ? 's' : ''} selected`;
    }
    }
  
    openDropdown(){
      var input = this.template.querySelector('lightning-icon');
      let rect = input.getBoundingClientRect();
      let x = rect.left;
      let y = rect.top;
      this.customStyle = `position: fixed;width: fit-content;top:${y+20}px;left:${x-100}px`
      this.isOpen = true;
    }
    closeDropdown(){
      this.isOpen = false;
    }
  
    handleClick(event){
      event.stopImmediatePropagation();
      this.openDropdown();
      window.addEventListener('click', this.handleClose);
    }

    // handleShowOption(event){
    //   event.stopImmediatePropagation();
    //   this.openDropdown();
    //   window.addEventListener('click',this.handleClose);
    // }

    handleClose = (event) => {
      event.stopPropagation();
      this.closeDropdown();
      window.removeEventListener('click', this.handleClose);
    }
  
    // handlePillRemove(event){
    //   event.preventDefault();
    //   event.stopPropagation();
  
    //   const name = event.detail.item.name;
  
    //   this.options_.forEach(function(element) {
    //     if (element.value === name) {
    //       element.selected = false;
    //     }
    //   });
    //   this.selectedPills = this.getPillArray();
    //   this.despatchChangeEvent();
  
    // }
  
    handleSelectedClick(event) {
      event.preventDefault();
      event.stopPropagation();
    
      const { value, selected, shift } = event.detail;
    
      if (shift) {
        this.options_ = this.options_.map(option => {
          if (option.value === value) {
            option.selected = selected;
          }
          return option;
        });
      } else {
        const selectedOption = this.options_.find(option => option.value === value);
        if (selectedOption) {
          selectedOption.selected = !selectedOption.selected;
        }
      }
    
      this.value_ = this.options_.filter(option => option.selected).map(option => option.value);
      this.selectedPills = this.getPillArray();
      this.despatchChangeEvent();
    }
    
    despatchChangeEvent() {
      let values =  this.selectedValues();
      let valueString = values.length > 0 ? values.join(";") : "";
      const eventDetail = {value:valueString};
      const changeEvent = new CustomEvent('change', { detail: eventDetail });
      this.dispatchEvent(changeEvent);
    }

    selectedValues(){
      var values = [];
      if (this.options_.length < 1){
        return this.value_;
      }
      this.options_.forEach(function(option) {
        if (option.selected === true) {
          values.push(option.value);
        }
      });
      return values;
    }
}