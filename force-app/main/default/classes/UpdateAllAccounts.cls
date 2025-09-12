global class UpdateAllAccounts implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Requêter tous les comptes
        return Database.getQueryLocator('SELECT Id FROM Account');
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope){
        Set<Id> accountIds = new Map<Id,SObject>(scope).keySet();
        UpdateAccountCAUtil.recalcAccounts(accountIds);
    }    

    global void finish(Database.BatchableContext bc){     
        // Optionnel : log ou email
    } 
}
