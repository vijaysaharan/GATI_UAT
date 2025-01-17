import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import SheetJs from "@salesforce/resourceUrl/SheetJs";
import getCustomerConnectData from '@salesforce/apex/SendMOMController.getCustomerConnectData';

export default class GenerateMomExcel extends LightningElement {

    @api recordId;
    @api download = false;
    scriptsLoaded = false;
    binaryString = '';
    data;
    customerConnectData;
    mergeRanges=[];
    betweenBorderCells = [];

    headerStyle = { 
        fill: { fgColor: { rgb: "DDDDDD" } },
        font: { bold: true, color: { rgb: "000000" } },
        alignment : {
            wrapText : true,
            horizontal : "center"
        },
        border : {
            top : { style: "thin", color: {rgb: "000000"} },
            left : { style: "thin", color: {rgb: "000000"} },
            right : { style: "thin", color: {rgb: "000000"} },
            bottom : { style: "thin", color: {rgb: "000000"} },
        },
    };

    bottomBorderStyle = {
        fill: { fgColor: { rgb: "DDDDDD" } },
        border : {
            bottom : { style: "thin", color: {rgb: "000000"} },
        },
    };

    topBottomBorderStyle = {
        fill: { fgColor: { rgb: "DDDDDD" } },
        border : {
            top : { style: "thin", color: {rgb: "000000"} },
            bottom : { style: "thin", color: {rgb: "000000"} },
        },
    };

    topRightBottomStyle = {
        fill: { fgColor: { rgb: "DDDDDD" } },
        border : {
            right : { style: "thin", color: {rgb: "000000"} },
            top : { style: "thin", color: {rgb: "000000"} },
            bottom : { style: "thin", color: {rgb: "000000"} },
        },
    };

    rightBottomStyle = {
        fill: { fgColor: { rgb: "DDDDDD" } },
        border : {
            right : { style: "thin", color: {rgb: "000000"} },
            bottom : { style: "thin", color: {rgb: "000000"} },
        },
    };

    customerColumnStyle = {
        fill: { fgColor: { rgb: "DDDDDD" } },
        font: { bold: true, color: { rgb: "000000" } },
        border : {
            top : { style: "thin", color: {rgb: "000000"} },
            left : { style: "thin", color: {rgb: "000000"} },
            right : { style: "thin", color: {rgb: "000000"} },
            bottom : { style: "thin", color: {rgb: "000000"} },
        },
    }

    keyPointStyle = {
        fill: { fgColor: { rgb: "0066CC" } },
        font: { bold: true, color: { rgb: "FFFFFF" } },
        border : {
            top : { style: "thin", color: {rgb: "000000"} },
            left : { style: "thin", color: {rgb: "000000"} },
            right : { style: "thin", color: {rgb: "000000"} },
            bottom : { style: "thin", color: {rgb: "000000"} },
        },
        alignment : {
            wrapText : true,
            horizontal : "center"
        },
    }

    borderBetweenStyle = {
        alignment : {
            wrapText : true,
            vertical : "center"
        },
        border : {
            top : { style: "thin", color: {rgb: "000000"} },
            left : { style: "thin", color: {rgb: "000000"} },
            right : { style: "thin", color: {rgb: "000000"} },
            bottom : { style: "thin", color: {rgb: "000000"} },
        },
    }

    borderTopStyle = { 
        border : {
            top : { style: "thin", color: {rgb: "000000"} },
            left : { style: "thin", color: {rgb: "000000"} },
            right : { style: "thin", color: {rgb: "000000"} },
        },
        alignment : {
            wrapText : true,
            vertical : "center"
        }
    };

    borderBottomStyle = { border : 
        {
            bottom : { style: "thin", color: {rgb: "000000"} },
            left : { style: "thin", color: {rgb: "000000"} },
            right : { style: "thin", color: {rgb: "000000"} },
        } 
    };

    borderAllStyle = { 
        border : {
            left : { style: "thin", color: {rgb: "000000"} },
            right : { style: "thin", color: {rgb: "000000"} },
            top : { style: "thin", color: {rgb: "000000"} },
            bottom : { style: "thin", color: {rgb: "000000"} }
        },
        alignment : {
            wrapText : true,
            vertical : "center"
        }
    };

    async connectedCallback(){
        //this.download = true;
        await loadScript(this, SheetJs);
        this.scriptsLoaded = true;
        this.customerConnectData = await getCustomerConnectData({cusId : this.recordId});       
        this.processExcel();
        this.binaryString = this.createExcel();
    }

    processExcel(){
        let gatiAttendees = '';
        let customerAttendees = '';
        let customerName = (this.customerConnectData?.customerConnect?.Lead__r?.Name) ? (this.customerConnectData?.customerConnect?.Lead__r?.Name) : ((this.customerConnectData?.customerConnect?.Customer_Code__r?.Name) ? (this.customerConnectData?.customerConnect?.Customer_Code__r?.Name) : (this.customerConnectData?.customerConnect?.Opportunity__r?.Account?.Name));
        if(this.customerConnectData?.attendees && this.customerConnectData?.attendees.length > 0){
            this.customerConnectData?.attendees.forEach(elm => {
                if(elm?.Contact__r?.Name){
                    customerAttendees += elm?.Contact__r?.Name + ',';
                }
                if(elm?.User__r?.Name){
                    gatiAttendees += elm?.User__r?.Name + ',';
                }
            });
        }
        if(this.customerConnectData?.actionable && this.customerConnectData?.actionable.length > 0){
            this.customerConnectData.actionable.forEach(elm => {
                if(elm?.Contact__r?.Name){
                    customerAttendees += elm?.Contact__r?.Name + ',';
                }
            });
        }
        if (gatiAttendees.endsWith(',')) {
            gatiAttendees = gatiAttendees.slice(0, -1);
        }
        if (customerAttendees.endsWith(',')) {
            customerAttendees = customerAttendees.slice(0, -1);
        }
        this.data = [];
        this.data.push([""]);
        this.data.push(["","Minutes of Meeting (MOM)","","","",""]);
        this.data.push(["","Meeting Date",(this.customerConnectData?.customerConnect?.Visit_Date__c) ? (this.customerConnectData?.customerConnect?.Visit_Date__c) : "" ,"","",""]);
        this.data.push(["","Customer Name",(customerName) ? (customerName) : "","","",""]);
        this.data.push(["","Customer Attendees",customerAttendees ? customerAttendees : "","","",""]);
        this.data.push(["","Gati Attendees",gatiAttendees ? gatiAttendees : "","","",""]);
        this.data.push(["","Subject","MoM Dated "+(this.customerConnectData?.customerConnect?.Visit_Date__c),"","",""]);
        this.data.push(["","Key Note",(this.customerConnectData?.customerConnect?.Key_Discussion_Description__c) ? (this.customerConnectData?.customerConnect?.Key_Discussion_Description__c) : "","","",""]);
        this.data.push(["","Discussed Points","Committed Action plan","Responsibility","Date","Status"]);
        if(this.customerConnectData?.actionable && this.customerConnectData?.actionable.length > 0){
            this.customerConnectData?.actionable.forEach(elm => {
                let temp = [""];
                temp.push(elm?.MCM_actionable__c ? elm?.MCM_actionable__c : "");
                temp.push(elm?.Task__c ? elm?.Task__c : "");
                temp.push(elm?.Action_Owner__r?.Name ? elm?.Action_Owner__r?.Name : "");
                temp.push(elm?.Due_Date__c ? elm?.Due_Date__c : "");
                temp.push(elm?.Status__c ? elm?.Status__c : "");
                this.data.push(temp);
            });
        }
        for(let i = 1; i < 8; i++){
            let s = {};
            if(i<2){
                s = {r : i, c : i};
            }
            else{
                s = {r : i, c : 2};
            }
            let e = {r : i, c : 5};
            this.mergeRanges.push({s,e});
        }
        for(let row = 9; row < (9+this.customerConnectData?.actionable.length); row++){
            for(let i = 1; i < 6; i++){
                let cell = {r : row, c : i};
                this.betweenBorderCells.push(cell);
            }
        }   
    }

    createExcel(){
        var ws = XLSX.utils.aoa_to_sheet(this.data);        
        if (ws["B2"]) {
            ws["B2"].s = this.headerStyle;
        }
        if (ws["C2"]) {
            ws["C2"].s = this.headerStyle;
        }
        if (ws["D2"]) {
            ws["D2"].s = this.topBottomBorderStyle;
        }
        if (ws["E2"]) {
            ws["E2"].s = this.topBottomBorderStyle;
        }
        if (ws["F2"]) {
            ws["F2"].s = this.topRightBottomStyle;
        }
        if (ws["B9"]) {
            ws["B9"].s = this.keyPointStyle;
        }
        if (ws["C9"]) {
            ws["C9"].s = this.keyPointStyle;
        }
        if (ws["D9"]) {
            ws["D9"].s = this.keyPointStyle;
        }
        if (ws["E9"]) {
            ws["E9"].s = this.keyPointStyle;
        }
        if (ws["F9"]) {
            ws["F9"].s = this.keyPointStyle;
        }
        
        for(let row = 2; row < 8; row++){
            const cellAddress1 = `${XLSX.utils.encode_cell({ c: 1, r: row })}`;
            const cellAddress2 = `${XLSX.utils.encode_cell({ c: 2, r: row })}`;
            const cellAddress3 = `${XLSX.utils.encode_cell({ c: 3, r: row })}`;
            const cellAddress4 = `${XLSX.utils.encode_cell({ c: 4, r: row })}`;
            const cellAddress5 = `${XLSX.utils.encode_cell({ c: 5, r: row })}`;
            if (ws[cellAddress1]) {
                ws[cellAddress1].s = this.customerColumnStyle;
            }
            if (ws[cellAddress2]) {
                ws[cellAddress2].s = this.customerColumnStyle;
            }
            if (ws[cellAddress3]) {
                ws[cellAddress3].s = this.bottomBorderStyle;
            }
            if (ws[cellAddress4]) {
                ws[cellAddress4].s = this.bottomBorderStyle;
            }
            if (ws[cellAddress5]) {
                ws[cellAddress5].s = this.rightBottomStyle;
            }
        }
        this.betweenBorderCells.forEach(cell => {
            const cellAddress = `${XLSX.utils.encode_cell(cell)}`;
            if (ws[cellAddress]) {
                ws[cellAddress].s = this.borderBetweenStyle;
            }
        });

        var wb = XLSX.utils.book_new();
        ws["!merges"] = this.mergeRanges;

        if(!ws["!cols"]) ws["!cols"] = [];
        for (let index = 1; index < 7; index++) {
            if(!ws["!cols"][index]) ws["!cols"][index] = {wch: 8};
            ws["!cols"][index].wpx = 180;
        }

        XLSX.utils.book_append_sheet(wb, ws, "MoM");
        if (!this.download) {
            return XLSX.write(wb, {type:'base64'});
        } 
        else {
            XLSX.writeFile(wb, "MoM.xlsx", { compression: true });
            this.dispatchEvent(new CustomEvent("close"));
        }
    }

    @api
    getGeneratedExcel(){
        return this.binaryString;
    }
}