import { api, LightningElement, track } from "lwc";

export default class Actionables extends LightningElement {
  requiredBool = false;
  @track parent;
  @api factorform;
  keyIndex = 0;
  @track staticdata = [];
  @track itemList = [
    {
      id: 0,
    },
  ];
  addRow() {
    ++this.keyIndex;
    var newItem = [{ id: this.keyIndex }];
    this.itemList = this.itemList.concat(newItem);
  }

  removeRow(event) {
    if (this.itemList.length >= 2) {
      this.itemList = this.itemList.filter(function (element) {
        return parseInt(element.id) !== parseInt(event.target.accessKey);
      });
      indexitem=event.target.accessKey
     
      if (this.staticdata.includes(indexitem))
      {

        const index = this.staticdata.indexOf(indexitem);
        if (index > -1) {P
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
      console.log(event.target.dataset.item + ' data');
      this.template.querySelectorAll('lightning-record-edit-form')[indexitem].submit(fields);
      this.staticdata.push(indexitem);
    }

  }
  @api handleSubmit(parentid) {
    this.parent = parentid;
    var isVal = true;
    this.template
      .querySelectorAll("lightning-input-field")
      .forEach((element) => {
        isVal = isVal && element.reportValidity();
        console.log(element.value);
      });
    if (isVal) {
      this.template
        .querySelectorAll(".hidden").forEach((element) => {
          element.click();


        });

    }
  }
  @api validate() {
    var isVal = true;
    this.template.querySelectorAll("lightning-input-field").forEach((element) => {

      isVal = isVal && element.reportValidity();
    });

    return isVal;
  }
  clearRec()
  {
    this.staticdata=[];
      this.keyIndex=0;
    this.itemList = [
      {
        id: 0,
      },
    ];

  }

  makerequired( event ){
    let selectVal = event.detail.checked;
    if (selectVal === true) {
      this.requiredBool = true;
    }else{
      this.requiredBool = false;
    }
 }

}