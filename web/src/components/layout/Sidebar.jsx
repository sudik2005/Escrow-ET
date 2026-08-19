import { useEffect, useRef } from 'react';
import { NavLink } from 'react-router-dom';
import './Sidebar.css';
import logoImage from '../../assets/logo.png';

/* =========================================================
   Icon
========================================================= */

const Icon = ({ children, className = '' }) => (
  <span
    className={`material-symbols-outlined sidebar__material-icon ${className}`}
    aria-hidden="true"
  >
    {children}
  </span>
);

/* =========================================================
   Navigation Items
========================================================= */

const navigationItems = [
  {
    to: '/dashboard',
    label: 'Dashboard',
    icon: 'dashboard',
    end: true,
  },
  {
    to: '/transactions',
    label: 'Transactions',
    icon: 'receipt_long',
  },
  {
    to: '/payment-links',
    label: 'Payment Links',
    icon: 'link',
  },
  {
    to: '/disputes',
    label: 'Disputes',
    icon: 'gavel',
  },
];

const settingsItems = [
  {
    to: '/settings/developer',
    label: 'Developer Settings',
    icon: 'code',
  },
  {
    to: '/docs',
    label: 'API Docs',
    icon: 'menu_book',
  },
];

/* =========================================================
   Sidebar
========================================================= */

const Sidebar = ({ isOpen = true, onClose }) => {
  const sidebarRef = useRef(null);

  /* ---------------------------------------------------------
     Close when clicking outside
  --------------------------------------------------------- */

  useEffect(() => {
    if (!isOpen) {
      return undefined;
    }

    const handlePointerDown = (event) => {
      const sidebar = sidebarRef.current;

      if (!sidebar) {
        return;
      }

      if (!sidebar.contains(event.target)) {
        onClose?.();
      }
    };

    document.addEventListener('mousedown', handlePointerDown);

    return () => {
      document.removeEventListener(
        'mousedown',
        handlePointerDown,
      );
    };
  }, [isOpen, onClose]);

  /* ---------------------------------------------------------
     Close with Escape
  --------------------------------------------------------- */

  useEffect(() => {
    if (!isOpen) {
      return undefined;
    }

    const handleKeyDown = (event) => {
      if (event.key === 'Escape') {
        onClose?.();
      }
    };

    document.addEventListener('keydown', handleKeyDown);

    return () => {
      document.removeEventListener(
        'keydown',
        handleKeyDown,
      );
    };
  }, [isOpen, onClose]);

  /* ---------------------------------------------------------
     Navigation behavior
  --------------------------------------------------------- */

  const handleNavigation = () => {
    if (window.innerWidth < 1024) {
      onClose?.();
    }
  };

  /* ---------------------------------------------------------
     Navigation link
  --------------------------------------------------------- */

  const renderNavigationItem = (item) => (
    <NavLink
      key={item.to}
      to={item.to}
      end={item.end}
      onClick={handleNavigation}
      className={({ isActive }) =>
        [
          'sidebar__nav-link',
          isActive ? 'sidebar__nav-link--active' : '',
        ]
          .filter(Boolean)
          .join(' ')
      }
    >
      <span className="sidebar__nav-icon">
        <Icon>{item.icon}</Icon>
      </span>

      <span className="sidebar__nav-label">
        {item.label}
      </span>
    </NavLink>
  );

  return (
    <>
      {/* =====================================================
          MOBILE OVERLAY
      ====================================================== */}

      {isOpen && (
        <button
          type="button"
          className="sidebar__overlay"
          aria-label="Close navigation"
          onClick={onClose}
        />
      )}

      {/* =====================================================
          SIDEBAR
      ====================================================== */}

      <aside
        ref={sidebarRef}
        className={[
          'sidebar',
          isOpen
            ? 'sidebar--open'
            : 'sidebar--closed',
        ]
          .filter(Boolean)
          .join(' ')}
        aria-label="Application sidebar"
        aria-hidden={!isOpen}
      >
        {/* ===================================================
            BRAND
        ==================================================== */}

        <div className="sidebar__brand">
          <div className="sidebar__brand-icon">
            <img
              src={logoImage}
              alt="Escrow ET logo"
              className="sidebar__logo"
            />
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

        {/* ===================================================
            MAIN NAVIGATION
        ==================================================== */}

        <div className="sidebar__navigation-area">
          <p className="sidebar__section-label">
            Main Menu
          </p>

          <nav
            className="sidebar__nav"
            aria-label="Main navigation"
          >
            {navigationItems.map(renderNavigationItem)}
          </nav>
        </div>

        {/* ===================================================
            BOTTOM NAVIGATION
        ==================================================== */}

        <div className="sidebar__bottom">
          <p className="sidebar__section-label">
            Resources
          </p>

          <nav
            className="sidebar__nav sidebar__nav--bottom"
            aria-label="Settings and resources"
          >
            {settingsItems.map(renderNavigationItem)}
          </nav>
        </div>

        {/* ===================================================
            SYSTEM STATUS
        ==================================================== */}

        <div className="sidebar__status">
          <span className="sidebar__status-dot" />

          <div className="sidebar__status-content">
            <span className="sidebar__status-title">
              System operational
            </span>

            <span className="sidebar__status-text">
              Escrow ET is running normally
            </span>
          </div>
        </div>
      </aside>
    </>
  );
};

export default Sidebar;