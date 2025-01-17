import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'
import CASE_OBJECT from '@salesforce/schema/Case';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { decodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import loading from "@salesforce/resourceUrl/loading";
import completed from "@salesforce/resourceUrl/completed";
import docketValidation from '@salesforce/apex/caseComponent.docketValidation';

export default class CaseComponent extends NavigationMixin(LightningElement) {
	loadingicon = loading;
	loadingval = false;
	docketValid = false;
	@track casePage = true;
	totalres;
	completedicon = completed;
	checkvalidation = true;
	docketlength = true;
	invaliddocket = false;
	checkvalidation = true;
	docketcheckcompleted = false;
	docketresponse;
	caserecordtypes;
	activeSections = ["basic", "service"];
	@track recordtypes;
	@track type;
	@track subtype;
	@api recordTypeId;
	@track docket;
	type;
	subtype;

	@wire(getObjectInfo,{objectApiName:'Case'})
	getinfos(val)
	{
		if(val.data)
		{
			console.log(Object.keys(val.data.recordTypeInfos));
			const rtis =val.data.recordTypeInfos;
			this.caserecordtypes=rtis;
			if ( rtis[this.recordTypeId].name == "Pick Up" || rtis[this.recordTypeId].name == "Email Case" ) {
				this.navigateToNewCasDefaults();
			}

		}
		if(val.error)
		{
			console.log(error);
		}
	}

	closeModal(){
        this.casePage = true;
      }   
	onCancel() {
		//  window.history.back();

		// Navigate to the case object's Recent list view.
		//this.closeModal();
		//this.closeTab();


		this[NavigationMixin.Navigate]({
			type: "standard__objectPage",
			attributes: {
				objectApiName: "Case",
				actionName: "list"
			},
			state: {
				filterName: "Recent"
			}
		});
	}
	assigndocket(event) {
		this.docket = event.target.value;

		console.log(this.docket.length);
		if (this.docket.length > 5) {
			this.docketlength = false;
		}
	}

	handleSubmit(event) {
		event.preventDefault();
		debugger;
		console.log('submit was clicked');
		console.log('submit was clicked 2'+this.type+this.subtype);
		let val = this.template.querySelector(".docketno");
		if ((this.docket == undefined || this.docket == null)&& val) {
			console.log(this.docket +' '+ val)
			val.setCustomValidity("Please Enter Value");
			val.reportValidity();
			console.log("before return docketempty"+this.type+this.subtype);
			return;
		}
		//val.setCustomValidity("");
		if (this.DocketValidate) {
			this.invaliddocket = false;
			this.docketValid = false;
			this.loadingval = true;
			this.docketlength = true;
			if(!this.docketValid)
			{
			this.validateDocket(this.docket);
			}
			else{
				console.log("here");
				this.navigateToNewCasDefaults(true);
			}
			console.log("after DocketValidate"+this.type+this.subtype);
		}else if(this.type == "Prospect Pickup")
		{	
			this.casePage = false;
			//this.navigateToNewCaseProspectpick();
		}
		else{console.log("before else navigateToNewCasDefaults"+this.type+this.subtype);
			this.navigateToNewCasDefaults();
			console.log("after else navigateToNewCasDefaults"+this.type+this.subtype);
		}
		
	}
	handlechange(event) {
		console.log(`event is called for ${event.target.name} and value is ${event.target.value}`);
		if (event.target.name == "Type") {
			this.type = event.target.value;
		}
		if (event.target.name == "Sub_Type__c") {
			this.subtype = event.target.value;
		}
	}
	closeTab(){
		let ev = new CustomEvent('closeclicked');
		this.dispatchEvent(ev); 
	}
	validateDocket(docketNumber) {
		docketValidation({ docketNo: docketNumber })
			.then((data) => {
				console.log(data)	;
				if (data.result == "successful") {
					this.loadingval = false;
					this.totalres=data;
					if(data.response.length<1)
					{
						this.invaliddocket = true;
						let val = this.template.querySelector(".docketno");
						val.setCustomValidity("No response received from GEMS system. Please try again.");
						val.reportValidity();						
					}
					let docres = data.response[0];
					this.docketresponse = docres;
					console.log(this.docketresponse)
					if (docres.sErrMsg == "Invalid Docket No" || docres.sErrMsg.length > 1) {
						this.invaliddocket = true;
						let val = this.template.querySelector(".docketno");
						val.setCustomValidity("Docket Number was not Found in Gems");
						val.reportValidity();
					} else {
						let val = this.template.querySelector(".docketno");
						val.setCustomValidity("");
						val.readonly = true;
						this.docketValid = true;
						this.navigateToNewCasDefaults(true);
					}
				} else {
					alert(JSON.stringify(data));
					return;
				}
			})
			.catch((err) => {
				console.log(err);
				const event = new ShowToastEvent({
					title: "Failed",
					message: err.body.message,
					variant: "error",
					mode: "sticky"
				});
				this.dispatchEvent(event);
				this.loadingval = false;
			});
	}
	checkError(event)
	{

	}
	get DocketValidate() {
		if ( this.recordTypeId.name != "Pick Up" && this.type!="ADD Extension" && this.type!="Bill back of Expenses" && this.type!="Appointment Delivery" && this.type!="Exception" && this.type!="UCG Confirmation" && this.type != "Pending Pickup" && this.type != "Prospect Pickup") {   //this.type!="Pick Up" && 
			return true;
		}
		return false;
	}
	handlerecordid(event) {
		let recid = event.target.value;
		console.log(recid);
		this.recordTypeId = recid;

		// this.template.querySelector('lightning-record-edit-form').re
	}
	// navigateToNewCaseProspectpick(){
	// 	this[NavigationMixin.Navigate]({
	// 		type: "standard__component",

	// 		attributes: {
	// 			componentName: "c__ProspectPickupCreation"
	// 		},
	// 		state: {
	// 			c__counter: '7'
	// 		}
	// 	});

	// }
	navigateToNewCasDefaults(includedefault=false) {
	
		let defaultValues;
		if(includedefault)
		{   console.log('insideincludedefault'+this.type+this.subtype);
			let respo=this.docketresponse.result[0];

			let delstn=respo.DELIVERY_STN;
			let booking= respo.BOOKING_STN;
			let accId = respo.CUSTOMER_CODE;
			let defaultArray = {
								Docket_Number__c: this.docket,
								Type: this.type,
								Consignee_Mobile_No__c: respo.CONSIGNEE_MOBILE_NO,
								//Stock_OU__c: (respo.STOCK_OU!= null && respo.STOCK_OU !='')?totalres[respo.STOCK_OU]:"",
								Consignee_PinCode__c: respo.CONSIGNEE_PINCODE,
								Risk_Coverage__c: respo.DOCKET_TYPE,
								COD_Type__c: this.docketresponse.COD_TYPE,
								Decl_Cargo_value__c: respo.DECL_CARGO_VAL,
								Consignor_Name__c: respo.CONSIGNOR_NAME,
								Booking_OU__c: this.totalres[booking],
								AccountId: this.totalres[accId],
								Docket_Status__c: respo.DOCKET_STATUS,
								No_of_Packages_Delivered__c:respo.NO_OF_PKGS_DELIVERED,
								//Contract_No__c: respo.CONTRACT_NO,
								Assured_Delivery_Date__c: respo.ASSURED_DLY_DT,
								Consignor_Mobile_No__c: respo.CONSIGNOR_MOBILE_NO,
								Actual_Weight_Booked__c: respo.ACTUAL_WT,
								Booking_Date__c: respo.BKG_DT,
								POD_Type__c:respo.COD_TYPE,
								COD_Type__c:respo.POD_TYPE,
								//Customer_Code__c: respo.CUSTOMER_CODE,
								Delivery_OU__c: this.totalres[delstn],
								//AccountId: this.totalres[accId],
								Consignor_Pincode__c: respo.CONSIGNOR_PINCODE,
								PROD_SERV_CODE__c: respo.PROD_SERV_CODE,
								Charged_Wt__c: respo.CHARGED_WT,
								No_Of_Packages_Booked__c: respo.NO_OF_PKGS,
								Consignee_Name__c: respo.CONSIGNEE_NAME,
								Actual_delivery_Date__c:respo.APPROVED_DLY_DT,
								Docket_Validation__c:"Valid",
                                Priority:"Normal",
								Company_of__c:this.docketresponse.companyId=='GKE'?"102":"101",
								Sub_Type__c: this.subtype
	    }
		if (respo.STOCK_OU!= null && respo.STOCK_OU !='')
		{
			defaultArray.Stock_OU__c = this.totalres[respo.STOCK_OU];
		}
		if (respo.STOCK_RECEIVING_OU!= null && respo.STOCK_RECEIVING_OU !='')
		{		
			defaultArray.Stock_Receiving_OU__c=this.totalres[respo.STOCK_RECEIVING_OU];;
		}
		defaultValues = encodeDefaultFieldValues(defaultArray);
		console.log('firstIfdefaultValues'+defaultValues);
	}
	else{
		console.log('insideincludedefault'+this.type+this.subtype);
	 defaultValues = encodeDefaultFieldValues({
			Docket_Number__c: this.docket,
			Type: this.type,
			Sub_Type__c: this.subtype,
			Docket_Validation__c:"Valid",
		    Company_of__c : '102'
		});
		console.log('firstIfdefaultValues'+defaultValues);
	}
		this[NavigationMixin.Navigate]({
			type: "standard__objectPage",

			attributes: {
				objectApiName: "Case",
				actionName: "new"
			},
			state: {
				recordTypeId: this.recordTypeId,
				nooverride: "1",
				defaultFieldValues: defaultValues
			}
		});
	}
}