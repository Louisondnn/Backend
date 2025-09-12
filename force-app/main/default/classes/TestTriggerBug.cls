@IsTest
public class TestTriggerBug {

    @IsTest
    static void testBulkOrders() {
        Account acc = new Account(Name='Compte Bug 100', Chiffre_d_affaire__c=0);
        insert acc;

        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < 100; i++) {
            orders.add(new Order(
                AccountId = acc.Id,
                Status = 'Ordered',
                TotalAmount = 100 + i

            ));
        }

        // L'insertion doit échouer ou provoquer l’erreur de limites
        try {
            insert orders;
            System.debug('Insertion réussie'); 
        } catch (Exception e) {
            System.debug('Erreur attendue : ' + e.getMessage());
        }
    }
}
