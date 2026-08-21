import { Routes, Route } from 'react-router-dom'
import DisputeForm from '../components/disputes/DisputeForm'
import DisputeMessages from '../components/disputes/DisputeMessages'
import AdminDashboard from '../components/admin/AdminDashboard'
import AdminDisputes from '../components/admin/AdminDisputes'
import AdminDisputeDtails from '../components/admin/AdminDisputeDetails'
function PlaceholderPage({ title, description }) {
  return (
    <section className="page-placeholder">
      <div className="page-placeholder__content">
        <p className="page-placeholder__eyebrow">
          Escrow ET
        </p>

        <h2>{title}</h2>

        <p>{description}</p>
      </div>
    </section>
  )
}

function AppRoutes({sidebarOpen, toggleSidebar}) {
  return (
    <Routes>
      <Route
        path="/"
        element={
          <PlaceholderPage
            title="Merchant Dashboard"
            description="Dashboard content will be added next."
          />
        }
      />

      <Route
        path="/transactions"
        element={
          <PlaceholderPage
            title="Transactions"
            description="Transaction tracking will be implemented by the escrow pipeline team."
          />
        }
      />

      <Route
        path="/payment-links"
        element={
          <PlaceholderPage
            title="Payment Links"
            description="Payment link creation will be implemented by the escrow pipeline team."
          />
        }
      />

      <Route
        path="/disputes"
        element={
          <DisputeForm
            title="Disputes"
            description="Dispute management will be implemented by the dispute resolution team."
          />
        }
      />
      <Route 
        path='/disputes/messages'
        element = {
        <DisputeMessages 
            title = 'Disputes-Messages'
        />}
       />
       <Route 
          path = '/admin' 
          element = {
          <AdminDashboard
            title = 'Admin-Dashboard'
            sidebarOpen = {sidebarOpen}
            toggleSidebar = {toggleSidebar} />
        }
       />
       <Route 
          path = '/admin/disputes'
          element = {
            <AdminDisputes 
            sidebarOpen = {sidebarOpen}
            toggleSidebar = {toggleSidebar} />
          } 
        />
        <Route 
          path='/admin/disputes/:disputeId'
          element = {<AdminDisputeDtails />}
        />
      <Route
        path="/settings/developer"
        element={
          <PlaceholderPage
            title="Developer Settings"
            description="Developer integration settings will be implemented next."
          />
        }
      />

      <Route
        path="*"
        element={
          <PlaceholderPage
            title="Page Not Found"
            description="The page you are looking for does not exist."
          />
        }
      />
    </Routes>
  )
}

export default AppRoutes