import { LightningElement, api } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import LightningAlert from 'lightning/alert';
import { FlowNavigationNextEvent} from 'lightning/flowSupport';

export default class GatiMdmAdditionalApproval extends LightningElement {
    @api contractData;
    @api approvalResult;
    @api selectedContract;
    @api selectedOpportunityId;

    columns = [
        { label: 'Opportunity Id', fieldName: 'Name' , initialWidth: 200,},
        { label: 'Existing Customer Code', fieldName: 'Existing_Customer_Code__c' , initialWidth: 200,},
        { label: 'Existing Customer Contract', fieldName: 'Existing_Customer_Contract__c' , initialWidth: 200,},
        { label: 'Customer Pan Number', fieldName: 'Customer_Pan_Number__c' , initialWidth: 200,},
        { label: 'Customer Phone Number', fieldName: 'Customer_Phone_Number__c' , initialWidth: 200,},
        { label: 'Customer Email ID', fieldName: 'Customer_Email_ID__c' , initialWidth: 200,},
        { label: 'Customer Name', fieldName: 'Customer_Name__c' , initialWidth: 200,},
        { label: 'Customer Category', fieldName: 'Customer_Category__c' , initialWidth: 200,},
        { label: 'Customer OU Code', fieldName: 'Customer_OU_Code__c' , initialWidth: 200,},
    ];

    connectedCallback(){
        console.log(JSON.stringify(this.contractData,null,2));
    }

    async handleShowAlert(){
        var dataTable = this.refs.table;
        var selectedRows = dataTable.getSelectedRows();

        if (selectedRows.length > 0) {
            var result = await LightningConfirm.open({
                message: 'Are you sure to process with duplicate customer?',
                theme: 'info', // a red theme intended for error states
                label: 'Confirmation', // this is the header text
            });
    
            if (result) {
                this.handleButtonClick('Y');
            } else {
                this.handleButtonClick('N');
            }
        } else {

            await LightningAlert.open({
            message: "Please select at atleast one record.",
            theme: "warning", 
            label: "Warning",
            });
        }

    }

    async handleCancel(){
        var dataTable = this.refs.table;
        var selectedRows = dataTable.getSelectedRows();
        if (selectedRows.length > 0) {
            this.handleButtonClick('N');
        } else {
            await LightningAlert.open({
            message: "Please select at atleast one record.",
            theme: "warning", 
            label: "Warning",
            });
        }
    }

    handleButtonClick(approvalResult){
        var dataTable = this.refs.table;
        var selectedRows = dataTable.getSelectedRows();
        this.selectedContract = selectedRows[0].Existing_Customer_Code__c;
        this.selectedOpportunityId = selectedRows[0].Name;
        this.approvalResult = approvalResult;
        var nextScreenEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextScreenEvent);
    }
}