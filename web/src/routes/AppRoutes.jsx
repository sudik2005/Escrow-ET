import { Navigate, Routes, Route } from 'react-router-dom';

import AppLayout from '../components/layout/AppLayout';

import ProtectedRoute from '../components/auth/ProtectedRoute';

import LandingPage from '../pages/LandingPage';
import LoginPage from '../pages/LoginPage';
import RegisterPage from '../pages/RegisterPage';
import DeveloperSettings from '../pages/DeveloperSettings';
import DeveloperDocs from '../pages/DeveloperDocs';
import CreatePaymentLink from '../pages/CreatePaymentLink';
import TransactionTracking from '../pages/TransactionTracking';
import Checkout from '../pages/Checkout';
import Payment from '../pages/Payment';
import PaymentSuccess from '../pages/PaymentSuccess';
import MerchantDashboard from '../pages/MerchantDashboard';
import QRCodeView from '../pages/QRCodeView';
import DeliveryVerified from '../pages/DeliveryVerified';
import DisputeForm from '../components/disputes/DisputeForm';
import DisputeMessages from '../components/disputes/DisputeMessages';
import AdminDashboard from '../components/admin/AdminDashboard';
import AdminDisputes from '../components/admin/AdminDisputes';
import AdminDisputeDtails from '../components/admin/AdminDisputeDetails';


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
  );
}


function DashboardLayout({ children }) {
  return (
    <AppLayout>
      {children}
    </AppLayout>
  );
}


function AppRoutes() {
  return (
    <Routes>

      {/* =====================================================
          PUBLIC ROUTES
      ====================================================== */}

      <Route
        path="/"
        element={<LandingPage />}
      />

      {/* Auth */}
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route path="/signup" element={<Navigate to="/register" replace />} />

      {/* Buyer-facing routes (public — buyer clicks a shared link) */}
      <Route path="/checkout/:contractId" element={<Checkout />} />
      <Route path="/checkout" element={<Checkout />} />
      <Route path="/payment/:contractId" element={<Payment />} />
      <Route path="/payment" element={<Payment />} />

      <Route
        path="/payment-success"
        element={<PaymentSuccess />}
      />

      <Route path="/qr-code" element={<QRCodeView />} />
      <Route path="/delivery-verified" element={<DeliveryVerified />} />


      {/* =====================================================
          PROTECTED MERCHANT ROUTES
      ====================================================== */}
      <Route element={<ProtectedRoute />}>

        <Route
          path="/dashboard"
          element={
            <DashboardLayout>
              <MerchantDashboard />
            </DashboardLayout>
          }
        />

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

        <Route
          path="/disputes"
          element={
            <DashboardLayout>
              <DisputeForm />
            </DashboardLayout>
          }
        />

        <Route
          path="/disputes/messages"
          element={
            <DashboardLayout>
              <DisputeMessages />
            </DashboardLayout>
          }
        />

        <Route
          path="/admin"
          element={
            <DashboardLayout>
              <AdminDashboard />
            </DashboardLayout>
          }
        />

        <Route
          path="/admin/disputes"
          element={
            <DashboardLayout>
              <AdminDisputes />
            </DashboardLayout>
          }
        />

        <Route
          path="/admin/disputes/:disputeId"
          element={
            <DashboardLayout>
              <AdminDisputeDtails />
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

      </Route>



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
  );
}

export default AppRoutes;
