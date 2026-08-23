import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import './AdminDisputes.css';
import { useAuth } from '../../context/AuthContext';
import * as api from '../../lib/api';
import { fmtEtb } from '../../lib/status';

function AdminDisputes() {
    const navigate = useNavigate();
    const { token } = useAuth();
    const [disputes, setDisputes] = useState([]);
    const [error, setError] = useState(null);

    useEffect(() => {
        if (!token) return;
        api.listDisputes(token)
            .then((data) => setDisputes(Array.isArray(data) ? data : []))
            .catch((err) => setError(err.message || 'Could not load disputes.'));
    }, [token]);

    return (
        <div className="admin-disputes">
            <h1>Disputes</h1>
            {error && <p className="text-sm text-red-500">{error}</p>}
            <div className="admin-disputes-list">
                {disputes.length === 0 && !error && (
                    <p className="text-sm text-[var(--text-muted)]">No disputes yet.</p>
                )}
                {disputes.map((dispute) => (
                    <button
                        key={dispute.id}
                        className="admin-dispute-item"
                        onClick={() => navigate(`/admin/disputes/${dispute.id}`)}
                    >
                        <div>
                            <strong>{dispute.item_name}</strong>
                            <span>{dispute.id}</span>
                        </div>
                        <span>{fmtEtb(dispute.amount)}</span>
                        <span className={dispute.status === 'UNDER_REVIEW' ? 'status-under-review' : 'status-disputed'}>
                            {dispute.status}
                        </span>
                    </button>
                ))}
            </div>
        </div>
    )
}

export default AdminDisputes;
