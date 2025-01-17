import { LightningElement, api, track, wire } from 'lwc';
import CASE_Object from '@salesforce/schema/Case';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class RecordViewFormStaticContact extends LightningElement {
    // Expose a field to make it available in the template

    bShowModal = false;
    fields = ['OwnerId',
        'CaseNumber',
        'Type',
        'Customer_Name__c',
        'Mobile__c',
        'Customer_Email__c',
        'Product__c',
        'Cargo_Purpose__c',
        'Pick_Up_Pincode__c',
        'Pick_Up_Pincode__r.Location__c',
        'Delivery_Pincode_Location__c',
        'Warehouse_Delivery__c',
        'Actual_Weight__c',
        'No_Of_Packages__c',
        'Unit_of_Measurement__c',
        'Volume__c',
        'Decl_Cargo_value__c',
        'Risk_Coverage_Prospect__c',
        'Value__c',
        'COD__c',
        'COD_Amt__c',
        'Pickup_Date__c',
        'Booking_Basis__c',
        'Description'
    ];


    // Flexipage provides recordId and objectApiName
    @api recordId;
    @api objectApiName;
    @track caseMeta = CASE_Object;
    @api recordTypeId;
    @api getRates;
    /* convertPickUp(){
         //alert(this.caseMeta.get(recordTypeInfos));
         this.fields.recordTypeId = this.recordTypeId;
         this.template.querySelector('lightning-record-form').submit(this.fields);
     }*/
    @wire(getObjectInfo, { objectApiName: 'Case' })
    getinfos(val) {
        if (val.data) {
            console.log(Object.values(val.data.recordTypeInfos));
            //rtis =val.data.recordTypeInfos;
            for (let i = 0; i < Object.values(val.data.recordTypeInfos).length; i++) {
                if (Object.values(val.data.recordTypeInfos)[i].name == "Pick Up") {
                    this.recordTypeId = Object.values(val.data.recordTypeInfos)[i].recordTypeId;
                    console.log(this.recordTypeId)
                    break;
                }
            }

        }
        if (val.error) {
            console.log(error);
        }
    }

    getRatesfromGems() {
        this.getRates = true;
    }

    showtoast(event) {
        console.log(event.detail);
        const evt = new ShowToastEvent({
            title: 'Sync Error',
            message: event.detail,
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.getRates = false;
    }

    // JS function to open modal window by setting property as true
    openModal() {
        this.bShowModal = true;
        console.log(this.recordId + ' trtsrt ' + this.recordTypeId);
    }

    // JS function to close modal window by setting property as false 
    closeModal() {
        this.bShowModal = false;
    }
}