import { LightningElement,api,track } from 'lwc';
import getChildConfig from '@salesforce/apex/RelatedListController.getChildConfig';

export default class CallRelatedForChild extends LightningElement {
    @api childString;
    @track options;
    configList; 
    selectedChild;   
    @track showRelatedList = false;
    showCombo = false;
    @api recordId;
    allData;
    @track bigObjApiName; 
    @track listToShow; 
    @track relatedLookup; 
    @track idToPass;  
    @track indexOfB; 


    // connectedCallback(){
    //     getChildConfig({config : this.childString}).then(res=>{
    //         this.allData = JSON.parse(res);
    //         this.configList = JSON.parse(this.allData.configList);
    //         console.log(this.configList);
    //         this.options = this.configList.map(ele => {
    //             var obj = {
    //                 label : ele.Object_Name__c + '-->' + ele.Big_Object_Name__c,
    //                 value : ele.Big_Object_Name__c
    //             }
    //             return obj;
    //         })    
    //         this.showCombo = true;        
    //     })
    // }

    // getDataForReleatedList(selectedVal){
    //     var configobj = this.configList.filter(ele => ele.Big_Object_Name__c == selectedVal);
    //     this.showRelatedList = false;
    //     setTimeout(() => {
    //         this.bigObjApiName = configobj[0].Big_Object_Name__c;
    //         this.listToShow = configobj[0].Fields_To_Show__c;
    //         this.relatedLookup = configobj[0].Big_Object_Index__c.split(',')[0];
    //         this.idToPass = this.recordId;
    //         this.indexOfB = configobj[0].Big_Object_Index__c;
    //         this.showRelatedList = true;

    //     },100 );
        
    // }

    // handleChildSelectCombo(event){
    //     this.selectedChild = event.detail.value;
    //     this.getDataForReleatedList(this.selectedChild);
    // }

    connectedCallback(){
        getChildConfig({config : this.childString}).then(res=>{
            this.allData = JSON.parse(res);
            this.configList = JSON.parse(this.allData.configList);
            this.options = this.configList.map(ele => {
                var obj = {
                    label : ele.Object_Name__c + ' (' + ele.Big_Object_Name__c+')',
                    bigObjApiName : ele.Big_Object_Name__c,
                    listToShow : ele.Fields_To_Show__c,
                    relatedLookup : ele.Big_Object_Index__c.split(',')[0],
                    idToPass : this.recordId,
                    indexOfB : ele.Big_Object_Index__c,
                    showRelatedList : true
                }
                return obj;
            })    
            // this.showCombo = true;        
        })
    }
}