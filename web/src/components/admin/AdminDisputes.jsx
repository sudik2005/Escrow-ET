import { useNavigate } from "react-router-dom";
import './AdminDisputes.css';
function AdminDisputes(){
    const navigate = useNavigate();
    const disputes = [
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
        <div className="admin-disputes">
            <h1>Disputes</h1>
            <div className="admin-disputes-list">
                {disputes.map((dispute) => (
                    <button key={dispute.id} className="admin-dispute-item" onClick={() => navigate(`/admin/disputes/${dispute.id}`)}>
                        <div>
                            <strong>{dispute.id}</strong>
                            <span>{dispute.title}</span>
                        </div>
                        <span>{dispute.amount}</span>
                        <span className={dispute.status === 'Under Review'? 'status-under-review': 'status-disputed'}>{dispute.status}</span>
                    </button>
                ))}
            </div>
        </div>
    )
}
export default AdminDisputes;