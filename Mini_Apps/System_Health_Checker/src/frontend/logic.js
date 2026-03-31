async function updateMetrics() {
    const cpuEl = document.getElementById('cpu');
    const memEl = document.getElementById('mem');
    const diskEl = document.getElementById('disk');
    const timeEl = document.getElementById('time');

    try {
        const response = await fetch('/metrics');
        const data = await response.json();
        
        
        cpuEl.innerText = data.cpu;
        memEl.innerText = data.memory;
        diskEl.innerText = data.disk;
        
       
        const now = new Date(data.timestamp);
        timeEl.innerText = now.toLocaleTimeString();
        
    } catch (error) {
        console.error("Failed to fetch metrics:", error);
        timeEl.innerText = "Error";
    }
}

document.getElementById('refreshBtn').addEventListener('click', updateMetrics);


setInterval(updateMetrics, 5000);


updateMetrics();