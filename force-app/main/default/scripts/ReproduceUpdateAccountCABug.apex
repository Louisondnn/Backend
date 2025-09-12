// 1️⃣ Créer un compte test
Account acc = new Account(
    Name = 'Compte Bug 100 commandes',
    Chiffre_d_affaire__c = 0
);
insert acc;

// 2️⃣ Créer 100 commandes avec un Status valide + EffectiveDate
Date today = Date.today();

List<Order> orders = new List<Order>();
for (Integer i = 0; i < 100; i++) {
    orders.add(new Order(
        Name = 'Commande ' + (i + 1),
        AccountId = acc.Id,
        Status = 'Draft', // ⚠️ doit exister dans ton picklist
        EffectiveDate = today,
        Montant__c = 100 + i
    ));
}
insert orders;

// 3️⃣ Mise à jour des commandes vers 'Activated' (ou autre valeur valide qui déclenche ton trigger)
for (Order o : orders) {
    o.Status = 'Activated'; // ⚠️ adapte selon les valeurs de ton picklist
}
update orders;

// 4️⃣ Vérification du Chiffre d’affaires
acc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
System.debug('Chiffre d\'affaires calculé : ' + acc.Chiffre_d_affaire__c);
