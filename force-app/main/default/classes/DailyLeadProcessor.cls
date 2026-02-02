public with sharing class DailyLeadProcessor implements Schedulable {
    public void execute(SchedulableContext ctx) {
        List<Lead> leads = [Select Id FROM Lead WHERE LeadSource = NULL LIMIT 200];
        for(Lead l : leads) {
            l.LeadSource = 'Dreamforce';
        }
        update leads;
    }

}