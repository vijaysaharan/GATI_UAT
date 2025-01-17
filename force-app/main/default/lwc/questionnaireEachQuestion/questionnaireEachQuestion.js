import { LightningElement,track,api } from 'lwc';
import getPicklistOptions from '@salesforce/apex/QuestionnaireController.getPicklistOptions';

export default class QuestionnaireEachQuestion extends LightningElement {
    @api lastname;
    @api phonenumber;
    @api emailaddress;
    @api consigneename;

    @track optionList;
    @track radioName;
    @track isOtherSelected = false;
    @track othersValue = '';
    @track isLead = false; 
    
    isRadioButton=false;
    // isEmoji=false;
    // isNumber=false;
    isCheckbox=false;

    @api questionList;
    @track selectedInput = {
        Name : '',
        Sequence__c : null,
        Question__c : null,
        Answer__c : null,
        ConsigneeFeedback__c : null,
        Lead__c : null 
    }
    @track leadList = {
        LastName : '',
        Street : '',
        Turnover_of_the_Company__c : null,
        Monthly_Spent_on_express_Logistic__c : 'Less Than and Equal To 5 Lakh',
        Customer_Potential__c : '1',
        MobilePhone : null,
        Email : null,
        Company : null,
        FirstName : '',
        Country : null,
        PostalCode : null,
        State	: null,
        City : null,
        LeadSource : 'Consignee Marketting',
        sobjectType : 'Lead'
    }

    @track potentialPerMonthList ;

        connectedCallback(){
            getPicklistOptions({objectName : 'Lead', fieldName : 'Monthly_Spent_on_express_Logistic__c'})
            .then(data=>{
                this.potentialPerMonthList = data.map(ele=>{
                    return {label : ele , value : ele}
                });
            })
            .catch(err=>{
                console.log('Error'+JSON.stringify(err));
            })
            this.radioName = 'optionName'+ this.questionList.Sequence__c;
            this.isRadioButton = this.questionList.OptionsType__c == 'Radio Button';
            //this.isEmoji = this.questionList.OptionsType__c == 'Emoji';
            //this.isNumber = this.questionList.OptionsType__c == 'Number';
            this.isCheckbox = this.questionList.OptionsType__c == 'Checkbox';
            if(this.questionList.Options__c != null)
                this.optionList = this.questionList.Options__c.split('@');

            this.selectedInput.Sequence__c = this.questionList.Sequence__c;
            this.selectedInput.Name = this.questionList.Name;
            this.selectedInput.Question__c = this.questionList.Question__c;
            
        }

        get optionClass(){
            let size = 12/this.questionList.RowLength__c;
            return 'slds-col slds-size_'+size+'-of-12';
        }

        handleOptionChangeChechbox(event) {
            const selectedCheckboxes = this.template.querySelectorAll(
                'input[type="checkbox"]:checked'
            );
        
            let selectedOptions = [];
            selectedCheckboxes.forEach((checkbox) => {
                selectedOptions.push(checkbox.value);
                if(checkbox.value == 'Others'){
                    this.isOtherSelected = true;
                }
                else{
                    this.isOtherSelected = false;
                }
            });
        
            this.selectedInput.Answer__c = selectedOptions.join(';');
            const Sendevent = new CustomEvent('inputchange', {
                detail: {
                    Id: this.questionList.Id,
                    selectedInput: this.selectedInput
                }
            });
            this.dispatchEvent(Sendevent);
        }

        handleOptionChangeRadio(event) {
            const selectedOption = event.target.value;
            this.selectedInput = {
                ...this.selectedInput,
                Answer__c: selectedOption
            };

            
            if(this.questionList.Create_Lead__c == true && selectedOption == this.questionList.Lead_Criteria__c ){
                this.isLead = true;
                this.leadList.LastName = this.lastname;
                this.leadList.MobilePhone = this.phonenumber;
                this.leadList.Email = this.emailaddress;
                this.leadList.Company = this.consigneename;
            }
            else{
                this.isLead = false;
            }

            if(this.questionList.Create_Lead__c == true && this.questionList.Lead_Criteria__c != selectedOption ){
                const Sendevent = new CustomEvent('leadchange', {
                    detail: {
                        queNumber : this.questionList.Name,
                        isCreate : this.isLead,
                        leadData : this.leadList
                    }
                });
                this.dispatchEvent(Sendevent);
            }

            const Sendevent = new CustomEvent('inputchange', {
                detail: {
                    Id: this.questionList.Id,
                    selectedInput: this.selectedInput
                }
            });
            this.dispatchEvent(Sendevent);
        }

        handleOthers(event){
            this.othersValue = event.target.value;
            const Sendevent = new CustomEvent('otherchange', {
                detail: {
                    Id: this.questionList.Id,
                    selectedInput: this.othersValue
                }
            });
            this.dispatchEvent(Sendevent);
        }

        handleleadInput(event){
            const { name, value } = event.target;
            this.leadList[name] = value;
            console.log('lead-------------',this.leadList.LastName)
            const Sendevent = new CustomEvent('leadchange', {
                detail: {
                    queNumber : this.questionList.Name,
                    isCreate : this.isLead,
                    leadData : this.leadList
                }
            });
            this.dispatchEvent(Sendevent);
        }

        @api validateChildInputs() {
            var returnVariable = true;
            if(this.isRadioButton){
                var radioList = this.template.querySelectorAll('input[type="radio"]');
                var radioGroupNames = [];

                for (let index = 0; index < radioList.length; index++) {
                const radio = radioList[index];
                const radioGroupName = radio.name;
                if (!radioGroupNames.includes(radioGroupName)) {
                    var validateRadioGroup = this.template.querySelector(
                    'input[type="radio"][name="' + radioGroupName + '"]:checked'
                    );
                        if (!validateRadioGroup) {
                        returnVariable = false;
                        }
                    radioGroupNames.push(radioGroupName);
                }
                }
                if(this.questionList.Create_Lead__c == true){
                    var inputList = this.template.querySelectorAll('lightning-input');
                    for (let index = 0; index < inputList.length; index++) {
                    const element = inputList[index];
                    var validateElement = element.reportValidity();
                        if (!validateElement) {
                            returnVariable = false;
                        }
                    }
                    var comboList = this.template.querySelectorAll('lightning-combobox');
                    for (let index = 0; index < comboList.length; index++) {
                    const element = comboList[index];
                    var validateElement = element.reportValidity();
                        if (!validateElement) {
                            returnVariable = false;
                        }
                    }
                }
            }
            if(this.isCheckbox){
                var checkboxList = this.template.querySelectorAll('input[type="checkbox"]');
                for (let index = 0; index < checkboxList.length; index++) {
                const checkbox = checkboxList[index];
                var validateCheckbox = checkbox.reportValidity();
                    if (!validateCheckbox) {
                        returnVariable = false;
                    }
                }
                if(this.isOtherSelected){
                    var inputList = this.template.querySelectorAll('lightning-input');
                    for (let index = 0; index < inputList.length; index++) {
                    const element = inputList[index];
                    var validateElement = element.reportValidity();
                        if (!validateElement) {
                            returnVariable = false;
                        }
                    }
                }
            }
            return returnVariable;
          }
}