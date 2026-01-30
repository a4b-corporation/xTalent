/**
 * xTalent Worker 360 - Dashboard Renderers
 * Specific dashboard layouts for each Working Relationship type
 */

const Dashboards = {
    /**
     * Render Employee Dashboard
     */
    employee(worker, wr, le, assignment, activities) {
        const attendance = assignment.timeAndAttendance.thisMonth;
        const attendancePercent = Math.round((attendance.daysWorked / attendance.workingDays) * 100);
        
        return `
            <div class="dashboard-grid">
                ${Render.infoCard('Worker Profile', 'user', [
                    { label: 'Full Name', value: worker.name },
                    { label: 'Date of Birth', value: Utils.formatDate(worker.dob) + ' (' + Utils.calculateAge(worker.dob) + 'y)' },
                    { label: 'Nationality', value: worker.nationality },
                    { label: 'Certifications', value: worker.certifications.length + ' active' },
                    { label: 'Languages', value: worker.languages.map(function(l) { return l.language; }).join(', ') }
                ], { type: 'worker', label: 'Shared' }, 0.15)}
                
                ${Render.infoCard('Working Relationship', 'file-contract', [
                    { label: 'Legal Entity', value: le.name },
                    { label: 'Type', value: Utils.getWRSubTypeLabel(wr.subType) },
                    { label: 'Contract', value: wr.contractType },
                    { label: 'Location', value: wr.workLocation },
                    { label: 'Start Date', value: Utils.formatDate(wr.startDate) },
                    { label: 'Probation', value: wr.probationCompleted ? '✓ Completed' : 'In Progress' }
                ], { type: 'wr', label: 'WR-Specific' }, 0.2)}
                
                ${Render.infoCard('Organization', 'sitemap', [
                    { label: 'Position', value: assignment.position.title },
                    { label: 'Level', value: assignment.position.jobLevel + ' - ' + assignment.position.grade },
                    { label: 'Department', value: assignment.organization.department },
                    { label: 'Team', value: assignment.organization.team },
                    { label: 'Manager', value: assignment.manager.name, link: true },
                    { label: 'Direct Reports', value: assignment.directReports.length + ' people' }
                ], null, 0.25)}
                
                <div class="card col-4 animate" style="animation-delay: 0.3s">
                    <div class="card-header">
                        <span class="card-title"><i class="fas fa-clock"></i> Time & Attendance</span>
                    </div>
                    <div style="margin-bottom: var(--space-md);">
                        <div style="display: flex; justify-content: space-between; font-size: 0.75rem; margin-bottom: var(--space-xs);">
                            <span>This Month</span>
                            <span>${attendance.daysWorked}/${attendance.workingDays} days (${attendancePercent}%)</span>
                        </div>
                        <div class="progress-bar"><div class="progress-fill" style="width: ${attendancePercent}%"></div></div>
                    </div>
                    <div class="stats-row">
                        <div class="stat"><div class="stat-value success">${assignment.timeAndAttendance.leaveBalances.annual.remaining}</div><div class="stat-label">Annual</div></div>
                        <div class="stat"><div class="stat-value">${assignment.timeAndAttendance.leaveBalances.sick ? assignment.timeAndAttendance.leaveBalances.sick.remaining : 'N/A'}</div><div class="stat-label">Sick</div></div>
                        <div class="stat"><div class="stat-value warning">${attendance.overtime}h</div><div class="stat-label">Overtime</div></div>
                    </div>
                </div>
                
                <div class="card col-4 animate" style="animation-delay: 0.35s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-chart-line"></i> Performance</span></div>
                    <div style="text-align: center; margin-bottom: var(--space-md);">
                        <div style="font-size: 0.75rem; color: var(--text-tertiary);">Current Rating</div>
                        <div style="font-size: 1.25rem; font-weight: 700; color: var(--success);">${assignment.performance.currentRating}</div>
                        ${assignment.performance.ratingScore ? '<div style="font-size: 0.75rem; color: var(--text-secondary);">' + assignment.performance.ratingScore + '/5.0</div>' : ''}
                    </div>
                    ${Render.goalsList(assignment.performance.goals.slice(0, 3))}
                </div>
                
                <div class="card col-4 animate" style="animation-delay: 0.4s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-cogs"></i> Skills Profile</span></div>
                    <div class="chart-container"><canvas id="skillsChart"></canvas></div>
                </div>
                
                <div class="card col-6 animate" style="animation-delay: 0.45s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-history"></i> Employment History</span></div>
                    ${Render.timeline(assignment.history)}
                </div>
                
                <div class="card col-6 animate" style="animation-delay: 0.5s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-stream"></i> Recent Activity</span></div>
                    ${Render.activityFeed(activities)}
                </div>
                
                <div class="card col-12 animate" style="animation-delay: 0.55s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-bolt"></i> Quick Actions</span></div>
                    ${Render.quickActions([
                        { icon: 'calendar-plus', label: 'Request Leave' },
                        { icon: 'file-invoice', label: 'View Payslip' },
                        { icon: 'bullseye', label: 'Update Goals' },
                        { icon: 'graduation-cap', label: 'Enroll Training' },
                        { icon: 'sitemap', label: 'View Org Chart' },
                        { icon: 'edit', label: 'Update Profile' }
                    ])}
                </div>
            </div>
        `;
    },

    /**
     * Render Contractor Dashboard
     */
    contractor(worker, wr, le, assignment, activities) {
        var completedDeliverables = assignment.deliverables.filter(function(d) { return d.status === 'completed'; }).length;
        
        return `
            <div class="dashboard-grid">
                ${Render.infoCard('Worker Profile', 'user', [
                    { label: 'Full Name', value: worker.name },
                    { label: 'Nationality', value: worker.nationality },
                    { label: 'Certifications', value: worker.certifications.length + ' active' },
                    { label: 'Languages', value: worker.languages.map(function(l) { return l.language; }).join(', ') }
                ], { type: 'worker', label: 'Shared' }, 0.15)}
                
                ${Render.infoCard('Contract Details', 'file-signature', [
                    { label: 'Client', value: le.name },
                    { label: 'Vendor', value: assignment.vendorCompany },
                    { label: 'Contract Type', value: wr.contractType },
                    { label: 'Location', value: wr.workLocation },
                    { label: 'Period', value: Utils.formatDate(wr.startDate) + ' - ' + Utils.formatDate(wr.endDate) },
                    { label: 'Notice', value: wr.noticePeriod }
                ], { type: 'wr', label: 'WR-Specific' }, 0.2)}
                
                ${Render.infoCard('Project Assignment', 'project-diagram', [
                    { label: 'Project', value: assignment.projectAssignment.projectName },
                    { label: 'Role', value: assignment.projectAssignment.role },
                    { label: 'Start', value: Utils.formatDate(assignment.projectAssignment.startDate) },
                    { label: 'End', value: Utils.formatDate(assignment.projectAssignment.endDate) }
                ].concat(assignment.projectManager ? [{ label: 'PM', value: assignment.projectManager.name, link: true }] : []), null, 0.25)}
                
                <div class="card col-4 animate" style="animation-delay: 0.3s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-dollar-sign"></i> Billing Information</span></div>
                    <div class="stats-row" style="grid-template-columns: 1fr;">
                        <div class="stat">
                            <div class="stat-value">${Utils.formatCurrency(assignment.billing.rate.amount, assignment.billing.rate.currency)}</div>
                            <div class="stat-label">${assignment.billing.rateType} Rate</div>
                        </div>
                    </div>
                    <div class="info-list">
                        ${assignment.billing.totalDays !== undefined ? '<div class="info-row"><span class="info-label">Days Worked</span><span class="info-value">' + assignment.billing.totalDays + '</span></div>' : ''}
                        ${assignment.billing.totalBilled ? '<div class="info-row"><span class="info-label">Total Billed</span><span class="info-value">' + Utils.formatCurrency(assignment.billing.totalBilled, assignment.billing.rate.currency) + '</span></div>' : ''}
                        ${assignment.billing.estimatedTotal ? '<div class="info-row"><span class="info-label">Est. Total</span><span class="info-value">' + Utils.formatCurrency(assignment.billing.estimatedTotal, assignment.billing.rate.currency) + '</span></div>' : ''}
                    </div>
                </div>
                
                <div class="card col-8 animate" style="animation-delay: 0.35s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-tasks"></i> Deliverables (${completedDeliverables}/${assignment.deliverables.length} completed)</span></div>
                    ${Render.deliverablesList(assignment.deliverables)}
                </div>
                
                <div class="card col-6 animate" style="animation-delay: 0.4s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-cogs"></i> Skills Profile</span></div>
                    <div class="chart-container"><canvas id="skillsChart"></canvas></div>
                </div>
                
                <div class="card col-6 animate" style="animation-delay: 0.45s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-stream"></i> Recent Activity</span></div>
                    ${Render.activityFeed(activities)}
                </div>
                
                <div class="card col-12 animate" style="animation-delay: 0.5s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-bolt"></i> Quick Actions</span></div>
                    ${Render.quickActions([
                        { icon: 'clock', label: 'Log Time' },
                        { icon: 'upload', label: 'Submit Deliverable' },
                        { icon: 'file-invoice', label: 'Submit Invoice' },
                        { icon: 'file-alt', label: 'View SOW' },
                        { icon: 'edit', label: 'Update Profile' }
                    ])}
                </div>
            </div>
        `;
    },

    /**
     * Render Intern Dashboard
     */
    intern(worker, wr, le, assignment, activities) {
        var avgProgress = Math.round(assignment.learningGoals.reduce(function(sum, g) { return sum + g.progress; }, 0) / assignment.learningGoals.length);
        
        return `
            <div class="dashboard-grid">
                ${Render.infoCard('Intern Profile', 'user', [
                    { label: 'Full Name', value: worker.name },
                    { label: 'Age', value: Utils.calculateAge(worker.dob) + ' years old' },
                    { label: 'University', value: assignment.university },
                    { label: 'Expected Graduation', value: assignment.expectedGraduation },
                    { label: 'Languages', value: worker.languages.map(function(l) { return l.language; }).join(', ') }
                ], { type: 'worker', label: 'Shared' }, 0.15)}
                
                ${Render.infoCard('Internship Details', 'graduation-cap', [
                    { label: 'Program', value: assignment.program.name },
                    { label: 'Cohort', value: assignment.program.cohort },
                    { label: 'Duration', value: assignment.program.duration },
                    { label: 'Period', value: Utils.formatDate(wr.startDate) + ' - ' + Utils.formatDate(wr.endDate) },
                    { label: 'Stipend', value: Utils.formatCurrency(assignment.stipend.amount, assignment.stipend.currency) + '/mo' }
                ], { type: 'wr', label: 'WR-Specific' }, 0.2)}
                
                ${Render.infoCard('Assignment', 'briefcase', [
                    { label: 'Position', value: assignment.position.title },
                    { label: 'Team', value: assignment.position.team },
                    { label: 'Department', value: assignment.position.department },
                    { label: 'Mentor', value: assignment.mentor.name, link: true },
                    { label: 'Supervisor', value: assignment.supervisor.name, link: true }
                ], null, 0.25)}
                
                <div class="card col-6 animate" style="animation-delay: 0.3s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-bullseye"></i> Learning Goals (${avgProgress}% overall)</span></div>
                    ${Render.goalsList(assignment.learningGoals)}
                </div>
                
                <div class="card col-6 animate" style="animation-delay: 0.35s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-star"></i> Evaluations</span></div>
                    <div class="timeline">
                        ${assignment.evaluations.map(function(e, i) {
                            return '<div class="timeline-item ' + (i === 0 ? 'current' : 'completed') + '">' +
                                '<div class="timeline-dot"></div>' +
                                '<div class="timeline-content">' +
                                    '<div class="timeline-title">' + e.period + ': ' + e.rating + '</div>' +
                                    '<div class="timeline-subtitle">' + e.feedback + '</div>' +
                                    '<div class="timeline-date">' + Utils.formatDate(e.date) + '</div>' +
                                '</div></div>';
                        }).join('')}
                    </div>
                </div>
                
                <div class="card col-6 animate" style="animation-delay: 0.4s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-cogs"></i> Skills Development</span></div>
                    <div class="chart-container"><canvas id="skillsChart"></canvas></div>
                </div>
                
                <div class="card col-6 animate" style="animation-delay: 0.45s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-stream"></i> Recent Activity</span></div>
                    ${Render.activityFeed(activities)}
                </div>
                
                <div class="card col-12 animate" style="animation-delay: 0.5s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-bolt"></i> Quick Actions</span></div>
                    ${Render.quickActions([
                        { icon: 'clock', label: 'Log Hours' },
                        { icon: 'book', label: 'Learning Resources' },
                        { icon: 'calendar', label: 'Schedule Mentor Meeting' },
                        { icon: 'tasks', label: 'View Tasks' },
                        { icon: 'edit', label: 'Update Profile' }
                    ])}
                </div>
            </div>
        `;
    },

    /**
     * Render Contingent Worker Dashboard
     */
    contingent(worker, wr, le, assignment, activities) {
        var completedTasks = assignment.currentTasks.filter(function(t) { return t.status === 'completed'; }).length;
        
        return `
            <div class="dashboard-grid">
                ${Render.infoCard('Worker Profile', 'user', [
                    { label: 'Full Name', value: worker.name },
                    { label: 'Nationality', value: worker.nationality },
                    { label: 'Certifications', value: worker.certifications.length + ' active' },
                    { label: 'Languages', value: worker.languages.map(function(l) { return l.language; }).join(', ') }
                ], { type: 'worker', label: 'Shared' }, 0.15)}
                
                ${Render.infoCard('Agency Details', 'building', [
                    { label: 'Agency', value: assignment.agency.name },
                    { label: 'Contact', value: assignment.agency.contactPerson },
                    { label: 'Email', value: assignment.agency.contactEmail, link: true },
                    { label: 'Client', value: le.name },
                    { label: 'Period', value: Utils.formatDate(wr.startDate) + ' - ' + Utils.formatDate(wr.endDate) }
                ], { type: 'wr', label: 'WR-Specific' }, 0.2)}
                
                ${Render.infoCard('Assignment', 'briefcase', [
                    { label: 'Title', value: assignment.assignment.title },
                    { label: 'Team', value: assignment.assignment.team },
                    { label: 'Department', value: assignment.assignment.department },
                    { label: 'Supervisor', value: assignment.supervisor.name, link: true },
                    { label: 'Location', value: wr.workLocation }
                ], null, 0.25)}
                
                <div class="card col-4 animate" style="animation-delay: 0.3s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-dollar-sign"></i> Billing</span></div>
                    <div class="stats-row" style="grid-template-columns: 1fr;">
                        <div class="stat">
                            <div class="stat-value">${Utils.formatCurrency(assignment.billing.rate.amount, assignment.billing.rate.currency)}</div>
                            <div class="stat-label">${assignment.billing.rateType}</div>
                        </div>
                    </div>
                    <div class="info-list" style="margin-top: var(--space-md);">
                        <div class="info-row"><span class="info-label">Billed To</span><span class="info-value">${assignment.billing.billedTo}</span></div>
                        <div class="info-row"><span class="info-label">Agency Markup</span><span class="info-value">${assignment.billing.markup}</span></div>
                    </div>
                </div>
                
                <div class="card col-8 animate" style="animation-delay: 0.35s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-tasks"></i> Current Tasks (${completedTasks}/${assignment.currentTasks.length})</span></div>
                    <div class="deliverables-list">
                        ${assignment.currentTasks.map(function(t) {
                            return '<div class="deliverable">' +
                                '<div class="deliverable-icon ' + t.status + '">' +
                                    '<i class="fas fa-' + (t.status === 'completed' ? 'check' : t.status === 'in-progress' ? 'spinner' : 'clock') + '"></i>' +
                                '</div>' +
                                '<div class="deliverable-info">' +
                                    '<div class="deliverable-name">' + t.name + '</div>' +
                                    '<div class="deliverable-meta">Priority: ' + t.priority + ' • Status: ' + t.status + '</div>' +
                                '</div></div>';
                        }).join('')}
                    </div>
                </div>
                
                <div class="card col-4 animate" style="animation-delay: 0.4s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-key"></i> System Access</span></div>
                    <div class="skills-tags">
                        ${assignment.accessSystems.map(function(s) { return '<span class="tag">' + s + '</span>'; }).join('')}
                    </div>
                </div>
                
                <div class="card col-4 animate" style="animation-delay: 0.45s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-cogs"></i> Skills Profile</span></div>
                    <div class="chart-container"><canvas id="skillsChart"></canvas></div>
                </div>
                
                <div class="card col-4 animate" style="animation-delay: 0.5s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-stream"></i> Recent Activity</span></div>
                    ${Render.activityFeed(activities)}
                </div>
                
                <div class="card col-12 animate" style="animation-delay: 0.55s">
                    <div class="card-header"><span class="card-title"><i class="fas fa-bolt"></i> Quick Actions</span></div>
                    ${Render.quickActions([
                        { icon: 'clock', label: 'Log Time' },
                        { icon: 'tasks', label: 'Update Tasks' },
                        { icon: 'comments', label: 'Contact Agency' },
                        { icon: 'file-alt', label: 'View Contract' },
                        { icon: 'edit', label: 'Update Profile' }
                    ])}
                </div>
            </div>
        `;
    }
};
