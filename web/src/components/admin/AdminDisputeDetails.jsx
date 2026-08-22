import { useNavigate, useParams } from "react-router-dom";
import { FiArrowLeft, FiAlertTriangle, FiClock, FiCheckCircle, FiRefreshCw } from "react-icons/fi";
import { useState } from "react";
import './AdminDisputeDetails.css'
function AdminDisputeDtails(){
    const navigate = useNavigate();
    const {disputeId} = useParams();
    const disputes = {
  'ET-10194': {
    id: 'ET-10194',
    title: 'Yirgacheffe Coffee',
    amount: '500 ETB',
    status: 'Disputed',
    buyer: 'Abebe Kebede',
    seller: 'Yirgacheffe Coffee Store',
    reason:
      'The product I received does not match the description provided by the seller.',
  },

  'ET-10191': {
    id: 'ET-10191',
    title: 'Laptop Purchase',
    amount: '8,500 ETB',
    status: 'Under Review',
    buyer: 'Dawit Alemu',
    seller: 'Tech Store Ethiopia',
    reason:
      'The laptop delivered to me has different specifications from the ones listed in the transaction.',
  },

  'ET-10192': {
    id: 'ET-10192',
    title: 'Website Design',
    amount: '3,000 ETB',
    status: 'Disputed',
    buyer: 'Sara Mohammed',
    seller: 'Digital Solutions',
    reason:
      'The delivered website does not include the features and functionality agreed upon in the transaction.',
  },
};
const dispute = disputes[disputeId]
const [status, setStatus] = useState(dispute?.status || 'Disputed');
if(!dispute){
    return(
        <div className="admin-dispute-details">
            <button className="back-button" onClick={() => navigate('/admin/disputes')}>
                <FiArrowLeft />
                Back to Disputes
            </button>
            <h1>Dispute Not Found</h1>
            <p>The dispute you're looking for doesn't exist.</p>
        </div>
    )
}
    return(
        <div className="admin-dispute-details">
            <button className="back-button" onClick={() => navigate('/admin/disputes')}>
                <FiArrowLeft /> Back to Disputes
            </button>
            <div className="admin-dispute-details-header">
                <div>
                    <p className="admin-dispute-details-eyebrow">Dispute {dispute.id}</p>
                    <h1>{dispute.title}</h1>
                </div>
                <span className={`dispute-status ${status.toLocaleLowerCase().replace(' ', '-')}`}>
                    {status === 'Disputed' && <FiAlertTriangle />}
                    {status === 'Under Review' && <FiClock />}
                    {status === 'Resolved' && <FiCheckCircle />}
                    {status}
                </span>
            </div>
            <section className="dispute-details-card">
                <h2>Transaction Information</h2>
                <div className="details-grid">
                    <div className="detail-item">
                        <span>Transaction ID</span>
                        <strong>{dispute.id}</strong>
                    </div>
                    <div className="detail-item">
                        <span>Amount</span>
                        <strong>{dispute.amount}</strong>
                    </div>
                    <div className="detail-item">
                        <span>Buyer</span>
                        <strong>{dispute.buyer}</strong>
                    </div>
                    <div className="detail-item">
                        <span>Seller</span>
                        <strong>{dispute.seller}</strong>
                    </div>
                </div>
            </section>
            <section className="dispute-details-card">
                <h2>Reason for Dispute</h2>
                <p className="dispute-reason">{dispute.reason}</p>
            </section>
            <section className="dispute-details-card">
                <h2>Admin Actions</h2>
                <div className="admin-actions">
                    <button className="admin-action-button review-button" onClick={() => setStatus('Under Review')} disabled = {status === 'Under Review'}>
                        <FiClock />
                        Mark Under Review
                    </button>
                    <button className="admin-action-button release-button" onClick={() => setStatus('Resolved')} disabled = {status === 'Resolved'}>
                        <FiCheckCircle />
                        Release Funds
                    </button>
                    <button className="admin-action-button refund-button" onClick={() => setStatus('Resolved')} disabled = {status === 'Resolved'}>
                        <FiRefreshCw />
                        Refund Buyer
                    </button>
                </div>
            </section>
            </div>
    )
}
export default AdminDisputeDtails;