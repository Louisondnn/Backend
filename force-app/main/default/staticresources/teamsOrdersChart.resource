// teamOrdersChart.js
function drawTeamOrdersChart(teamOrders) {
    google.charts.load('current', {packages:['corechart']});
    google.charts.setOnLoadCallback(function() {
        var data = google.visualization.arrayToDataTable([
            ['Commercial', 'Total']
            ].concat(
                teamOrders.map(function(t) { 
                    return [t.userName, t.total]; 
                })
            )
        );

        var options = {
            title: 'Commandes par commercial',
            pieHole: 0.4,
            width: 600,
            height: 400
        };

        var chart = new google.visualization.PieChart(
            document.getElementById('chart_div')
        );
        chart.draw(data, options);
    });
}
