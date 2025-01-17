import { track, LightningElement, api } from 'lwc';
import Verticals from '@salesforce/label/c.Verticals';

export default class CustomerConnectDashboardChild extends LightningElement {
    @api recordList;
    @api verticalWiseBiz;
    verticalList;
    recordListOdData = [];
    @api oppRecords = [];
    @api oppRecordsAverage = [];
    @api businessData = [];
    @api promisBizPerData = [];
    @track tableList = [{ colList: [''] }];
    // @track tableList = [{colList: ['','Retail','MSME','Strategic','KEA']}];
    connectedCallback(event) {
        console.log('-- opp--avg', this.oppRecordsAverage);
        this.verticalList = Verticals.split(',');
        if (this.recordList != null) {
            this.recordList.forEach(ele => {
                this.tableList[0].colList.push(ele.months);
            })
        }
        this.tableList.push({ colList: ['Retail'] });
        this.verticalList = Verticals.split(',');
        if (this.recordList != null) {
            this.recordList.forEach(ele => {
                this.tableList[1].colList.push(ele.retailData);
            })
        }
        this.tableList.push({ colList: ['MSME'] });
        this.verticalList = Verticals.split(',');
        if (this.recordList != null) {
            this.recordList.forEach(ele => {
                this.tableList[2].colList.push(ele.msmeData);
            })
        }
        this.tableList.push({ colList: ['Strategic'] });
        this.verticalList = Verticals.split(',');
        if (this.recordList != null) {
            this.recordList.forEach(ele => {
                this.tableList[3].colList.push(ele.strategicData);
            })
        }
        this.tableList.push({ colList: ['KEA'] });
        this.verticalList = Verticals.split(',');
        if (this.recordList != null) {
            this.recordList.forEach(ele => {
                this.tableList[4].colList.push(ele.kealData);
            })
        }
        if (this.verticalWiseBiz != null) {
            this.verticalWiseBiz.forEach(ele => {
                this.tableList[0].colList.push(ele.months);
            })
        }
        if (this.verticalWiseBiz != null) {
            this.verticalWiseBiz.forEach(ele => {
                this.tableList[1].colList.push(ele.retailData);
            })
        }
        if (this.verticalWiseBiz != null) {
            this.verticalWiseBiz.forEach(ele => {
                this.tableList[2].colList.push(ele.msmeData);
            })
        }
        if (this.verticalWiseBiz != null) {
            this.verticalWiseBiz.forEach(ele => {
                this.tableList[3].colList.push(ele.strategicData);
            })
        }
        if (this.verticalWiseBiz != null) {
            this.verticalWiseBiz.forEach(ele => {
                this.tableList[4].colList.push(ele.kealData);
            })
        }
        if (this.oppRecords != null) {
            this.oppRecords.forEach(ele => {
                this.tableList[0].colList.push(ele.months);
            })
        }
        if (this.oppRecords != null) {
            this.oppRecords.forEach(ele => {
                this.tableList[1].colList.push(ele.retailData);
            })
        }
        if (this.oppRecords != null) {
            this.oppRecords.forEach(ele => {
                this.tableList[2].colList.push(ele.msmeData);
            })
        }
        if (this.oppRecords != null) {
            this.oppRecords.forEach(ele => {
                this.tableList[3].colList.push(ele.strategicData);
            })
        }
        if (this.oppRecords != null) {
            this.oppRecords.forEach(ele => {
                this.tableList[4].colList.push(ele.kealData);
            })
        }
        if (this.oppRecordsAverage != null) {
            this.oppRecordsAverage.forEach(ele => {
                this.tableList[0].colList.push(ele.months);
            })
        }
        if (this.oppRecordsAverage != null) {
            this.oppRecordsAverage.forEach(ele => {
                this.tableList[1].colList.push(ele.retailData);
            })
        }
        if (this.oppRecordsAverage != null) {
            this.oppRecordsAverage.forEach(ele => {
                this.tableList[2].colList.push(ele.msmeData);
            })
        }
        if (this.oppRecordsAverage != null) {
            this.oppRecordsAverage.forEach(ele => {
                this.tableList[3].colList.push(ele.strategicData);
            })
        }
        if (this.oppRecordsAverage != null) {
            this.oppRecordsAverage.forEach(ele => {
                this.tableList[4].colList.push(ele.kealData);
            })
        }
        //business
        if (this.businessData != null) {
            this.businessData.forEach(ele => {
                this.tableList[0].colList.push(ele.months);
            })
        }
        if (this.businessData != null) {
            this.businessData.forEach(ele => {
                this.tableList[1].colList.push(ele.retailData);
            })
        }
        if (this.businessData != null) {
            this.businessData.forEach(ele => {
                this.tableList[2].colList.push(ele.msmeData);
            })
        }
        if (this.businessData != null) {
            this.businessData.forEach(ele => {
                this.tableList[3].colList.push(ele.strategicData);
            })
        }
        if (this.businessData != null) {
            this.businessData.forEach(ele => {
                this.tableList[4].colList.push(ele.kealData);
            })
        }
        //promise business
        if (this.promisBizPerData != null) {
            this.promisBizPerData.forEach(ele => {
                this.tableList[0].colList.push(ele.months);
            })
        }
        if (this.promisBizPerData != null) {
            this.promisBizPerData.forEach(ele => {
                this.tableList[1].colList.push(ele.retailData);
            })
        }
        if (this.promisBizPerData != null) {
            this.promisBizPerData.forEach(ele => {
                this.tableList[2].colList.push(ele.msmeData);
            })
        }
        if (this.promisBizPerData != null) {
            this.promisBizPerData.forEach(ele => {
                this.tableList[3].colList.push(ele.strategicData);
            })
        }
        if (this.promisBizPerData != null) {
            this.promisBizPerData.forEach(ele => {
                this.tableList[4].colList.push(ele.kealData);
            })
        }
    }

}