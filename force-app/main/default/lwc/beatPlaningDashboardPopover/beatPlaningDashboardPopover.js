import { LightningElement, api, track } from 'lwc';

export default class BeatPlaningDashboardPopover extends LightningElement {
    @api accountDataApi;
    @api account360DataApi;
    @track accountData;
    @track account360Data;

    connectedCallback(){
        console.log('pop up log');
        this.accountData = JSON.parse(JSON.stringify(this.accountDataApi));
        this.account360Data = JSON.parse(JSON.stringify(this.account360DataApi));
        this.account360Data.LYSMTD = this.formatCurrency(this.account360Data.LYSMTD);
        this.account360Data.MTD = this.formatCurrency(this.account360Data.MTD);
        this.account360Data.LMTD = this.formatCurrency(this.account360Data.LMTD);
    }

    formatCurrency(amount, currency = "INR", locale = "en-US") {
        const formatter = new Intl.NumberFormat(locale, {
          style: "currency",
          currency,
        });
        return formatter.format(amount);
    }
}