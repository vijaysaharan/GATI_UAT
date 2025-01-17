import { LightningElement } from 'lwc';
import Bulkfile_download from '@salesforce/resourceUrl/BulkAccountTeamMember';

export default class AccountTeamMemberCSVDownload extends LightningElement {



    download(event) {
        var baseUrl = 'https://' + location.host;
        window.open(baseUrl + Bulkfile_download + '/BulkPickup.csv');

    }
}