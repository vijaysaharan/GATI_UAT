import { LightningElement, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACTIVITY_OBJECT from '@salesforce/schema/Event';
import VISITED_FIELD from '@salesforce/schema/Event.Visited__c';
export default class EventLWC extends LightningElement {


    @wire(getObjectInfo, { objectApiName: ACTIVITY_OBJECT })
    activityInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$activityInfo.data.defaultRecordTypeId',
        fieldApiName: VISITED_FIELD
    })
    visitedValues;

    handleChange() {

    }

}