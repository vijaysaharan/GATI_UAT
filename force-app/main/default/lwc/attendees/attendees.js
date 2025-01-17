import { LightningElement,track,api } from 'lwc';

export default class Attendees extends LightningElement {
	@track parent;
	@api factorform;
	@api usrid;
	keyIndex = 0;
	@track staticdata = [];
	@track itemList = [
		{
			id: 0
		}
	];

	addRow() {
		++this.keyIndex;
		var newItem = [{ id: this.keyIndex }];
		this.itemList = this.itemList.concat(newItem);
	}


	connectedCallback()
	{
		console.log(`user id is ${this.usrid}`);
	}
	removeRow(event) {
		if (this.itemList.length >= 2) {
			this.itemList = this.itemList.filter(function (element) {
				return parseInt(element.id) !== parseInt(event.target.accessKey);
			});
			indexitem = event.target.accessKey;

			if (this.staticdata.includes(indexitem)) {
				const index = this.staticdata.indexOf(indexitem);
				if (index > -1) {
					P;
					this.staticdata.splice(index, 1);
				}
			}
		}
	}
	handleSubmits(event) {
		event.preventDefault();
		const fields = event.detail.fields;
		console.log("Fields: ", fields);
		fields.Customer_Connect__c = this.parent;
		console.log(this.parent);
		let indexitem = event.target.dataset.item;
		if (!this.staticdata.includes(indexitem)) {
			console.log(event.target.dataset.item + " data");
			this.template.querySelectorAll("lightning-record-edit-form")[indexitem].submit(fields);
			this.staticdata.push(indexitem);
		}
	}
	@api handleSubmit(parentid) {
		this.parent = parentid;
		var isVal = true;
		// this.template.querySelectorAll("lightning-input-field").forEach((element) => {
		// 	isVal = isVal && element.reportValidity();
		// });
		if (isVal) {
			this.template.querySelectorAll(".hidden").forEach((element) => {
				element.click();
			});
		}
	}
	@api validate() {
		var isVal = true;
    var check=true;
		let arr = [];
		this.template.querySelectorAll("lightning-input-field").forEach((element) => {
			console.log(`Element is ${element.name} the value is ${element.value} row is ${element.dataset.id}`);
			 if (arr.includes(element.value) && element.value!=null) {
			 
			   isVal = false;
         alert(`Duplicate Attendee found for ${element.name} at row ${parseInt(element.dataset.id) + 1}`);
         return isVal;

			 }
			 else
       {
			 arr.push(element.value);
       }

			isVal = isVal && element.reportValidity();
		});
    if(!check)
    isVal=false;
		return isVal;
	}
	showToast(tit, mess, vari, mod) {
		const event = new ShowToastEvent({
			title: tit,
			message: mess,
			variant: vari
		});
		this.dispatchEvent(event);
	}
	clearRec() {
		this.staticdata = [];
		this.keyIndex = 0;
		this.itemList = [
			{
				id: 0
			}
		];
	}
}