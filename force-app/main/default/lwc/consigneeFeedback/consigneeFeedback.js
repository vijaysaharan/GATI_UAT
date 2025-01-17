import { LightningElement, track, api, wire } from 'lwc';
import getQuestions from '@salesforce/apex/QuestionnaireController.getQuestions';
import insertConsigneeFeedback from '@salesforce/apex/QuestionnaireController.insertConsigneeFeedback';
import insertConsigneeQuestionnaire from '@salesforce/apex/QuestionnaireController.insertConsigneeQuestionnaire';
import insertLeadFromConsignee from '@salesforce/apex/QuestionnaireController.insertLeadFromConsignee';
import getPicklistOptions from '@salesforce/apex/QuestionnaireController.getPicklistOptions';
import getAllStaffCode from '@salesforce/apex/QuestionnaireController.getAllStaffCode';
//import DOCUMENT_ID  from '@salesforce/label/c.documentId';
import GATI_LOGO from '@salesforce/resourceUrl/GatiLogo';

export default class ConsigneeFeedback extends LightningElement {
  @track thankYouMessage = false;
  @track ErrorMessage = false;
  @track errorDetail;
  @track showStaff = false;
  @track loaded = true; 
  @track isDesktop = false;
  @track StaffCodeList = [];
  logoUrl =GATI_LOGO;
  /*@api documentId = DOCUMENT_ID; 
    get logoUrl() {
        return `/servlet/servlet.FileDownload?file=${this.documentId}`;
    }*/

    questions;
    formattedDate;
    @track selectedInputs = [];
    @track othersValues = [];
    @track leadList = [];
    @track ConsigneeFeedbackList = {
        ConsigneeName__c : '',
        Date__c : null,
        ContactPerson__c : '',
        MobilePhone__c : '',
        Strength__c	 : '',
        Comments__c : '',
        Email__c:null,
        Gati_Staff_or_Consignee__c : 'Consignee',
        Staff_Code__c : null,
        sobjectType : 'ConsigneeFeedback__c'
    }

    @track feedbackPicklist;

    connectedCallback(){
        getPicklistOptions({objectName : 'ConsigneeFeedback__c', fieldName : 'Gati_Staff_or_Consignee__c'})
        .then(data=>{
            this.feedbackPicklist = data.map(option => {
                return { label: option, value: option };
            });
        }).catch(err=>{
        })
        getQuestions().then(ele=>{
            this.questions = ele;
        });
        const today = new Date();
        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');
        this.formattedDate = `${year}-${month}-${day}`;
        this.ConsigneeFeedbackList.Date__c = this.formattedDate;
    }

    handleInput(event){
        const { name, value } = event.target;
        this.ConsigneeFeedbackList[name] = value;
        if(name == 'Gati_Staff_or_Consignee__c' && value == 'Gati Staff'){
            this.showStaff = true;
        }
        if(name == 'Gati_Staff_or_Consignee__c' && value == 'Consignee'){
            this.showStaff = false;
            this.ConsigneeFeedbackList.Staff_Code__c = null;
        }
    }

    handleInputChange(event) {
        const { Id, selectedInput } = event.detail;

        const existingInputIndex = this.selectedInputs.findIndex(
            (input) => input.Id === Id
        );

        if (existingInputIndex !== -1) {
            this.selectedInputs[existingInputIndex].Answer__c = selectedInput.Answer__c;
        } else {
            this.selectedInputs.push({
                Id,
                ...selectedInput
            });
        }

    }

    handleOthersChange(event){
        const {Id, selectedInput} = event.detail;

        const existingInputIndex = this.othersValues.findIndex(
            (input) => input.Id === Id
        );

        if (existingInputIndex !== -1) {
            this.othersValues[existingInputIndex].othersValue = selectedInput;
        } else {
            this.othersValues.push({
                Id,
                othersValue : selectedInput
            });
        }

    }

    getOthersValue(id) {
        const othersRecord = this.othersValues.find((others) => others.Id === id);
        return othersRecord ? othersRecord.othersValue : null;
    }

    handleleadchange(event){
        const {queNumber,isCreate,leadData} = event.detail;

        const existingInputIndex = this.leadList.findIndex(
            (input) => input.queNumber === queNumber
        );

        if (existingInputIndex !== -1) {
            this.leadList[existingInputIndex].leadData = leadData;
            this.leadList[existingInputIndex].isCreate = isCreate;
        } else {
            this.leadList.push({
                queNumber: queNumber,
                isCreate : isCreate,
                leadData : leadData
            });
        }

    }

    handleSave(){
        this.loaded = false;
        this.selectedInputs.forEach((question) => {
            const othersValue = this.getOthersValue(question.Id);
            if (othersValue) {
                question.Answer__c = question.Answer__c.replace('Others', othersValue);
            }
        });
        if(this.validateAllInputs() && this.eachQuestionValidation()){
            if(this.selectedInputs.length == (this.questions.length-1) && this.checkEachForAnswers()){
                if(this.ConsigneeFeedbackList.Gati_Staff_or_Consignee__c != 'Consignee'){
                    console.log('Inside IF',this.ConsigneeFeedbackList.Staff_Code__c)
                    getAllStaffCode({staffCode : this.ConsigneeFeedbackList.Staff_Code__c}).then(code=>{
                        console.log('Code',code);
                        if(code){
                            this.saveAllRecords();
                        }
                        else{
                            this.loaded = true;
                            this.errorDetail = 'Please enter a valid Staff Code.';
                            this.ErrorMessage = true;
                        }
                    }).catch(e=>{
                        this.loaded = true;
                        this.errorDetail = e.body.message;
                        this.ErrorMessage = true;
                    })
                }
                else{
                    this.saveAllRecords();
                }
            }
            else{
                this.loaded = true;
                this.errorDetail = 'Please answer to all questions';
                this.ErrorMessage = true;
            }
        }
        else{
            this.loaded = true;
            this.errorDetail = 'Your data is not correct.';
            this.ErrorMessage = true;
        }
    }

    saveAllRecords(){
        let insertLeadList = this.leadList.filter(ele => ele.isCreate).map(ele => {
            delete ele.isCreate;
            return ele;
        });
        let leadMap = insertLeadList.reduce((obj, ele) => {
            obj[ele.queNumber] = ele.leadData;
            return obj;
        }, {});
        console.log('jsdafjgsda'+JSON.stringify(leadMap));
        if(Object.keys(leadMap).length > 0){
            insertLeadFromConsignee({lstToInsert : leadMap}).then(mapOfIdsToLead=>{
                this.insertRecordwithoutLead(mapOfIdsToLead);
            })
            .catch(err=>{
                this.loaded = true;
                this.errorDetail = err.body.message;
                this.ErrorMessage = true;
            })
        }
        else{
            this.insertRecordwithoutLead(null);
        }
    }

    insertRecordwithoutLead(mapOfIdsToLead){
        insertConsigneeFeedback({lstToInsert : this.ConsigneeFeedbackList}).then(res=>{
            if(res != ''){
                let consigneeQuestionnaireLead = JSON.parse(JSON.stringify(this.selectedInputs)).map(ele => {
                    ele.sobjectType = 'ConsigneeQuestionnaire__c';
                    ele.ConsigneeFeedback__c = res;
                    if ( mapOfIdsToLead != null && mapOfIdsToLead.hasOwnProperty(ele.Name)) {
                        ele.Lead__c = mapOfIdsToLead[ele.Name].Id;
                    }
                    delete ele.Id;
                    return ele;
                });
                console.log('questionnasdfds'+JSON.stringify(consigneeQuestionnaireLead));
                insertConsigneeQuestionnaire({lstToInsert : consigneeQuestionnaireLead.map(el=>{delete el.Id; return el})})
                        .then(ele=>{
                            this.loaded = true;
                            if(ele){
                                this.thankYouMessage = true;
                            }
                            else{
                                this.errorDetail = 'No data or invalid data for Consignee Questions';
                                this.ErrorMessage = true;
                            }
                        })
                        .catch(err=>{
                            this.loaded = true;
                            this.errorDetail = err.body.message;
                            this.ErrorMessage = true;
                        });
            }
        }).catch(err=>{
            this.loaded = true;
            this.errorDetail = err.body.message;
            this.ErrorMessage = true;
        });
    }

    eachQuestionValidation(){
        var isEachValid = true;
        const childComponent = this.template.querySelectorAll('c-questionnaire-each-question');
        for (let index = 0; index < childComponent.length; index++) {
            const ele = childComponent[index];
            var validateCheckbox = ele.validateChildInputs();
                if (!validateCheckbox) {
                    isEachValid = false;
                }
            }
        return isEachValid;
    }

    checkEachForAnswers(){
        let isValidAll = true;
        for(let i= 0; i<this.selectedInputs.length;i++){
            const element = this.selectedInputs[i];
            console.log('Answer==>'+element.Answer__c);
            if(element.Answer__c == null || element.Answer__c == ''){
                isValidAll = false;
                break;
            }
        }
        return isValidAll;
    }

    handleClose(){
        this.thankYouMessage = false;
        location.reload();
    }

    handleErrorClose(){
        this.ErrorMessage = false;
    }

    validateAllInputs() {
        var returnVariable = true;
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
        return returnVariable;
      }
}