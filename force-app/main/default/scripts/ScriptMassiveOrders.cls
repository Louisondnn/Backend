public class ScriptMassiveOrders {
    public static void run(Integer nbOrders) {
        Account acc = new Account(Name='Compte Test Massive', Chiffre_d_affaire__c=0);
        insert acc;

        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < nbOrders; i++) {
            orders.add(new Order(
                Name = 'Commande ' + (i + 1),
                AccountId = acc.Id,
                Status = 'Draft', // ou une valeur valide dans ton picklist
                Montant__c = 100 + i,
                EffectiveDate = Date.today()
            ));
        }
        insert orders;

        System.debug('Nombre de commandes créées : ' + orders.size());
    }
}
