import { Routes, Route } from 'react-router-dom'
import AppLayout from '../components/layout/AppLayout'
import LandingPage from '../pages/LandingPage'
import DeveloperSettings from '../pages/DeveloperSettings'
import DeveloperDocs from '../pages/DeveloperDocs'
import CreatePaymentLink from '../pages/CreatePaymentLink'
import TransactionTracking from '../pages/TransactionTracking'
import Checkout from '../pages/Checkout'
import Payment from '../pages/Payment'
import PaymentSuccess from '../pages/PaymentSuccess'
import MerchantDashboard from '../pages/MerchantDashboard'

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
      <Route
        path="/"
        element={<LandingPage />}
      />

      <Route
        path="/dashboard"
        element={
          <DashboardLayout>
            <MerchantDashboard />
          </DashboardLayout>
        }
      />

      {/* Merchant-facing: wrapped in the dashboard shell (sidebar + header) */}
      <Route
        path="/transactions"
        element={
          <DashboardLayout>
            <TransactionTracking />
          </DashboardLayout>
        }
      />

      <Route
        path="/payment-links"
        element={
          <DashboardLayout>
            <CreatePaymentLink />
          </DashboardLayout>
        }
      />

      {/* Buyer-facing: standalone, no merchant sidebar */}
      <Route path="/checkout" element={<Checkout />} />
      <Route path="/payment" element={<Payment />} />
      <Route path="/payment-success" element={<PaymentSuccess />} />

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
            <DeveloperSettings />
          </DashboardLayout>
        }
      />

      <Route
        path="/docs"
        element={
          <DashboardLayout>
            <DeveloperDocs />
          </DashboardLayout>
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