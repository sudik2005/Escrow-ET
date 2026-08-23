// web/src/components/layout/Header.jsx

import { useEffect, useRef, useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useTheme } from "../../context/useTheme";
import { useAuth } from "../../context/AuthContext";
import * as api from "../../lib/api";
import { displayName, initials, isDisputed, isReleased, statusLabel } from "../../lib/status";
import "./Header.css";

const routeTitles = {
  "/dashboard": "Dashboard",
  "/transactions": "Transactions",
  "/payment-links": "Payment Links",
  "/disputes": "Disputes",
  "/settings/developer": "Developer Settings",
  "/docs": "API Docs",
  "/profile": "Profile",
};

const Header = ({ sidebarOpen, setSidebarOpen }) => {
  const { theme, toggleTheme } = useTheme();
  const { user, token, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [notices, setNotices] = useState([]);

const [profileMenu, setProfileMenu] = useState({
  path: null,
  open: false,
});

const [notificationsMenu, setNotificationsMenu] = useState({
  path: null,
  open: false,
});

const profileOpen =
  profileMenu.path === location.pathname && profileMenu.open;

const notificationsOpen =
  notificationsMenu.path === location.pathname &&
  notificationsMenu.open;

  const profileRef = useRef(null);
  const notificationRef = useRef(null);

  const currentTitle =
    routeTitles[location.pathname] || "Dashboard";

  /*
   * Close dropdowns when clicking outside.
   */
const pathname = location.pathname;

useEffect(() => {
  const handleOutsideClick = (event) => {
    if (
      profileRef.current &&
      !profileRef.current.contains(event.target)
    ) {
      setProfileMenu({
        path: pathname,
        open: false,
      });
    }

    if (
      notificationRef.current &&
      !notificationRef.current.contains(event.target)
    ) {
      setNotificationsMenu({
        path: pathname,
        open: false,
      });
    }
  };

  document.addEventListener("mousedown", handleOutsideClick);

  return () => {
    document.removeEventListener(
      "mousedown",
      handleOutsideClick
    );
  };
}, [pathname]);

useEffect(() => {
  if (!token) return;
  api.mineContracts(token)
    .then((data) => {
      const list = Array.isArray(data) ? data : [];
      setNotices(
        list.slice(0, 5).map((c) => ({
          id: c.id,
          title: isDisputed(c.status)
            ? "Dispute open"
            : isReleased(c.status)
            ? "Funds released"
            : statusLabel(c.status),
          detail: c.item_name || `ET-${c.id}`,
          tone: isDisputed(c.status)
            ? "warning"
            : isReleased(c.status)
            ? "success"
            : "info",
        })),
      );
    })
    .catch(() => setNotices([]));
}, [token]);

  const handleLogout = () => {
    setProfileMenu({
      path: location.pathname,
      open: false,
    });
    logout();
    navigate("/");
  };

  const profileLabel = displayName(user);
  const roleLabel = user?.role
    ? user.role.charAt(0) + user.role.slice(1).toLowerCase()
    : "Account";
  const avatarLetters = initials(profileLabel);

  return (
    <header className="header">
      {/* =====================================================
          LEFT SIDE
      ====================================================== */}

      <div className="header__left">
        {/* Mobile / Tablet menu */}
        <button
          type="button"
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="header__menu-toggle"
          aria-label={
            sidebarOpen
              ? "Close navigation"
              : "Open navigation"
          }
          aria-expanded={sidebarOpen}
          title={
            sidebarOpen
              ? "Close navigation"
              : "Open navigation"
          }
        >
          <span className="header__menu-icon">
            <svg
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              {sidebarOpen ? (
                <path
                  d="M6 6l12 12M18 6L6 18"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                />
              ) : (
                <path
                  d="M4 7h16M4 12h16M4 17h16"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                />
              )}
            </svg>
          </span>
        </button>

        {/* Page title */}
        <div className="header__title-group">
          <span className="header__eyebrow">
            Merchant Portal
          </span>

          <h1 className="header__title">
            {currentTitle}
          </h1>
        </div>
      </div>

      {/* =====================================================
          RIGHT SIDE
      ====================================================== */}

      <div className="header__right">
        {/* Read docs */}
        <Link
          to="/docs"
          className="header__docs-button"
        >
          <svg
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <path
              d="M6 4.5A2.5 2.5 0 0 1 8.5 2H20v17H8.5A2.5 2.5 0 0 0 6 21.5v-17Z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinejoin="round"
            />

            <path
              d="M6 18.5A2.5 2.5 0 0 1 8.5 16H20"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.8"
              strokeLinecap="round"
            />
          </svg>

          <span>Read docs</span>
        </Link>

        {/* =================================================
            THEME TOGGLE
        ================================================== */}

        <button
          type="button"
          onClick={toggleTheme}
          className="header__icon-button header__theme-toggle"
          aria-label={
            theme === "dark"
              ? "Switch to light mode"
              : "Switch to dark mode"
          }
          aria-pressed={theme === "dark"}
          title={
            theme === "dark"
              ? "Switch to light mode"
              : "Switch to dark mode"
          }
        >
          <span className="header__icon-wrapper">
            {theme === "dark" ? (
              <svg
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <circle
                  cx="12"
                  cy="12"
                  r="4"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.8"
                />

                <path
                  d="M12 2v2M12 20v2M4.93 4.93l1.42 1.42M17.65 17.65l1.42 1.42M2 12h2M20 12h2M4.93 19.07l1.42-1.42M17.65 6.35l1.42-1.42"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.8"
                  strokeLinecap="round"
                />
              </svg>
            ) : (
              <svg
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path
                  d="M20.4 15.2A8.5 8.5 0 0 1 8.8 3.6 8.5 8.5 0 1 0 20.4 15.2Z"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.8"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            )}
          </span>
        </button>

        {/* =================================================
            NOTIFICATIONS
        ================================================== */}

        <div
          className="header__notification-wrapper"
          ref={notificationRef}
        >
          <button
            type="button"
           onClick={() =>
  setNotificationsMenu({
    path: location.pathname,
    open: !notificationsOpen,
  })
}
            className="header__icon-button header__notification"
            aria-label="Notifications"
            aria-expanded={notificationsOpen}
            title="Notifications"
          >
            <span className="header__icon-wrapper">
              <svg
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path
                  d="M18 9a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.8"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />

                <path
                  d="M10 21h4"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.8"
                  strokeLinecap="round"
                />
              </svg>
            </span>

            {notices.length > 0 && (
              <span className="header__notification-badge">
                {notices.length}
              </span>
            )}
          </button>

          {notificationsOpen && (
            <div className="header__notification-menu">
              <div className="header__dropdown-header">
                <div>
                  <strong>Notifications</strong>
                  <span>Recent activity</span>
                </div>

                <span className="header__notification-count">
                  {notices.length}
                </span>
              </div>

              {notices.length === 0 ? (
                <div className="header__notification-item">
                  <div>
                    <strong>No new activity</strong>
                    <span>Your contracts will show up here.</span>
                  </div>
                </div>
              ) : (
                notices.map((item) => (
                  <Link
                    key={item.id}
                    to={`/transactions?id=${item.id}`}
                    className="header__notification-item"
                    onClick={() =>
                      setNotificationsMenu({
                        path: location.pathname,
                        open: false,
                      })
                    }
                  >
                    <span className={`notification-dot ${item.tone}`} />
                    <div>
                      <strong>{item.title}</strong>
                      <span>{item.detail}</span>
                    </div>
                  </Link>
                ))
              )}

              <Link
                to="/transactions"
                className="header__view-notifications"
              >
                View all activity
              </Link>
            </div>
          )}
        </div>

        {/* =================================================
            PROFILE DROPDOWN
        ================================================== */}

        <div
          className="header__profile-wrapper"
          ref={profileRef}
        >
          <button
            type="button"
           onClick={() =>
  setProfileMenu({
    path: location.pathname,
    open: !profileOpen,
  })
}
            className={`header__profile ${
              profileOpen
                ? "header__profile--open"
                : ""
            }`}
            aria-label="Open profile menu"
            aria-expanded={profileOpen}
            title="Profile menu"
          >
            <div className="header__avatar header__avatar--fallback">
              <span className="header__avatar-initials">
                {avatarLetters}
              </span>
            </div>

            <div className="header__profile-info">
              <span className="header__profile-name">
                {profileLabel}
              </span>

              <span className="header__profile-role">
                {roleLabel}
              </span>
            </div>

            <svg
              className={`header__profile-chevron ${
                profileOpen
                  ? "header__profile-chevron--open"
                  : ""
              }`}
              viewBox="0 0 24 24"
              aria-hidden="true"
            >
              <path
                d="m7 10 5 5 5-5"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </button>

          {profileOpen && (
            <div className="header__profile-menu">
              {/* Profile */}
              <button
                type="button"
                className="header__profile-menu-item"
               onClick={() => {
  setProfileMenu({
    path: location.pathname,
    open: false,
  });
  navigate("/profile");
}}
              >
                <span className="header__menu-item-icon">
                  <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true"
                  >
                    <circle
                      cx="12"
                      cy="8"
                      r="3.5"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                    />

                    <path
                      d="M5 20a7 7 0 0 1 14 0"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                      strokeLinecap="round"
                    />
                  </svg>
                </span>

                <span>
                  <strong>Profile</strong>
                  <small>
                    Manage your account
                  </small>
                </span>
              </button>

              <div className="header__profile-menu-divider" />

              {/* Logout */}
              <button
                type="button"
                className="header__profile-menu-item header__profile-menu-item--danger"
                onClick={handleLogout}
              >
                <span className="header__menu-item-icon">
                  <svg
                    viewBox="0 0 24 24"
                    aria-hidden="true"
                  >
                    <path
                      d="M10 5H6.5A1.5 1.5 0 0 0 5 6.5v11A1.5 1.5 0 0 0 6.5 19H10"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                      strokeLinecap="round"
                    />

                    <path
                      d="M14 8l4 4-4 4M18 12H9"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="1.8"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </span>

                <span>
                  <strong>Logout</strong>
                  <small>
                    Sign out of your account
                  </small>
                </span>
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;