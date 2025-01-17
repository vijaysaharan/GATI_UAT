import createBigObject from '@salesforce/apex/CreateBigObjectController.createBigObject';
import getFields from '@salesforce/apex/CreateBigObjectController.getFields';
import listOfSobject from '@salesforce/apex/CreateBigObjectController.listOfSobject';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, track } from 'lwc';
//import createB2SMapping from '@salesforce/apex/CreateBigObjectController.createB2SMapping';

export default class CreateBigObject extends NavigationMixin(LightningElement) {
    
    allObjOptions  = [{
        label : '--NONE--',
        value : null
    }];
    @track searchedObjectList = [];
    searchedObjectValue = '';

    directionOption = [
        { label: 'Ascending', value: 'ASC' },
        { label: 'Descending', value: 'DESC' }
    ];

    @track dataToShow = [];
    @track allFieldData = [];
    prevDatatoShow = [];

    columns = [ {
        label : 'Field Label',
        fieldName : 'label'
    },
    {
        label : 'Field API Name',
        fieldName : 'value'
    },
    {
        label : 'Data Type',
        fieldName : 'fieldType'
    },
    {
        label : 'BigObject Label',
        fieldName : 'EnteredLabel',
        type : 'inputColumn',
        typeAttributes: {inputValue : { fieldName: 'EnteredLabel'}, inputId : { fieldName : 'value'}, typeOfField : { fieldName : 'EnteredLabelType'}, indicator : {fieldName : 'inputLableIndicator'} }
    },
    {
        label : 'Bigobject API Name',
        fieldName : 'bigObjectApiName'
    },
    {
        label : 'Index',
        fieldName : 'isSelectedForIndex',
        type : 'checkboxColumn',
        initialWidth : 80,
        cellAttributes: { alignment: 'center' },
        typeAttributes: {inputValue : { fieldName: 'isSelectedForIndex'}, inputId : { fieldName : 'value'} }
    },
    {
        label : 'Order',
        fieldName : 'orderValue',
        type : 'comboboxColumn',
        wrapText : true,
        typeAttributes: {inputValue : { fieldName: 'orderValue'}, inputId : { fieldName : 'value'}, isdisable :{ fieldName : 'isOrderDisable'}}
    },
    {
        label : 'Sequence',
        fieldName : 'indexSequence',
        type : 'inputColumn',
        typeAttributes: {inputValue : { fieldName: 'indexSequence'}, inputId : { fieldName : 'value'}, typeOfField : { fieldName : 'inputColumnType'}, isdisable : { fieldName : 'isSequenceDisable'}, indicator : {fieldName : 'inputSequenceIndicator'}}
    },
    {
        label : 'Index Length',
        fieldName : 'indexLength',
        type : 'inputColumn',
        typeAttributes: {inputValue : { fieldName: 'indexLength'}, inputId : { fieldName : 'value'}, typeOfField : { fieldName : 'inputColumnType'}, isdisable : { fieldName : 'isindexLengthDisable'}, indicator : {fieldName : 'inputLenghtindicator'} }
    },
    ];
    @track selectedFileds = [];

    @track selectedObject = null;

    fieldOptions = [];
    @track searchedFieldOption = [];
    searchedFieldValue = '';

    disableNext = true;
    isLoading = false;

    @track selectedFields = [];
    @track selectedFieldForIndex = [];
    showFieldList = false;
    firstPage = true;

    @track forObjString;
    finalPage = false;

    @track inputforFieldDirection = [];
    disableFinalNext = true;

    @track selectedForIndex = [];

    bigObjectName = '';
    disableCreateBigObj = true;

    
    connectedCallback(){
        this.getObjList();
    }

    getObjList(){
        this.isLoading = true;
        listOfSobject().then(res=>{
            this.allObjOptions =this.allObjOptions.concat(JSON.parse(res));
            this.searchedObjectList = this.allObjOptions;
            this.isLoading = false;
            //this.serachedObjList = this.allOptions;
        })
    }

    handleObjectSearch(event){
       this.searchedObjectValue = event.detail.value;
        if(event.detail.value != '' || event.detail.value != null){
            this.searchedObjectList = this.allObjOptions.filter(ele => {
                if(ele.label.toLowerCase().includes(event.detail.value.toLowerCase())){
                    return true;
                }else{
                    return false;
                }
            });
            this.searchedObjectList = [{
                label : '--NONE--',
                value : null
            }, ...this.searchedObjectList];
        }else{
            this.searchedObjectList = this.allObjOptions;
        }
    }

    handleObjectSelectionChange(event){
        this.showFieldList = false;
        this.isLoading = true;
        this.selectedObject = event.detail.value;
        this.selectedFields = [];
        this.getAllFields(event.detail.value);
    }
    
    getAllFields(selectedObject){
        getFields({objectApiName : selectedObject}).then(res=>{
            this.fieldOptions = JSON.parse(res);
            this.allFieldData = this.fieldOptions.map(ele => {
                ele['EnteredLabel'] = ele.label;
                ele['bigObjectApiName'] = ele.label.replaceAll(/([^a-zA-Z0-9]+)/ig ,'')+'__c';
                ele['isSelectedForIndex'] = false;
                ele['orderValue']  = 'DESC';
                ele['isOrderDisable']  = !ele.isSelectedForIndex ;
                ele['EnteredLabelType'] = 'Text';
                ele['indexLength'] = 0;
                ele['inputColumnType'] = 'number'
                ele['indexSequence'] = 0;
                ele['isSequenceDisable'] = !ele.isSelectedForIndex;
                ele['isindexLengthDisable'] = !ele.isSelectedForIndex;
                ele['inputLenghtindicator'] = 'len';
                ele['inputSequenceIndicator'] = 'seq';
                ele['inputLableIndicator'] = 'lab';
                return ele;
            });
            this.dataToShow = this.allFieldData;
            this.prevDatatoShow = this.dataToShow;
            this.selectedFileds = [];
            this.showFieldList = true;
            this.isLoading = false;
        })
    }

    getSelectedValue(event){
        this.showFieldList = false;
        this.selectedFileds = event.detail.selectedRows.map(ele => {return ele.value;});
        // var dataToShowList = this.dataToShow.map(ele => {return ele.value});
        // var removedeleData = this.dataToShow.filter(ele => !shownDataSelected.includes(ele.value));
        // var removedEle = removedeleData.map(ele => {return ele.value});
        // console.log('selected row',shownDataSelected);
        // console.log('removed list',removedEle);
        // this.selectedFileds = [...new Set(this.selectedFileds.concat(shownDataSelected))];
        // console.log(this.selectedFileds);
        // this.selectedFileds = this.selectedFileds.filter(ele => !(removedEle.includes(ele) && dataToShowList.includes(ele)));
        // console.log(this.selectedFileds);
        this.showFieldList = true;
    }

    handleFieldSearch(event){
        // this.showFieldList = false;
        // this.prevDatatoShow = this.dataToShow;
        // this.searchedFieldValue = event.detail.value;
        // console.log('this is search event', this.selectedFileds);
        // //var selectedField = this.selectedFields;
        // if(event.detail.value != '' || event.detail.value != null){
        //     this.dataToShow = this.allFieldData.filter(ele=>{
        //         if(ele.label.toLowerCase().includes(event.detail.value.toLowerCase())){
        //             return true;
        //         }else{
        //             return false;
        //         }
        //     });
        // //this.selectedFields = selectedField;
        // }else{
        //     this.dataToShow = this.allFieldData;
        //    // this.selectedFields = selectedField;
        // }
        // // var temp = this.selectedFileds;
        // // this.selectedFileds = [];
        // // this.selectedFileds = temp;
        // var temp = JSON.parse(JSON.stringify(this.selectedFields));
        // this.template.querySelector('c-custom-data-table-type').selectedRows = temp;
        // var sFields = this.template.querySelector('c-custom-data-table-type').selectedRows;
        // console.log(sFields);
        // this.showFieldList = true;
    }

    // handleselectAllField(){
    //     this.selectedFields = this.fieldOptions.map(ele =>{
    //         return ele.value;
    //     })
    //     this.disableNext = false;
    // }

    // handleFieldChange(event){
    //     console.log(event.detail.value);
    //     if(this.searchedFieldValue != ''){
    //         this.selectedFields = this.selectedFields.concat(event.detail.value);
    //     }else{
    //         this.selectedFields = event.detail.value;
    //     }
    //     if(this.selectedFields.length > 0){
    //         this.disableNext = false;
    //     }
    //     else{
    //         this.disableNext = true;
    //     }
    // }


    handleChangeInput(event){
        if(event.detail.indicator == 'lab' ){
            this.allFieldData = this.allFieldData.map(ele => {
                if(event.detail.unique == ele.value){
                    ele['EnteredLabel'] = event.detail.value;
                    ele['bigObjectApiName'] =ele.EnteredLabel.replaceAll(/([^a-zA-Z0-9]+)/ig ,'')+'__c';
                }
                return ele;
            });
        } else if(event.detail.indicator == 'seq'){
            this.allFieldData = this.allFieldData.map(ele => {
                if(event.detail.unique == ele.value){
                    ele['indexSequence'] = event.detail.value;
                    //ele['bigObjectApiName'] =ele.EnteredLabel.replaceAll(/([^a-zA-Z0-9]+)/ig ,'')+'__c';
                }
                return ele;
            });
        } else if(event.detail.indicator == 'len'){
            this.allFieldData = this.allFieldData.map(ele => {
                if(event.detail.unique == ele.value){
                    ele['indexLength'] = event.detail.value;
                    //ele['bigObjectApiName'] =ele.EnteredLabel.replaceAll(/([^a-zA-Z0-9]+)/ig ,'')+'__c';
                }
                return ele;
            });
        }
    }

    handleOrderChange(event){
        this.allFieldData = this.allFieldData.map(ele => {
            if(event.detail.unique == ele.value){
                ele['orderValue'] = event.detail.value;
            }
            return ele;
        });
    }



    handleChangeSelection(event){
        this.allFieldData = this.allFieldData.map(ele => {
            if(event.detail.unique == ele.value){
                if(this.selectedFileds.includes(ele.value)){
                    ele['isSelectedForIndex'] = event.detail.value;
                    ele['isOrderDisable']  = !ele.isSelectedForIndex ;
                    ele['isSequenceDisable'] = !ele.isSelectedForIndex;
                    ele['isindexLengthDisable'] = !ele.isSelectedForIndex;
                }
                else{
                    ele['isSelectedForIndex'] = false;
                }
            }
            return ele;
        });
    }

    // handleNextClick(){
    //     console.log(this.selectedFields);
    //     var selectedObj = this.allObjOptions.filter( ele => ele.value == this.selectedObject);
    //     this.forObjString = JSON.stringify({
    //         labelName : selectedObj[0].label,
    //         developerName : selectedObj[0].value 
    //     })
    //     var selected = this.selectedFields;
    //     this.selectedFieldForIndex = this.fieldOptions.filter(ele => selected.includes(ele.value));
    //     this.firstPage = false;
    // }

    // handleIndexChange(event){
    //     var selectedIndex  = event.detail.value;
    //     console.log(selectedIndex);
    //     this.selectedForIndex = selectedIndex;
    //     if(selectedIndex.length > 0){

    //         this.inputforFieldDirection = selectedIndex.map(ele => {
    //             var obj = this.selectedFieldForIndex.filter(elelist => elelist.value == ele);
    //             var objToReturn ={
    //                 labelName : obj[0].label,
    //                 apiName : obj[0].value,
    //                 sortDirection : 'ASC',
    //                 lengthOfField : 0,
    //                 indexed : true
    //             }
    //             return objToReturn;

    //         })

            
    //         this.inputforFieldDirection = this.inputforFieldDirection.concat(this.selectedFieldForIndex.filter(ele => {return !selectedIndex.includes(ele.value)}).map(ele =>{
    //             var obj ={
    //                 labelName : ele.label,
    //                 apiName : ele.value,
    //                 sortDirection : 'ASC',
    //                 lengthOfField : 0,
    //                 indexed : false
    //             }
    //             return obj;
    //         }));

    //         console.log(this.inputforFieldDirection);

    //         this.disableFinalNext = false;
    //     }else{
    //         this.disableFinalNext = true;
    //     }
    // }

    // handleFinalNextClick(){
    //     if( this.selectedForIndex.length > 0){
    //         this.finalPage = true;
    //     }
    // }

    // handleNextPrevious(){
    //     this.firstPage = true;
    //     this.finalPage = false;
    //     this.inputforFieldDirection = [];
    //     this.selectedForIndex = [];
    //     this.disableFinalNext = true;
    // }

    // handleTableInputChange(event){
    //     var tableInput = event.target.value;
    //     var forApi = event.currentTarget.dataset.id;
    //     this.inputforFieldDirection = this.inputforFieldDirection.map(ele =>{
    //         if(ele.apiName == forApi){
    //             ele.sortDirection = tableInput;
    //         }
    //         return ele;
    //     })
    // }

    // handleLengthInputChange(event){
    //     var tableInput = event.target.value;
    //     var forApi = event.currentTarget.dataset.id;
    //     this.inputforFieldDirection = this.inputforFieldDirection.map(ele =>{
    //         if(ele.apiName == forApi){
    //             ele.lengthOfField = tableInput;
    //         }
    //         return ele;
    //     })
    // }

    hangleBigNameChange(event){
        var bname = event.detail.value;
        this.bigObjectName = bname;
        if(bname == '' || bname == null){
            this.disableCreateBigObj = true;
        }else{
            this.disableCreateBigObj = false;
        }
    }

    compare_seq(a, b){
        // a should come before b in the sorted order
        if(a.indexSequence < b.indexSequence){
                return -1;
        // a should come after b in the sorted order
        }else if(a.indexSequence > b.indexSequence){
                return 1;
        // a and b are the same
        }else{
                return 0;
        }
    }

    handleCreate(){
        this.isLoading = true;
        this.disableCreateBigObj = true;
        //adding logic for tabel
        this.inputforFieldDirection = this.allFieldData.filter(ele => ele.isSelectedForIndex == true).sort(this.compare_seq).map(ele=>{
            var obj ={
                labelName : ele.label,
                apiName : ele.value,
                sortDirection : ele.orderValue,
                lengthOfField : ele.indexLength,
                indexed : ele.isSelectedForIndex,
                bigApiName : ele.bigObjectApiName,
                bigLableName : ele.EnteredLabel
            }
            return obj;
        })

        this.inputforFieldDirection = this.inputforFieldDirection.concat(this.allFieldData.filter(ele=> ele.isSelectedForIndex == false && this.selectedFileds.includes(ele.value)).map(ele=>{
            var obj ={
                labelName : ele.label,
                apiName : ele.value,
                sortDirection : ele.orderValue,
                lengthOfField : ele.indexLength,
                indexed : ele.isSelectedForIndex,
                bigApiName : ele.bigObjectApiName,
                bigLableName : ele.EnteredLabel
            }
            return obj;
        }));


        var selectedObj = this.allObjOptions.filter( ele => ele.value == this.selectedObject);
        this.forObjString = JSON.stringify({
            labelName : selectedObj[0].label,
            developerName : selectedObj[0].value 
        })

        var bigApiList = this.inputforFieldDirection.map(ele=>{
            return ele.bigApiName.toLowerCase();
        })
        const toFindDuplicates = bigApiList => bigApiList.filter((item, index) => bigApiList.indexOf(item) !== index)
        var duplicateElementa = toFindDuplicates(bigApiList);
        console.log(duplicateElementa);
       if(duplicateElementa.length >0){
            const event = new ShowToastEvent({
                title: 'Big Object Created',
                message:'There are some same API name please change label to correct :'+ duplicateElementa.join(","),
                variant : "error"
            });
            this.dispatchEvent(event);
            this.isLoading = false;
            this.disableCreateBigObj = false;  
       }else{
            createBigObject({fieldNameWithTypeJSON : JSON.stringify(this.inputforFieldDirection), forObject : this.forObjString, bigObjectName : this.bigObjectName}).then(res=>{
                var obj = JSON.parse(res);
                if(obj.idOfConfig != undefined){
                    const event = new ShowToastEvent({
                        title: 'Big Object Created',
                        message:'The Big Object is created by the name '+this.bigObjectName,
                        variant : "success"
                    });
                    this.dispatchEvent(event);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: obj.idOfConfig,
                            objectApiName: 'Backup_Configuration__c', // objectApiName is optional
                            actionName: 'view'
                        }
                    });   
                    this.isLoading = false;
                    this.disableCreateBigObj = false;        
                }
            }).catch(err=>{
                console.log(err);
                const event = new ShowToastEvent({
                    title: 'Error!',
                    message:'Failed to create big object with error '+err.message,
                    variant : "error"
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                this.disableCreateBigObj = false;
            })
       }
        // this is going to reconsider
        
    }

}