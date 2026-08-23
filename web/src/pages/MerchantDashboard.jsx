import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "./MerchantDashboard.css";
import { useAuth } from "../context/AuthContext";
import * as api from "../lib/api";
import {
  displayName,
  fmtEtb,
  isDisputed,
  isLocked,
  isPendingPayment,
  isReleased,
  statusLabel,
  statusVariant,
} from "../lib/status";

function contractToRow(c) {
  const variant = statusVariant(c.status);
  return {
    id: `ET-${c.id}`,
    rawId: c.id,
    title: c.item_name || "—",
    buyer: c.buyer_username || c.buyer_phone || "—",
    amount: fmtEtb(c.amount),
    status: statusLabel(c.status),
    date: c.created_at
      ? new Date(c.created_at).toLocaleString("en-ET", {
          day: "2-digit",
          month: "short",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        })
      : "—",
    icon: variant === "disputed" ? "warning" : "shopping_bag",
    variant,
  };
}

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

function TransactionsTable({ rows = [] }) {
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

      {rows.length === 0 ? (
        <p className="text-center text-sm text-[var(--text-muted)] py-8">No transactions yet.</p>
      ) : (
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
              {rows.map((transaction) => (
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
                    <a
                      href={`/transactions?id=${transaction.rawId}`}
                      aria-label={`View ${transaction.id}`}
                      title={`View ${transaction.id}`}
                    >
                      <Icon>chevron_right</Icon>
                    </a>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}

function PaymentLinks({ links = [] }) {
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
        {links.length === 0 ? (
          <p className="text-sm text-[var(--text-muted)] py-4 text-center">No open payment links.</p>
        ) : (
          links.map((paymentLink) => (
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
          ))
        )}
      </div>
    </section>
  );
}

function Disputes({ items = [] }) {
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
        {items.length === 0 ? (
          <p className="text-sm text-[var(--text-muted)] py-4 text-center">No active disputes.</p>
        ) : (
          items.map((dispute) => (
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

                <a href={`/disputes/messages?id=${dispute.disputeId || ""}`}>
                  {dispute.status}
                  <Icon>arrow_forward</Icon>
                </a>
              </div>
            </div>
          ))
        )}
      </div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="dashboard-footer">
      <p>Copyright © 2024 Escrow ET</p>

      <div>
        <a href="/#privacy">Privacy Policy</a>
        <a href="/#terms">Terms of Service</a>
        <a href="/#contact">Contact Support</a>
        <a href="/#security">Security Guide</a>
      </div>
    </footer>
  );
}

export default function MerchantDashboard() {
  const { user, token } = useAuth();
  const navigate = useNavigate();
  const [contracts, setContracts] = useState([]);
  const [loadingContracts, setLoadingContracts] = useState(true);

  useEffect(() => {
    if (!token) return;
    api
      .mineContracts(token)
      .then((data) => setContracts(Array.isArray(data) ? data : []))
      .catch(() => setContracts([]))
      .finally(() => setLoadingContracts(false));
  }, [token]);

  const locked = contracts
    .filter((c) => isLocked(c.status))
    .reduce((sum, c) => sum + Number(c.amount), 0);

  const released = contracts
    .filter((c) => isReleased(c.status))
    .reduce((sum, c) => sum + Number(c.amount), 0);

  const summaryCards = [
    {
      title: "Wallet balance",
      value: fmtEtb(user?.balance ?? 0),
      icon: "account_balance_wallet",
      variant: "primary",
    },
    {
      title: "Locked Funds",
      value: fmtEtb(locked),
      icon: "lock",
      variant: "secondary",
    },
    {
      title: "Total Released",
      value: fmtEtb(released),
      icon: "check_circle",
      variant: "primary",
    },
    {
      title: "Total Transactions",
      value: String(contracts.length),
      icon: "receipt_long",
      variant: "neutral",
    },
  ];

  const rows = contracts.slice(0, 10).map(contractToRow);

  const paymentLinks = contracts
    .filter((c) => isPendingPayment(c.status))
    .slice(0, 5)
    .map((c) => ({
      title: c.item_name || "Payment",
      url: `${window.location.origin}/checkout/${c.id}`,
      amount: fmtEtb(c.amount),
      date: c.created_at
        ? new Date(c.created_at).toLocaleDateString("en-ET", {
            day: "2-digit",
            month: "short",
          })
        : "—",
    }));

  const disputes = contracts
    .filter((c) => isDisputed(c.status))
    .slice(0, 5)
    .map((c) => ({
      id: `ET-${c.id}`,
      disputeId: c.dispute_id,
      title: c.item_name || "—",
      amount: fmtEtb(c.amount),
      status: "Open",
    }));

  return (
    <div className="merchant-dashboard">
      <div className="dashboard-content">

        <div className="dashboard-heading">
          <div>
            <p className="dashboard-eyebrow">
              Account overview
            </p>

            <h1 className="dashboard-greeting">
              Hello, {displayName(user)} <span>👋</span>
            </h1>

            <p className="dashboard-subtitle">
              Here is what is happening with your escrow account today.
            </p>
          </div>

          <button
            type="button"
            className="create-payment-button"
            onClick={() => navigate("/payment-links")}
          >
            <Icon>add</Icon>
            Create Payment Link
          </button>
        </div>

        <section className="summary-grid">
          {summaryCards.map((card) => (
            <SummaryCard
              card={card}
              key={card.title}
            />
          ))}
        </section>

        {loadingContracts ? (
          <div className="flex justify-center py-12">
            <div className="w-8 h-8 border-2 border-[var(--brand)] border-t-transparent rounded-full animate-spin" />
          </div>
        ) : (
          <>
            <TransactionsTable rows={rows} />
            <div className="bottom-grid">
              <PaymentLinks links={paymentLinks} />
              <Disputes items={disputes} />
            </div>
          </>
        )}

        <Footer />
      </div>
    </div>
  );
}