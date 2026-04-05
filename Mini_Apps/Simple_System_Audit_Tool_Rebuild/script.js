// Concepts to learn :
// 1. ASYNC functions 
// 2. const and let
// 3. Fetch API to make HTTP requests to the backend
// 3. await to handle asynchronous operations
// 5. Response handling 
// 6. InnerText 


// Parts :
// 1. UpdateMetrics function to fetch and display current system metrics
// 2. UpdateHistory function to fetch and display historical metrics data in a table
// 3. Event listener for the refresh button to trigger updates
// 4. Initial calls to populate the dashboard on page load
// 5. SetInterval to auto-refresh metrics every 5 seconds

async function UpdateMetrics() {
    try{
        const response = await fetch('/metrics');
        const data = await response.json();
        document.getElementById('cpu').innerText = data.cpu;
        document.getElementById('mem').innerText = data.memory;
        document.getElementById('disk').innerText = data.disk;
        document.getElementById('time').innerText = new Date(data.timestamp).toLocaleTimeString();
    } catch (error) {
        console.error("Metrics Error:", error);
    }

    
}

async function UpdateHistory() {
    try {
        const response = await fetch('/history'); // Fetch historical data from the backend
        const historyData = await response.json(); // Parse the JSON response
        const body = document.getElementById('historyBody');
        if (!body) return;

        // Map the historical data to table rows and update the table body

        body.innerHTML = historyData.map(row => `<tr>
            <td>${new Date(row.timestamp).toLocaleTimeString()}</td>
            <td>${row.cpu}%</td>
            <td>${row.memory}%</td>
            <td>${row.disk}%</td>
        </tr>`).join('');
    } catch (error) {
        console.error("History Fetch Error:", error);
    }   

}

// Event listener for the refresh button to trigger updates

document.getElementById('refreshBtn').addEventListener('click', () => {
    UpdateMetrics();
    UpdateHistory();
});

UpdateMetrics();
UpdateHistory();

setInterval(() => {
    UpdateMetrics(); // Auto-refresh metrics every 5 seconds
}, 5000);
