import { useNavigate } from "react-router-dom";
import {FiMenu, FiBell, FiAlertTriangle, FiChevronRight} from 'react-icons/fi';
import './AdminDashboard.css';
import {useTheme} from '../../context/ThemeContext';
import React from "react";
function AdminDashboard({sidebarOpen, toggleSidebar}){
    const navigate = useNavigate();
    const {theme, toggleTheme} = useTheme();
    const stats = [
        {
            title: 'Total Transactions',
            value: '10,245',
        },
        {
            title: 'Total Locked',
            value: '3,500 ETB',
        },
        {
            title: 'Total Released',
            value: '8,950 ETB',
        },
        {
            title: 'Open Disputes',
            value: '12',
        },
    ];
    const recentDisputes = [
        {
            id: 'ET-10194',
            title: 'Yirgacheffe Coffee',
            amount: '500 ETB',
            status: 'Disputed',
        },
        {
            id: 'ET-10191',
            title: 'Laptop Purchase',
            amount: '8,500 ETB',
            status: 'Under Review',
        },
        {
            id: 'ET-10192',
            title: 'Website Design',
            amount: '3,000 ETB',
            status: 'Disputed',
        },
    ];
    return(
        <div className="admin-dashboard">
            <header className="admin-header">
                <div className="admin-header-left">
                    <button className="menu-button" onClick={toggleSidebar} aria-label={sidebarOpen ? 'Close menu' : 'Open menu'} aria-expanded={sidebarOpen}><FiMenu /></button>
                    <h1>Admin Dashboard</h1>
                </div>
                <div className="admin-header-right">
                    <button className="admin-header-button" onClick={toggleTheme} aria-label={theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'} title={theme === 'dark'? 'Switch to light mode': 'Switch to dark mode'}>
                        {theme === 'dark'? '☀': '☾'}
                    </button>
                    <button className="notification-button" aria-label="Notifications"><FiBell /></button>
                <button className="admin-header-button" aria-label="Profile">👤</button>
                </div>
            </header>
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
                    {recentDisputes.map((dispute) => (
                        <button className="dispute-row" key={dispute.id} onClick={() => navigate(`/admin/disputes/${dispute.id}`)}>
                            <div className="dispute-row-icon"><FiAlertTriangle /></div>
                            <div className="dispute-row-info">
                                <span className="dispute-id">{dispute.id}</span>
                                <span className="dispute-title">{dispute.title}</span>
                            </div>
                            <span className="dispute-amount">{dispute.amount}</span>
                            <span className={`dispute-status ${dispute.status === 'Under Review'? 'under-review' : 'disputed'}`}>{dispute.status}</span>
                            <span className="dispute-arrow"><FiChevronRight /></span>
                        </button>
                    ))}
                </div>
            </section>
        </div>
    )
}
export default AdminDashboard;