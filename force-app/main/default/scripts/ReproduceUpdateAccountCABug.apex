// 1️ Créer un compte test
Account acc = new Account(
    Name = 'Compte Bug 100 commandes',
    Chiffre_d_affaire__c = 0
);
insert acc;

// Create a PricebookEntry for a standard product
Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
insert prod;

PricebookEntry pbe = new PricebookEntry(
    Pricebook2Id = Test.getStandardPricebookId(),
    Product2Id = prod.Id,
    UnitPrice = 10.0,
    IsActive = true
);
insert pbe;

// 2 Créer 100 commandes avec un Status valide + EffectiveDate
Date today = Date.today();

List<Order> orders = new List<Order>();
for (Integer i = 0; i < 100; i++) {
    Order newOrder = new Order(
        Name = 'Commande ' + (i + 1),
        AccountId = acc.Id,
        Status = 'Draft', // ⚠️ doit exister dans ton picklist
        EffectiveDate = today,
        OwnerAmount = 100 + i
    );
    orders.add(newOrder);
}
insert orders;

// 3️Mise à jour des commandes vers 'Activated' (ou autre valeur valide qui déclenche ton trigger)
for (Order o : orders) {
    o.Status = 'Activated'; // ⚠️ adapte selon les valeurs de ton picklist
}
update orders;

// Add OrderItems to the orders to avoid FAILED_ACTIVATION error
List<OrderItem> orderItems = new List<OrderItem>();
for (Order o : orders) {
    orderItems.add(new OrderItem(
        OrderId = o.Id,
        PricebookEntryId = pbe.Id,
        Quantity = 1,
        UnitPrice = 10.0
    ));
}
insert orderItems;

// 4️Vérification du Chiffre d’affaires
acc = [SELECT Chiffre_d_affaire__c FROM Account WHERE Id = :acc.Id];
System.debug('Chiffre d\'affaires calculé : ' + acc.Chiffre_d_affaire__c);
