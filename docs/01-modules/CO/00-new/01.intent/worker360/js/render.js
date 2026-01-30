/**
 * xTalent Worker 360 - Render Functions
 */

const Render = {
    /**
     * Render worker list in sidebar
     */
    workerList(workers, wrs) {
        return Object.values(workers).map((worker, index) => {
            const primaryWR = wrs[worker.workingRelationships[0]];
            return `
                <div class="worker-item ${index === 0 ? 'active' : ''}" 
                     data-worker-id="${worker.id}"
                     onclick="App.selectWorker('${worker.id}')">
                    <div class="avatar">${Utils.getInitials(worker.name)}</div>
                    <div class="worker-item-info">
                        <div class="worker-item-name">${worker.name}</div>
                        <div class="worker-item-type">
                            <span class="badge ${primaryWR.type}">${Utils.getWRTypeLabel(primaryWR.type)}</span>
                        </div>
                    </div>
                </div>
            `;
        }).join('');
    },

    /**
     * Render profile header
     */
    profileHeader(worker, wr, le, assignment) {
        const skills = worker.skills.slice(0, 5);
        const moreSkills = worker.skills.length - 5;
        
        let currentTitle = '';
        if (wr.type === 'employment' && assignment) {
            currentTitle = assignment.position.title;
        } else if (wr.type === 'contract' && assignment) {
            currentTitle = assignment.projectAssignment.role;
        } else if (wr.type === 'internship' && assignment) {
            currentTitle = assignment.position.title;
        } else if (wr.type === 'contingent' && assignment) {
            currentTitle = assignment.assignment.title;
        }

        return `
            <div class="profile-header animate">
                <div class="profile-header-content">
                    <div class="avatar lg">${Utils.getInitials(worker.name)}</div>
                    <div class="profile-info">
                        <div class="profile-name-row">
                            <div>
                                <h1 class="profile-name">${worker.name}</h1>
                                <div class="profile-worker-id">Worker ID: ${worker.id}</div>
                            </div>
                            <span class="status-badge ${wr.status}">
                                <i class="fas fa-circle"></i>
                                ${wr.status.charAt(0).toUpperCase() + wr.status.slice(1)}
                            </span>
                        </div>
                        
                        <div class="profile-meta">
                            <span class="profile-meta-item">
                                <i class="fas fa-briefcase"></i>
                                ${currentTitle}
                            </span>
                            <span class="profile-meta-item">
                                <i class="fas fa-building"></i>
                                ${le.name}
                            </span>
                            <span class="profile-meta-item">
                                <i class="fas fa-map-marker-alt"></i>
                                ${wr.workLocation}
                            </span>
                            <span class="profile-meta-item">
                                <i class="fas fa-clock"></i>
                                ${Utils.calculateTenure(wr.startDate)} tenure
                            </span>
                        </div>
                        
                        <div class="contact-btns">
                            <button class="btn">
                                <i class="fas fa-envelope"></i>
                                ${worker.email}
                            </button>
                            <button class="btn">
                                <i class="fas fa-phone"></i>
                                ${worker.phone}
                            </button>
                            ${wr.workEmail ? `
                                <button class="btn">
                                    <i class="fas fa-at"></i>
                                    ${wr.workEmail}
                                </button>
                            ` : ''}
                        </div>
                        
                        <div class="skills-tags">
                            ${skills.map(s => `<span class="tag">${s.name}</span>`).join('')}
                            ${moreSkills > 0 ? `<span class="tag more">+${moreSkills} more</span>` : ''}
                        </div>
                    </div>
                </div>
            </div>
        `;
    },

    /**
     * Render WR switcher
     */
    wrSwitcher(worker, selectedWRId, wrs, les) {
        const workerWRs = worker.workingRelationships.map(wrId => wrs[wrId]);
        
        return `
            <div class="wr-switcher animate" style="animation-delay: 0.1s">
                <div class="wr-switcher-header">
                    <span class="wr-switcher-title">
                        <i class="fas fa-briefcase"></i>
                        Working Relationships (${workerWRs.length})
                    </span>
                </div>
                <div class="wr-cards">
                    ${workerWRs.map(wr => {
                        const le = les[wr.leId];
                        const isActive = wr.id === selectedWRId;
                        const isHistorical = wr.status === 'completed';
                        
                        return `
                            <div class="wr-card ${isActive ? 'active' : ''} ${isHistorical ? 'historical' : ''}" 
                                 onclick="App.selectWR('${worker.id}', '${wr.id}')">
                                <div class="wr-card-le">
                                    <i class="fas fa-building"></i>
                                    ${le.name}
                                </div>
                                <div class="wr-card-details">
                                    <div class="wr-card-row">
                                        <span>Type:</span>
                                        <span class="badge ${wr.type}">${Utils.getWRTypeLabel(wr.type)}</span>
                                    </div>
                                    <div class="wr-card-row">
                                        <span>Period:</span>
                                        <span>${Utils.formatDate(wr.startDate)} - ${wr.endDate ? Utils.formatDate(wr.endDate) : 'Present'}</span>
                                    </div>
                                    <div class="wr-card-row">
                                        <span>Status:</span>
                                        <span>${wr.status}</span>
                                    </div>
                                </div>
                            </div>
                        `;
                    }).join('')}
                </div>
            </div>
        `;
    },

    /**
     * Render info card
     */
    infoCard(title, icon, items, scopeBadge = null, delay = 0) {
        return `
            <div class="card col-4 animate" style="animation-delay: ${delay}s">
                <div class="card-header">
                    <span class="card-title">
                        <i class="fas fa-${icon}"></i>
                        ${title}
                        ${scopeBadge ? `<span class="scope-badge ${scopeBadge.type}">${scopeBadge.label}</span>` : ''}
                    </span>
                </div>
                <div class="info-list">
                    ${items.map(item => `
                        <div class="info-row">
                            <span class="info-label">${item.label}</span>
                            <span class="info-value ${item.link ? 'link' : ''}">${item.value}</span>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;
    },

    /**
     * Render goals list
     */
    goalsList(goals) {
        return `
            <div class="goals-list">
                ${goals.map(g => `
                    <div class="goal">
                        <div class="goal-header">
                            <span class="goal-title">${g.title}</span>
                            <span class="goal-status ${g.status}">${g.status.replace('-', ' ')}</span>
                        </div>
                        <div class="goal-progress">
                            <div class="progress-bar" style="flex: 1;">
                                <div class="progress-fill" style="width: ${g.progress}%"></div>
                            </div>
                            <span class="goal-percent">${g.progress}%</span>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    },

    /**
     * Render timeline
     */
    timeline(items) {
        return `
            <div class="timeline">
                ${items.map((item, i) => `
                    <div class="timeline-item ${i === 0 ? 'current' : 'completed'}">
                        <div class="timeline-dot"></div>
                        <div class="timeline-content">
                            <div class="timeline-title">${item.event}</div>
                            <div class="timeline-subtitle">${item.from ? `${item.from} → ${item.to}` : (item.position || item.details || '')}</div>
                            <div class="timeline-date">${Utils.formatDate(item.date)}</div>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    },

    /**
     * Render deliverables list
     */
    deliverablesList(deliverables) {
        return `
            <div class="deliverables-list">
                ${deliverables.map(d => `
                    <div class="deliverable">
                        <div class="deliverable-icon ${d.status}">
                            <i class="fas fa-${d.status === 'completed' ? 'check' : d.status === 'in-progress' ? 'spinner' : 'clock'}"></i>
                        </div>
                        <div class="deliverable-info">
                            <div class="deliverable-name">${d.name}</div>
                            <div class="deliverable-meta">Due: ${Utils.formatDate(d.dueDate)} ${d.progress ? `• Progress: ${d.progress}%` : ''}</div>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    },

    /**
     * Render activity feed
     */
    activityFeed(activities) {
        if (!activities || activities.length === 0) {
            return '<div style="color: var(--text-tertiary); font-size: 0.8125rem;">No recent activity</div>';
        }
        
        return `
            <div class="activity-feed">
                ${activities.map(a => `
                    <div class="activity">
                        <div class="activity-icon">
                            <i class="fas fa-${a.icon}"></i>
                        </div>
                        <div class="activity-content">
                            <div class="activity-text">${a.action}</div>
                            <div class="activity-details">${a.details}</div>
                            <div class="activity-time">${a.time}</div>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    },

    /**
     * Render quick actions
     */
    quickActions(actions) {
        return `
            <div class="quick-actions">
                ${actions.map((a, i) => `
                    <button class="btn ${i === 0 ? 'primary' : ''}">
                        <i class="fas fa-${a.icon}"></i>
                        ${a.label}
                    </button>
                `).join('')}
            </div>
        `;
    }
};

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Render;
}
