import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { FiArrowLeft, FiAlertTriangle, FiClock, FiCheckCircle, FiRefreshCw } from "react-icons/fi";
import './AdminDisputeDetails.css'
import { useAuth } from '../../context/AuthContext';
import * as api from '../../lib/api';
import { fmtEtb } from '../../lib/status';

function AdminDisputeDtails() {
    const navigate = useNavigate();
    const { disputeId } = useParams();
    const { token } = useAuth();
    const [dispute, setDispute] = useState(null);
    const [error, setError] = useState(null);
    const [busy, setBusy] = useState(false);

    useEffect(() => {
        if (!token || !disputeId) return;
        api.getDispute(token, disputeId)
            .then(setDispute)
            .catch((err) => setError(err.message || 'Dispute not found.'));
    }, [token, disputeId]);

    async function run(action) {
        setBusy(true);
        setError(null);
        try {
            const next =
                action === 'review'
                    ? await api.reviewDispute(token, disputeId)
                    : await api.resolveDispute(token, disputeId, action);
            setDispute(next);
        } catch (err) {
            setError(err.message || 'Action failed.');
        } finally {
            setBusy(false);
        }
    }

    if (error && !dispute) {
        return (
            <div className="admin-dispute-details">
                <button className="back-button" onClick={() => navigate('/admin/disputes')}>
                    <FiArrowLeft />
                    Back to Disputes
                </button>
                <h1>Dispute Not Found</h1>
                <p>{error}</p>
            </div>
        );
    }

    if (!dispute) {
        return (
            <div className="flex justify-center py-12">
                <div className="w-8 h-8 border-2 border-[var(--brand)] border-t-transparent rounded-full animate-spin" />
            </div>
        );
    }

    const resolved = dispute.status === 'RESOLVED_RELEASED' || dispute.status === 'RESOLVED_REFUNDED';

    return (
        <div className="admin-dispute-details">
            <button className="back-button" onClick={() => navigate('/admin/disputes')}>
                <FiArrowLeft /> Back to Disputes
            </button>
            <div className="admin-dispute-details-header">
                <div>
                    <p className="admin-dispute-details-eyebrow">Dispute {dispute.id}</p>
                    <h1>{dispute.item_name}</h1>
                </div>
                <span className={`dispute-status ${dispute.status.toLowerCase().replaceAll('_', '-')}`}>
                    {dispute.status === 'UNDER_REVIEW' ? <FiClock /> : <FiAlertTriangle />}
                    {dispute.status}
                </span>
            </div>
            <section className="dispute-details-card">
                <h2>Transaction Information</h2>
                <div className="details-grid">
                    <div className="detail-item">
                        <span>Transaction ID</span>
                        <strong>{dispute.escrow_id}</strong>
                    </div>
                    <div className="detail-item">
                        <span>Amount</span>
                        <strong>{fmtEtb(dispute.amount)}</strong>
                    </div>
                    <div className="detail-item">
                        <span>Buyer</span>
                        <strong>{dispute.buyer_username || dispute.buyer_phone}</strong>
                    </div>
                    <div className="detail-item">
                        <span>Seller</span>
                        <strong>{dispute.seller_username || dispute.seller_phone}</strong>
                    </div>
                </div>
            </section>
            <section className="dispute-details-card">
                <h2>Reason for Dispute</h2>
                <p className="dispute-reason">{dispute.reason}</p>
            </section>
            {error && <p className="text-sm text-red-500">{error}</p>}
            <section className="dispute-details-card">
                <h2>Admin Actions</h2>
                <div className="admin-actions">
                    <button
                        className="admin-action-button review-button"
                        onClick={() => run('review')}
                        disabled={busy || resolved || dispute.status === 'UNDER_REVIEW'}
                    >
                        <FiClock />
                        Mark Under Review
                    </button>
                    <button
                        className="admin-action-button release-button"
                        onClick={() => run('release')}
                        disabled={busy || resolved}
                    >
                        <FiCheckCircle />
                        Release Funds
                    </button>
                    <button
                        className="admin-action-button refund-button"
                        onClick={() => run('refund')}
                        disabled={busy || resolved}
                    >
                        <FiRefreshCw />
                        Refund Buyer
                    </button>
                </div>
            </section>
        </div>
    )
}

export default AdminDisputeDtails;
