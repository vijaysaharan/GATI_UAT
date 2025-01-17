trigger QuoteTrigger on Quote (Before Insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        QuoteTriggerHandler.quoteCreationValidation(Trigger.new);
    }
}