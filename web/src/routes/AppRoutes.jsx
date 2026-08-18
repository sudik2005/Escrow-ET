import { Routes, Route } from 'react-router-dom'
import AppLayout from '../components/layout/AppLayout'
import LandingPage from '../pages/LandingPage'

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

function DashboardLayout({ children }) {
  return <AppLayout>{children}</AppLayout>
}

function AppRoutes() {
  return (
    <Routes>
      {/* =====================================================
          PUBLIC LANDING PAGE
      ====================================================== */}
      <Route
        path="/"
        element={<LandingPage />}
      />

      {/* =====================================================
          MERCHANT APPLICATION
      ====================================================== */}
      <Route
        path="/dashboard"
        element={
          <DashboardLayout>
            <PlaceholderPage
              title="Dashboard"
              description="The dashboard will be implemented by the escrow pipeline team."
            />
          </DashboardLayout>
        }
      /> 
      <Route
        path="/transactions"
        element={
          <DashboardLayout>
            <PlaceholderPage
              title="Transactions"
              description="Transaction tracking will be implemented by the escrow pipeline team."
            />
          </DashboardLayout>
        }
      />

      <Route
        path="/payment-links"
        element={
          <DashboardLayout>
            <PlaceholderPage
              title="Payment Links"
              description="Payment link creation will be implemented by the escrow pipeline team."
            />
          </DashboardLayout>
        }
      />

      <Route
        path="/disputes"
        element={
          <DashboardLayout>
            <PlaceholderPage
              title="Disputes"
              description="Dispute management will be implemented by the dispute resolution team."
            />
          </DashboardLayout>
        }
      />

      <Route
        path="/settings/developer"
        element={
          <DashboardLayout>
            <PlaceholderPage
              title="Developer Settings"
              description="Developer integration settings will be implemented next."
            />
          </DashboardLayout>
        }
      />

      {/* =====================================================
          404
      ====================================================== */}
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