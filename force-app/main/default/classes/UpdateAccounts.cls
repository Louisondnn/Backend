global class UpdateAccounts implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Account
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Account> accounts = (List<Account>) scope;
        
        // Changer 'Ordered' par 'Activated' ici 
        List<Order> orders = [
            SELECT AccountId, TotalAmount
            FROM Order
            WHERE AccountId IN :accounts
              AND Status = 'Activated'  
        ];
        
        Map<Id, Decimal> sumMap = new Map<Id, Decimal>();
        for (Order o : orders) {
            Decimal montant = (o.TotalAmount != null) ? o.TotalAmount : 0;
            sumMap.put(
                o.AccountId,
                (sumMap.containsKey(o.AccountId) ? sumMap.get(o.AccountId) : 0) + montant
            );
        }
        
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : accounts) {
            acc.Chiffre_d_affaire__c = sumMap.containsKey(acc.Id)
                ? sumMap.get(acc.Id)
                : 0;
            accountsToUpdate.add(acc);
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optionnel : log, notification ou audit
    }
}