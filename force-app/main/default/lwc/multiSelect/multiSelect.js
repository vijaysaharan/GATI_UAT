import { LightningElement, api, track } from 'lwc';

export default class MultiSelect extends LightningElement {

  @api width = 100;
  @api variant = '';
  @api label = '';
  @api name = '';
  @api dropdownLength = 5;
  @api disableInput = false;
  @api customLeft = 350;
  @api placeholder = 'Select Option...';
  @api isSearch = false;
  @api searchLabel = 'label';

  @api options = [];
  @api value = '';
  @api selectedPills = [];
  @track value_ = '';
  @track isOpen = false;
  @track options_ = [];
  @track searchValue = '';



  TargetedLocations = 'Targeted Locations';
  rendered = false;
  customStyle='';

  @api refreseValues(){
    if(this.value != undefined)
      this.value_ = JSON.parse(JSON.stringify(this.value));

    if(this.value != undefined && this.options != undefined){
    this.parseValue(this.value_);
    } 
  }
  connectedCallback(){
     if(this.options != undefined){
      this.options_ = JSON.parse(JSON.stringify(this.options));
      this.selectedPills = this.getPillArray();
     }

     if(this.value != undefined)
      this.value_ = JSON.parse(JSON.stringify(this.value));

     if(this.value != undefined && this.options != undefined){
      this.parseValue(this.value_);
     } 
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
      }else{
        option.selected = false;
      }
      return option;
    });
    this.selectedPills = this.getPillArray();
  }

  parseOptions(options){
    if (options != undefined && Array.isArray(options)){
      this.options_ = JSON.parse(JSON.stringify(options)).map( (option,i) => {
        option.key = i;
        return option;
      });
    }
  }

  get disableStatus(){
    return this.label==this.TargetedLocations ? false : this.disableInput;
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
    console.log('values',values);
    return values;
  }



  get labelStyle() {
    switch (this.variant) {
      case 'label-hidden':
        return ' slds-hide';
      case 'for-pe':
        return ' slds-form-element__label multi-select-label-PE';
      default:
        return ' slds-form-element__label multi-select-label';
    }
  }

  get dropdownOuterStyle(){
    return 'slds-dropdown slds-dropdown_fluid slds-dropdown_length-5';
  }

  get mainDivClass(){
    var style = ' slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
    return this.isOpen ? ' slds-is-open ' + style : style;
  }

  get hintText(){
    let selectedCount = this.selectedPills.length;
    if (selectedCount === 0) {
      if(this.placeholder != ''){
         return this.placeholder;
      }else{
        return "Select an option...";
      }
    } else {
      return `${selectedCount} option${selectedCount > 1 ? 's' : ''} selected`;
    }
  }

  openDropdown(){
      let input = this.template.querySelector('lightning-icon');
      let rect = input.getBoundingClientRect();
      let x = rect.left;
      let y = rect.top;
      this.customStyle = `position: fixed;width: fit-content;top:${y+20}px;left:${x-this.customLeft}px`
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
  handleClose = (event) => {
    event.stopPropagation();
    this.closeDropdown();
    window.removeEventListener('click', this.handleClose);
  }

  handlePillRemove(event){
    event.preventDefault();
    event.stopPropagation();

    const name = event.detail.item.name;

    this.options_.forEach(function(element) {
      if (element.value === name) {
        element.selected = false;
      }
    });
    this.selectedPills = this.getPillArray();
    this.despatchChangeEvent();

  }

  handleSelectedClick(event) {
    event.preventDefault();
    event.stopPropagation();
    const { value, selected, shift } = event.detail;
    if (shift) {
        this.options_ = this.options_.map(option => {
          if(value == 'ALL'){
            option.selected = selected;
          }
          else if(option.value === value){
            option.selected = selected;
          }
          return option;
        });
    } else {
      const selectedOption = JSON.parse(JSON.stringify(this.options_.find(option => option.value === value)));
      if(value == 'ALL'){
        this.options_.forEach(ele => {
          ele.selected = !selectedOption.selected;
        });
      }
      else if(selectedOption){
        this.options_ = this.options_.map(option => {
          if(option.value === value){
            option.selected = !selectedOption.selected;
          }
          return option;
        });
      }
    }
    if(value != 'ALL' && selected == false){
      this.options_ = this.options_.map(ele => {
        if(ele.value == 'ALL'){
          ele.selected = selected;
        }
        return ele;
      });
    }
    else if(value != 'ALL' && selected == true && this.selectedPills.length == (this.options_.length - 2)){
      this.options_ = this.options_.map(ele => {
        if(ele.value == 'ALL'){
          ele.selected = selected;
        }
        return ele;
      });
    }
    this.value_ = this.options_.filter(option => option.selected).map(option => option.value);
    this.selectedPills = this.getPillArray();
    this.despatchChangeEvent();
  }


  despatchChangeEvent() {
    let values =  this.selectedValues();
    let valueString = values.length > 0 ? values.join(";") : "";
    var eventDetail = {value:valueString};
    const changeEvent = new CustomEvent('inputchange', { detail: eventDetail });
    this.dispatchEvent(changeEvent);
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

  searchData(event){
    var allData = [];
    this.options.forEach(ele => {
      if(ele.label !='All'){
        allData.push({label:ele.label,value:ele.value,selected:false});
      }
    });
    this.searchValue = event.detail.value;
    let filterData = allData.filter(ele => ele.label.toLowerCase().includes(this.searchValue.toLowerCase()));
    let selectedData = this.options_.filter(ele => ele.selected && ele.label != 'All');
    let uniqueFilterData = filterData.filter(item => !selectedData.find(elm => elm[this.searchLabel] == item[this.searchLabel]));
    let tempOptions = [{label:'All',value:'ALL',selected:false},...selectedData,...uniqueFilterData];
    this.options_ = JSON.parse(JSON.stringify(tempOptions));
    this.openDropdown();
  }
}