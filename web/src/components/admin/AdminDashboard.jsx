import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { FiAlertTriangle, FiChevronRight } from 'react-icons/fi';
import './AdminDashboard.css';
import { useAuth } from '../../context/AuthContext';
import * as api from '../../lib/api';
import { fmtEtb } from '../../lib/status';

function AdminDashboard() {
    const navigate = useNavigate();
    const { token } = useAuth();
    const [overview, setOverview] = useState(null);
    const [disputes, setDisputes] = useState([]);
    const [error, setError] = useState(null);

    useEffect(() => {
        if (!token) return;
        Promise.all([api.adminOverview(token), api.listDisputes(token)])
            .then(([stats, list]) => {
                setOverview(stats);
                setDisputes(Array.isArray(list) ? list.slice(0, 8) : []);
            })
            .catch((err) => setError(err.message || 'Could not load admin data.'));
    }, [token]);

    const stats = [
        {
            title: 'Total Transactions',
            value: overview ? String(overview.total_transactions) : '—',
        },
        {
            title: 'Total Locked',
            value: overview ? fmtEtb(overview.total_locked) : '—',
        },
        {
            title: 'Total Released',
            value: overview ? fmtEtb(overview.total_released) : '—',
        },
        {
            title: 'Open Disputes',
            value: overview ? String(overview.open_disputes) : '—',
        },
    ];

    return (
        <div className="admin-dashboard">
            <header className="admin-header">
                <div className="admin-header-left">
                    <h1>Admin Dashboard</h1>
                </div>
            </header>
            {error && <p className="text-sm text-red-500 px-4">{error}</p>}
            <section className="admin-stats">
                {stats.map((stat) => (
                    <article className="stat-card" key={stat.title}>
                        <p className="stat-card-title">{stat.title}</p>
                        <h2 className="stat-card-value">{stat.value}</h2>
                    </article>
                ))}
            </section>
            <section className="recent-disputes">
                <div className="section-header">
                    <h2>Recent Disputes</h2>
                    <button className="view-all-button" onClick={() => navigate('/admin/disputes')}>View all</button>
                </div>
                <div className="dispute-list">
                    {disputes.length === 0 && (
                        <p className="text-sm text-[var(--text-muted)] py-6">No disputes yet.</p>
                    )}
                    {disputes.map((dispute) => (
                        <button className="dispute-row" key={dispute.id} onClick={() => navigate(`/admin/disputes/${dispute.id}`)}>
                            <div className="dispute-row-icon"><FiAlertTriangle /></div>
                            <div className="dispute-row-info">
                                <span className="dispute-id">{dispute.id}</span>
                                <span className="dispute-title">{dispute.item_name}</span>
                            </div>
                            <span className="dispute-amount">{fmtEtb(dispute.amount)}</span>
                            <span className={`dispute-status ${dispute.status === 'UNDER_REVIEW' ? 'under-review' : 'disputed'}`}>
                                {dispute.status}
                            </span>
                            <span className="dispute-arrow"><FiChevronRight /></span>
                        </button>
                    ))}
                </div>
            </section>
        </div>
    )
}

export default AdminDashboard;
