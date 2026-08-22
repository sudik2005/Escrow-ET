// web/src/components/layout/Sidebar.jsx

import React, { useEffect, useRef } from 'react';
import { NavLink } from 'react-router-dom';
import './Sidebar.css';

// Simple brand mark – shield SVG
const BrandMark = () => (
  <svg
    width="32"
    height="32"
    viewBox="0 0 32 32"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    aria-hidden="true"
  >
    <rect
      x="4"
      y="4"
      width="24"
      height="24"
      rx="6"
      fill="var(--brand)"
      opacity="0.15"
    />

    <path
      d="M16 8L22 12V18C22 22 16 26 16 26C16 26 10 22 10 18V12L16 8Z"
      fill="var(--brand)"
    />

    <path
      d="M16 11L19 13V17C19 19.5 16 21.5 16 21.5C16 21.5 13 19.5 13 17V13L16 11Z"
      fill="white"
    />
  </svg>
);

const Sidebar = ({ isOpen = true, onClose }) => {
  const sidebarRef = useRef(null);

  /*
   * Close the sidebar when the user clicks anywhere
   * outside of the sidebar.
   *
   * This is especially useful on mobile/tablet when
   * the sidebar is opened using the hamburger button.
   */
  useEffect(() => {
    if (!isOpen) {
      return;
    }

    const handleOutsideClick = (event) => {
      const sidebar = sidebarRef.current;

      if (!sidebar) {
        return;
      }

      // If the click happened outside the sidebar,
      // close it.
      if (!sidebar.contains(event.target)) {
        onClose?.();
      }
    };

    document.addEventListener('mousedown', handleOutsideClick);

    return () => {
      document.removeEventListener('mousedown', handleOutsideClick);
    };
  }, [isOpen, onClose]);

  /*
   * Close the sidebar when the user presses Escape.
   */
  useEffect(() => {
    if (!isOpen) {
      return;
    }

    const handleEscape = (event) => {
      if (event.key === 'Escape') {
        onClose?.();
      }
    };

    document.addEventListener('keydown', handleEscape);

    return () => {
      document.removeEventListener('keydown', handleEscape);
    };
  }, [isOpen, onClose]);

  /*
   * Close the sidebar after selecting a navigation item.
   *
   * This mainly affects mobile/tablet. On desktop,
   * the sidebar normally remains visible.
   */
  const handleNavigation = () => {
    if (window.innerWidth < 1024) {
      onClose?.();
    }
  };

  return (
    <aside
      ref={sidebarRef}
      className={`sidebar ${
        isOpen ? 'sidebar--open' : 'sidebar--closed'
      }`}
      aria-label="Application sidebar"
    >
      {/* Brand Area */}
      <div className="sidebar__brand">
        <div className="sidebar__brand-icon">
          <BrandMark />
        </div>

        <div className="sidebar__brand-text">
          <span className="sidebar__brand-name">
            Escrow ET
          </span>

          <span className="sidebar__brand-sub">
            Merchant Portal
          </span>
        </div>
      </div>

      {/* Main Navigation */}
      <nav
        className="sidebar__nav"
        aria-label="Main navigation"
      >
        <NavLink
          to="/"
          end
          onClick={handleNavigation}
          className={({ isActive }) =>
            `sidebar__nav-link ${
              isActive
                ? 'sidebar__nav-link--active'
                : ''
            }`
          }
        >
          <span
            className="sidebar__nav-icon"
            aria-hidden="true"
          >
            ⌂
          </span>

          <span>Dashboard</span>
        </NavLink>

        <NavLink
          to="/transactions"
          onClick={handleNavigation}
          className={({ isActive }) =>
            `sidebar__nav-link ${
              isActive
                ? 'sidebar__nav-link--active'
                : ''
            }`
          }
        >
          <span
            className="sidebar__nav-icon"
            aria-hidden="true"
          >
            ⟳
          </span>

          <span>Transactions</span>
        </NavLink>

        <NavLink
          to="/payment-links"
          onClick={handleNavigation}
          className={({ isActive }) =>
            `sidebar__nav-link ${
              isActive
                ? 'sidebar__nav-link--active'
                : ''
            }`
          }
        >
          <span
            className="sidebar__nav-icon"
            aria-hidden="true"
          >
            ⊕
          </span>

          <span>Payment Links</span>
        </NavLink>

        <NavLink
          to="/disputes"
          onClick={handleNavigation}
          className={({ isActive }) =>
            `sidebar__nav-link ${
              isActive
                ? 'sidebar__nav-link--active'
                : ''
            }`
          }
        >
          <span
            className="sidebar__nav-icon"
            aria-hidden="true"
          >
            ⚖
          </span>

          <span>Disputes</span>
        </NavLink>
      </nav>

      {/* Developer Settings */}
      <div className="sidebar__bottom">
        <NavLink
          to="/settings/developer"
          onClick={handleNavigation}
          className={({ isActive }) =>
            `sidebar__nav-link sidebar__nav-link--bottom ${
              isActive
                ? 'sidebar__nav-link--active'
                : ''
            }`
          }
        >
          <span
            className="sidebar__nav-icon"
            aria-hidden="true"
          >
            ⚙
          </span>

          <span>Developer Settings</span>
        </NavLink>
      </div>
    </aside>
  );
};

export default Sidebar;