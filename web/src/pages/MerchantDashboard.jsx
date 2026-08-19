import "./MerchantDashboard.css";

const summaryCards = [
  {
    title: "Total Balance",
    value: "12,450 ETB",
    icon: "account_balance_wallet",
    variant: "primary",
  },
  {
    title: "Locked Funds",
    value: "3,500 ETB",
    icon: "lock",
    variant: "secondary",
  },
  {
    title: "Total Released",
    value: "8,950 ETB",
    icon: "check_circle",
    variant: "primary",
  },
  {
    title: "Total Transactions",
    value: "24",
    icon: "receipt_long",
    variant: "neutral",
  },
];

const transactions = [
  {
    id: "ET-10294",
    title: "Yirgacheffe Coffee",
    buyer: "Buno Coffee",
    amount: "500 ETB",
    status: "Locked",
    date: "12 Aug 2026, 10:30 AM",
    icon: "shopping_bag",
    variant: "locked",
  },
  {
    id: "ET-10093",
    title: "Shoes Order",
    buyer: "Abebe",
    amount: "1,200 ETB",
    status: "Released",
    date: "11 Aug 2026, 10:30 AM",
    icon: "shopping_bag",
    variant: "released",
  },
  {
    id: "ET-10292",
    title: "Website Design",
    buyer: "Kebede",
    amount: "3,000 ETB",
    status: "Disputed",
    date: "12 Aug 2026, 10:30 AM",
    icon: "warning",
    variant: "disputed",
  },
];

const paymentLinks = [
  {
    title: "Coffee Beans",
    url: "escrow-et.com/pay/lk-29x",
    amount: "500 ETB",
    date: "12 Aug",
  },
];

const disputes = [
  {
    id: "ET-10292",
    title: "Website Design",
    amount: "3,000 ETB",
    status: "Open",
  },
];

function Icon({ children, className = "" }) {
  return (
    <span className={`material-symbols-outlined ${className}`}>
      {children}
    </span>
  );
}

function SummaryCard({ card }) {
  return (
    <article className={`summary-card ${card.variant}`}>
      <div className="summary-icon">
        <Icon>{card.icon}</Icon>
      </div>

      <div className="summary-card-info">
        <p className="summary-title">{card.title}</p>
        <p className="summary-value">{card.value}</p>
      </div>
    </article>
  );
}

function StatusBadge({ status, variant }) {
  return (
    <span className={`status-badge ${variant}`}>
      <span className="status-dot" />
      {status}
    </span>
  );
}

function TransactionsTable() {
  return (
    <section className="dashboard-section transactions-section">
      <div className="section-header">
        <div>
          <h2>Recent Transactions</h2>
          <p>Latest payment activity across your account</p>
        </div>

        <a href="/transactions" className="section-link">
          View all
          <Icon>arrow_forward</Icon>
        </a>
      </div>

      <div className="transactions-table-wrapper">
        <table className="transactions-table">
          <thead>
            <tr>
              <th className="type-column">Type</th>
              <th>ID</th>
              <th>Details</th>
              <th className="amount-column">Amount</th>
              <th className="status-column">Status</th>
              <th className="date-column">Date</th>
              <th className="action-column" />
            </tr>
          </thead>

          <tbody>
            {transactions.map((transaction) => (
              <tr key={transaction.id}>
                <td className="type-column">
                  <div className={`transaction-icon ${transaction.variant}`}>
                    <Icon>{transaction.icon}</Icon>
                  </div>
                </td>

                <td>
                  <span className="transaction-id">
                    {transaction.id}
                  </span>
                </td>

                <td>
                  <p className="transaction-title">
                    {transaction.title}
                  </p>

                  <p className="transaction-buyer">
                    Buyer: {transaction.buyer}
                  </p>
                </td>

                <td className="amount-column transaction-amount">
                  {transaction.amount}
                </td>

                <td className="status-column">
                  <StatusBadge
                    status={transaction.status}
                    variant={transaction.variant}
                  />
                </td>

                <td className="date-column transaction-date">
                  {transaction.date}
                </td>

                <td className="transaction-action">
                  <button
                    type="button"
                    aria-label={`View ${transaction.id}`}
                    title={`View ${transaction.id}`}
                  >
                    <Icon>chevron_right</Icon>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}

function PaymentLinks() {
  return (
    <section className="dashboard-section bottom-section-card">
      <div className="section-header">
        <div>
          <h2>Recent Payment Links</h2>
          <p>Your latest generated payment links</p>
        </div>

        <a href="/payment-links" className="section-link">
          View all
          <Icon>arrow_forward</Icon>
        </a>
      </div>

      <div className="bottom-card-content">
        {paymentLinks.map((paymentLink) => (
          <div
            className="payment-link-item"
            key={paymentLink.url}
          >
            <div className="payment-link-information">
              <div className="payment-link-icon">
                <Icon>link</Icon>
              </div>

              <div className="payment-link-details">
                <p className="payment-link-title">
                  {paymentLink.title}
                </p>

                <p className="payment-link-url">
                  {paymentLink.url}
                </p>
              </div>
            </div>

            <div className="payment-link-value">
              <strong>{paymentLink.amount}</strong>
              <span>{paymentLink.date}</span>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

function Disputes() {
  return (
    <section className="dashboard-section bottom-section-card">
      <div className="section-header">
        <div>
          <h2>Disputes</h2>
          <p>Transactions requiring your attention</p>
        </div>

        <a href="/disputes" className="section-link">
          View all
          <Icon>arrow_forward</Icon>
        </a>
      </div>

      <div className="bottom-card-content">
        {disputes.map((dispute) => (
          <div
            className="dispute-item"
            key={dispute.id}
          >
            <div className="dispute-information">
              <div className="dispute-icon">
                <Icon>gavel</Icon>
              </div>

              <div>
                <p className="dispute-id">
                  {dispute.id}
                </p>

                <p className="dispute-title">
                  {dispute.title}
                </p>
              </div>
            </div>

            <div className="dispute-value">
              <strong>{dispute.amount}</strong>

              <button type="button">
                {dispute.status}
                <Icon>arrow_forward</Icon>
              </button>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="dashboard-footer">
      <p>Copyright © 2024 Escrow ET</p>

      <div>
        <a href="#">Privacy Policy</a>
        <a href="#">Terms of Service</a>
        <a href="#">Contact Support</a>
        <a href="#">Security Guide</a>
      </div>
    </footer>
  );
}

export default function MerchantDashboard() {
  return (
    <div className="merchant-dashboard">
      <div className="dashboard-content">

        <div className="dashboard-heading">
          <div>
            <p className="dashboard-eyebrow">
              Account overview
            </p>

            <h1 className="dashboard-greeting">
              Hello, Bereket <span>👋</span>
            </h1>

            <p className="dashboard-subtitle">
              Here is what is happening with your escrow account today.
            </p>
          </div>

          <a
            href="/payment-links"
            className="create-payment-button"
          >
            <Icon>add</Icon>
            Create Payment Link
          </a>
        </div>

        <section className="summary-grid">
          {summaryCards.map((card) => (
            <SummaryCard
              card={card}
              key={card.title}
            />
          ))}
        </section>

        <TransactionsTable />

        <div className="bottom-grid">
          <PaymentLinks />
          <Disputes />
        </div>

        <Footer />
      </div>
    </div>
  );
}