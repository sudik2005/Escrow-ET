// web/src/components/layout/Header.jsx

import { useEffect, useRef, useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useTheme } from "../../context/useTheme";
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
  const location = useLocation();
  const navigate = useNavigate();

  const [profileOpen, setProfileOpen] = useState(false);
  const [notificationsOpen, setNotificationsOpen] = useState(false);

  const profileRef = useRef(null);
  const notificationRef = useRef(null);

  const currentTitle =
    routeTitles[location.pathname] || "Dashboard";

  /*
   * Close dropdowns when clicking outside.
   */
  useEffect(() => {
    const handleOutsideClick = (event) => {
      if (
        profileRef.current &&
        !profileRef.current.contains(event.target)
      ) {
        setProfileOpen(false);
      }

      if (
        notificationRef.current &&
        !notificationRef.current.contains(event.target)
      ) {
        setNotificationsOpen(false);
      }
    };

    document.addEventListener("mousedown", handleOutsideClick);

    return () => {
      document.removeEventListener(
        "mousedown",
        handleOutsideClick
      );
    };
  }, []);

  /*
   * Close dropdowns when route changes.
   */
  useEffect(() => {
    setProfileOpen(false);
    setNotificationsOpen(false);
  }, [location.pathname]);

  const handleLogout = () => {
    /*
     * TODO:
     * Connect this to the Django authentication API.
     *
     * Example later:
     * await logoutApi();
     * navigate("/login");
     */

    setProfileOpen(false);

    console.log("Logout clicked");

    // Temporary navigation until backend authentication is connected.
    navigate("/");
  };

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
              setNotificationsOpen(!notificationsOpen)
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

            <span className="header__notification-badge">
              3
            </span>
          </button>

          {notificationsOpen && (
            <div className="header__notification-menu">
              <div className="header__dropdown-header">
                <div>
                  <strong>Notifications</strong>
                  <span>Recent activity</span>
                </div>

                <span className="header__notification-count">
                  3
                </span>
              </div>

              <div className="header__notification-item">
                <span className="notification-dot success" />

                <div>
                  <strong>Payment released</strong>
                  <span>
                    ET-10093 has been released.
                  </span>
                </div>
              </div>

              <div className="header__notification-item">
                <span className="notification-dot warning" />

                <div>
                  <strong>New dispute</strong>
                  <span>
                    ET-10292 requires your attention.
                  </span>
                </div>
              </div>

              <div className="header__notification-item">
                <span className="notification-dot info" />

                <div>
                  <strong>Payment link created</strong>
                  <span>
                    Coffee Beans link is ready.
                  </span>
                </div>
              </div>

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
              setProfileOpen(!profileOpen)
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
            <div className="header__avatar">
              <img
                src="/profile.png"
                alt="Bereket"
                onError={(event) => {
                  event.currentTarget.style.display =
                    "none";

                  event.currentTarget.parentElement.classList.add(
                    "header__avatar--fallback"
                  );
                }}
              />

              <span className="header__avatar-initials">
                B
              </span>
            </div>

            <div className="header__profile-info">
              <span className="header__profile-name">
                Bereket
              </span>

              <span className="header__profile-role">
                Merchant
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
                  setProfileOpen(false);
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