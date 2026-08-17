import { Routes, Route } from 'react-router-dom'

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

function AppRoutes() {
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
          <PlaceholderPage
            title="Disputes"
            description="Dispute management will be implemented by the dispute resolution team."
          />
        }
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