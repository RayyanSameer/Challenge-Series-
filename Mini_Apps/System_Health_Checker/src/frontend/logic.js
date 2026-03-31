async function updateMetrics() {
    try {
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

async function updateHistory() {
    try {
        const response = await fetch('/history');
        const historyData = await response.json();
        
        const body = document.getElementById('historyBody');
        if (!body) return; 

        body.innerHTML = historyData.map(row => `
            <tr>
                <td>${new Date(row.timestamp).toLocaleTimeString()}</td>
                <td>${row.cpu}%</td>
                <td>${row.memory}%</td>
                <td>${row.disk}%</td>
            </tr>
        `).join('');
    } catch (error) {
        console.error("History Fetch Error:", error);
    }
}

document.getElementById('refreshBtn').addEventListener('click', () => {
    updateMetrics();
    updateHistory();
});

updateMetrics();
updateHistory();


setInterval(() => {
    updateMetrics(); 

}, 5000);