/**
 * xTalent Worker 360 - Main Application
 */

const App = {
    data: null,
    currentWorkerId: null,
    currentWRId: null,
    skillsChart: null,

    /**
     * Initialize the application
     */
    async init() {
        try {
            // Load data
            const response = await fetch('data/data-graph.json');
            this.data = await response.json();
            
            // Render worker list
            this.renderWorkerList();
            
            // Select first worker
            const firstWorkerId = Object.keys(this.data.workers)[0];
            if (firstWorkerId) {
                this.selectWorker(firstWorkerId);
            }
            
            // Setup event listeners
            this.setupEventListeners();
            
        } catch (error) {
            console.error('Failed to initialize app:', error);
            document.getElementById('mainContent').innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-exclamation-triangle"></i>
                    <p>Failed to load data. Please refresh the page.</p>
                </div>
            `;
        }
    },

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Mobile menu toggle
        document.addEventListener('click', (e) => {
            if (e.target.closest('.menu-toggle')) {
                document.getElementById('sidebar').classList.toggle('open');
            }
        });
        
        // Close sidebar on outside click (mobile)
        document.addEventListener('click', (e) => {
            if (window.innerWidth < 768) {
                const sidebar = document.getElementById('sidebar');
                const menuToggle = document.querySelector('.menu-toggle');
                if (!sidebar.contains(e.target) && !menuToggle.contains(e.target)) {
                    sidebar.classList.remove('open');
                }
            }
        });
    },

    /**
     * Render worker list in sidebar
     */
    renderWorkerList() {
        const workerList = document.getElementById('workerList');
        workerList.innerHTML = Render.workerList(this.data.workers, this.data.workingRelationships);
    },

    /**
     * Select a worker
     */
    selectWorker(workerId) {
        this.currentWorkerId = workerId;
        
        // Update sidebar selection
        document.querySelectorAll('.worker-item').forEach(item => {
            item.classList.toggle('active', item.dataset.workerId === workerId);
        });
        
        // Get worker and primary WR
        const worker = this.data.workers[workerId];
        const primaryWRId = worker.workingRelationships[0];
        
        // Render profile with primary WR
        this.selectWR(workerId, primaryWRId);
        
        // Close sidebar on mobile
        if (window.innerWidth < 768) {
            document.getElementById('sidebar').classList.remove('open');
        }
    },

    /**
     * Select a working relationship
     */
    selectWR(workerId, wrId) {
        this.currentWorkerId = workerId;
        this.currentWRId = wrId;
        
        const worker = this.data.workers[workerId];
        const wr = this.data.workingRelationships[wrId];
        const le = this.data.legalEntities[wr.leId];
        const activities = this.data.activities[workerId] || [];
        
        // Get assignment based on WR type
        let assignment = null;
        if (wr.type === 'employment') {
            assignment = this.data.assignments.employees[wr.assignmentId];
        } else if (wr.type === 'contract') {
            assignment = this.data.assignments.contractors[wr.assignmentId];
        } else if (wr.type === 'internship') {
            assignment = this.data.assignments.interns[wr.assignmentId];
        } else if (wr.type === 'contingent') {
            assignment = this.data.assignments.contingentWorkers[wr.assignmentId];
        }
        
        // Render profile
        this.renderProfile(worker, wr, le, assignment, activities);
    },

    /**
     * Render worker profile
     */
    renderProfile(worker, wr, le, assignment, activities) {
        const mainContent = document.getElementById('mainContent');
        
        // Build HTML
        let html = '';
        
        // Profile header
        html += Render.profileHeader(worker, wr, le, assignment);
        
        // WR switcher
        html += Render.wrSwitcher(worker, wr.id, this.data.workingRelationships, this.data.legalEntities);
        
        // Dashboard based on WR type
        if (wr.type === 'employment') {
            html += Dashboards.employee(worker, wr, le, assignment, activities);
        } else if (wr.type === 'contract') {
            html += Dashboards.contractor(worker, wr, le, assignment, activities);
        } else if (wr.type === 'internship') {
            html += Dashboards.intern(worker, wr, le, assignment, activities);
        } else if (wr.type === 'contingent') {
            html += Dashboards.contingent(worker, wr, le, assignment, activities);
        }
        
        mainContent.innerHTML = html;
        
        // Initialize charts after DOM is ready
        setTimeout(() => {
            this.initSkillsChart(worker);
        }, 100);
    },

    /**
     * Initialize skills radar chart
     */
    initSkillsChart(worker) {
        const canvas = document.getElementById('skillsChart');
        if (!canvas || worker.skills.length === 0) return;
        
        // Destroy existing chart
        if (this.skillsChart) {
            this.skillsChart.destroy();
        }
        
        const ctx = canvas.getContext('2d');
        const skills = worker.skills.slice(0, 6);
        
        this.skillsChart = new Chart(ctx, {
            type: 'radar',
            data: {
                labels: skills.map(s => s.name),
                datasets: [{
                    label: 'Skill Level',
                    data: skills.map(s => s.level),
                    backgroundColor: 'rgba(37, 99, 235, 0.2)',
                    borderColor: 'rgba(37, 99, 235, 1)',
                    borderWidth: 2,
                    pointBackgroundColor: 'rgba(37, 99, 235, 1)',
                    pointBorderColor: '#fff',
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: 'rgba(37, 99, 235, 1)'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    r: {
                        beginAtZero: true,
                        max: 100,
                        ticks: {
                            stepSize: 20,
                            font: { size: 10 },
                            display: false
                        },
                        pointLabels: {
                            font: { size: 10 }
                        },
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)'
                        }
                    }
                },
                plugins: {
                    legend: { display: false }
                }
            }
        });
    }
};

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    App.init();
});
