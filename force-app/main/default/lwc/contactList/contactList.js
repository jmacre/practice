import { LightningElement, wire } from 'lwc';
import getContacts from '@salesforce/apex/ContactController.getContacts';
import FIRST_NAME_FIELD from '@salesforce/schema/Contact.FirstName'
import LAST_NAME_FIELD from '@salesforce/schema/Contact.LastName'
import EMAIL_FIELD from '@salesforce/schema/Contact.Email'

export default class ContactList extends LightningElement {
    @wire(getContacts)
    contacts;

    COLUMNS = [
        { label: 'First Name', fieldName: FIRST_NAME_FIELD.fieldApiName, type: 'text' },
        { label: 'Last Name', fieldName: LAST_NAME_FIELD.fieldApiName, type: 'text' },
        { label: 'Email', fieldName: EMAIL_FIELD.fieldApiName, type: 'text' }
    ]


}