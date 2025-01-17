import { LightningElement } from 'lwc';
import Financial_Year from '@salesforce/label/c.Financial_Year';
import Gati_Quarter from '@salesforce/label/c.Gati_Quarter';
import getPicklistValue from '@salesforce/apex/CustomerConnectDashboardController.getPicklistValue';
import getCustmoer360 from '@salesforce/apex/CustomerConnectDashboardController.getCustmoer360';
import fetchOpprtunityData from '@salesforce/apex/CustomerConnectDashboardController.fetchOpprtunityData';
import opportunitySignedAvgDays from '@salesforce/apex/CustomerConnectDashboardController.opportunitySignedAvgDays';
import getAccountWithCustomer360 from '@salesforce/apex/CustomerConnectDashboardController.getAccountWithCustomer360';
import getPromiseRevenue from '@salesforce/apex/CustomerConnectDashboardController.getPromiseRevenue';
export default class CustomerConnectDashboard extends LightningElement {
    label = {
        Gati_Quarter,
        Financial_Year
    };
    isDashboard = false;
    quarterList = [];
    fiscalYearList = [];
    selecteQurter;
    selectFiscalYear;
    recordOfDataList;
    dailyAvgSales;
    vertocalData;
    oppAllData;
    oppDataAvg;
    contrctbusinessPer;
    promisBizPer;
    isSpinner = false;

    connectedCallback() {
        var tempqt = [];
        var tempqtyr = [];
        tempqtyr = this.label.Financial_Year.split(',');
        tempqt = this.label.Gati_Quarter.split(',');
        if (tempqt != null) {
            tempqt.forEach(ele => {
                var qObj = new Object();
                qObj.label = ele;
                qObj.value = ele;
                this.quarterList.push(qObj);
            });
        }
        if (tempqtyr != null) {
            tempqtyr.forEach(element => {
                var qObj = new Object();
                qObj.label = element;
                qObj.value = element;
                this.fiscalYearList.push(qObj);
            });
        }

    }

    handleChangeQuarter(event) {
        this.selecteQurter = event.detail.value;
        console.log('--- check quarter--', this.selecteQurter);
    }

    handleChangeFiscalYear(event) {
        this.selectFiscalYear = event.detail.value;
    }

    handleContinue(event) {
        this.isSpinner = true;
        getPicklistValue({
                quarter: this.selecteQurter,
                fiscalYear: this.selectFiscalYear
            })
            .then(result => {
                // this.isDashboard = true;
                this.dailyAvgSales = result;
                console.log('--- result---', result);
                this.handleCustomer360();
            })
            .catch(error => {
                console.error('--- errror--', error);
                this.handleCustomer360();
            })

    }

    handleCustomer360(event) {
        getCustmoer360()
            .then(result => {
                this.vertocalData = result;
                console.log('--- result 12---', result);
                this.featchOpportunityData();
            })
            .catch(error => {
                console.error('--- errror--', error);
                this.featchOpportunityData();
            })

    }

    featchOpportunityData(event) {
        fetchOpprtunityData({
                quarter: this.selecteQurter,
                fiscalYear: this.selectFiscalYear
            })
            .then(result => {
                this.oppAllData = result;
                console.log('--- result---opp', result);
                this.featchOpportunityAvg();
            })
            .catch(error => {
                console.error('--- errror--', error);
                this.featchOpportunityAvg();
            })

    }
    featchOpportunityAvg(event) {
        opportunitySignedAvgDays()
            .then(result => {
                this.oppDataAvg = result;
                //this.isDashboard = true;
                console.log('--- result---opp avg', result);
                this.featchBusinessPercentage();
            })
            .catch(error => {
                console.error('--- errror--', error);
                // this.isDashboard = true;
            })

    }
    featchBusinessPercentage(event) {
        getAccountWithCustomer360()
            .then(result => {
                this.contrctbusinessPer = result;
                //this.isDashboard = true;
                console.log('---business per', result);
                this.featchPromiseBusiness();
            })
            .catch(error => {
                console.error('--- errror--', error);
                //this.isDashboard = true;
            })
    }

    featchPromiseBusiness(event) {
        getPromiseRevenue()
            .then(result => {
                this.promisBizPer = result;
                this.isDashboard = true;
                this.isSpinner = false;
                console.log('---business per', result);
            })
            .catch(error => {
                console.error('--- errror--', error);
                this.isDashboard = true;
                this.isSpinner = false;
            })

    }

    handleCancel(event) { location.reload(); }

}