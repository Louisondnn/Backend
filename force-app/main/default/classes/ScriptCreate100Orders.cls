public class ScriptCreate100Orders {
    public static void run() {
        // Création d'un compte de test
        Account acc = new Account(Name='Test', Chiffre_d_affaire__c=0);        
        insert acc;

        // Création de 100 commandes
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 100; i++) {
            orders.add(new Order(
                Name = 'Commande ' + (i+1),
                AccountId = acc.Id,
                Status = 'Draft',
                Montant__c = 100 + i,
                EffectiveDate = Date.today() 
            ));
        }
        insert orders;

        // Debug du nombre de commandes créées
        Integer nbOrders = [SELECT COUNT() FROM Order WHERE AccountId = :acc.Id];
        System.debug('Nombre de commandes créées : ' + nbOrders);

        // Calcul du chiffre d'affaires total
        AggregateResult result = [SELECT SUM(Montant__c) sumMontant FROM Order WHERE AccountId = :acc.Id];
        Decimal totalCA = (Decimal) result.get('sumMontant'); // cast obligatoire
        acc.Chiffre_d_affaire__c = totalCA != null ? totalCA : 0;
        update acc;

        System.debug('Chiffre d\'affaires calculé : ' + acc.Chiffre_d_affaire__c);
    }
}
