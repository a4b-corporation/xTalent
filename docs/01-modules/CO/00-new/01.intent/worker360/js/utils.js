/**
 * xTalent Worker 360 - Utility Functions
 */

const Utils = {
    /**
     * Format date to readable string
     */
    formatDate(dateStr) {
        if (!dateStr) return 'N/A';
        const date = new Date(dateStr);
        return date.toLocaleDateString('en-GB', { 
            day: '2-digit', 
            month: 'short', 
            year: 'numeric' 
        });
    },

    /**
     * Calculate age from date of birth
     */
    calculateAge(dob) {
        const today = new Date();
        const birthDate = new Date(dob);
        let age = today.getFullYear() - birthDate.getFullYear();
        const m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        return age;
    },

    /**
     * Calculate tenure from start date
     */
    calculateTenure(startDate) {
        const start = new Date(startDate);
        const now = new Date();
        let totalMonths = (now.getFullYear() - start.getFullYear()) * 12 + 
                          (now.getMonth() - start.getMonth());
        
        if (now.getDate() < start.getDate()) {
            totalMonths--;
        }
        
        const years = Math.floor(totalMonths / 12);
        const months = totalMonths % 12;
        
        if (years > 0) {
            return `${years}yr ${months}mo`;
        }
        return `${months}mo`;
    },

    /**
     * Get initials from name
     */
    getInitials(name) {
        if (!name) return '??';
        return name
            .split(' ')
            .map(n => n[0])
            .join('')
            .substring(0, 2)
            .toUpperCase();
    },

    /**
     * Get WR type label
     */
    getWRTypeLabel(wrType) {
        const labels = {
            'employment': 'Employment',
            'contract': 'Contract',
            'contingent': 'Contingent',
            'internship': 'Internship'
        };
        return labels[wrType] || wrType;
    },

    /**
     * Get WR subtype label
     */
    getWRSubTypeLabel(subType) {
        const labels = {
            'full-time': 'Full-time',
            'part-time': 'Part-time',
            'secondment': 'Secondment',
            'independent-contractor': 'Independent',
            'consultant': 'Consultant',
            'agency-worker': 'Agency',
            'student-intern': 'Student'
        };
        return labels[subType] || subType;
    },

    /**
     * Format currency
     */
    formatCurrency(amount, currency) {
        if (currency === 'VND') {
            return new Intl.NumberFormat('vi-VN').format(amount) + ' ₫';
        } else if (currency === 'USD') {
            return new Intl.NumberFormat('en-US', { 
                style: 'currency', 
                currency: 'USD' 
            }).format(amount);
        } else if (currency === 'SGD') {
            return new Intl.NumberFormat('en-SG', { 
                style: 'currency', 
                currency: 'SGD' 
            }).format(amount);
        }
        return `${amount} ${currency}`;
    },

    /**
     * Create HTML element from string
     */
    createElement(html) {
        const template = document.createElement('template');
        template.innerHTML = html.trim();
        return template.content.firstChild;
    },

    /**
     * Escape HTML
     */
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    },

    /**
     * Debounce function
     */
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
};

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = Utils;
}
