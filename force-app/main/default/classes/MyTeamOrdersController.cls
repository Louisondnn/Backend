public without sharing class MyTeamOrdersController {
    public Decimal sumOrders { get; private set; }
    public List<TeamOrderWrapper> teamOrders { get; private set; }

    public class TeamOrderWrapper {
        public String userName { get; set; }
        public Decimal total { get; set; }
        public TeamOrderWrapper(String name, Decimal t) {
            userName = name;
            total = t;
        }
    }

    public MyTeamOrdersController() {
        teamOrders = new List<TeamOrderWrapper>();
        sumOrders = 0;

        // Utilisateur connecté
        Id currentUserId = UserInfo.getUserId();
        Id currentRoleId = UserInfo.getUserRoleId();

        // Tous les utilisateurs du même rôle
        List<User> usersInRole = [
            SELECT Id, Name
            FROM User
            WHERE UserRoleId = :currentRoleId
        ];

        for (User u : usersInRole) {
            AggregateResult ar = [
                SELECT SUM(TotalAmount) total
                FROM Order
                WHERE Status IN ('Draft', 'Activated', 'Submitted', 'Ordered')
                AND OwnerId = :u.Id
            ][0];

            Decimal total = (ar.get('total') == null) ? 0 : (Decimal) ar.get('total');
            sumOrders += total;
            teamOrders.add(new TeamOrderWrapper(u.Name, total));
        }
    }
}

