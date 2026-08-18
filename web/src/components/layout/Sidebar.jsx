import { useEffect, useRef } from 'react';
import { NavLink } from 'react-router-dom';
import './Sidebar.css';

/* =========================================================
   Brand Mark
========================================================= */

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

/* =========================================================
   Navigation Items
========================================================= */

const navigationItems = [
  {
    to: '/',
    label: 'Dashboard',
    icon: '⌂',
    end: true,
  },
  {
    to: '/transactions',
    label: 'Transactions',
    icon: '⟳',
  },
  {
    to: '/payment-links',
    label: 'Payment Links',
    icon: '⊕',
  },
  {
    to: '/disputes',
    label: 'Disputes',
    icon: '⚖',
  },
];

const settingsItems = [
  {
    to: '/settings/developer',
    label: 'Developer Settings',
    icon: '⚙',
  },
  {
    to: '/docs',
    label: 'API Docs',
    icon: '▤',
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

     On mobile/tablet:
     selecting a page closes the sidebar.

     On desktop:
     the sidebar remains open.
  --------------------------------------------------------- */

  const handleNavigation = () => {
    if (window.innerWidth < 1024) {
      onClose?.();
    }
  };

  /* ---------------------------------------------------------
     Render navigation link
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
          isActive
            ? 'sidebar__nav-link--active'
            : '',
        ]
          .filter(Boolean)
          .join(' ')
      }
    >
      <span
        className="sidebar__nav-icon"
        aria-hidden="true"
      >
        {item.icon}
      </span>

      <span className="sidebar__nav-label">
        {item.label}
      </span>
    </NavLink>
  );

  return (
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
      {/* =====================================================
          Brand
      ===================================================== */}

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

      {/* =====================================================
          Main Navigation
      ===================================================== */}

      <nav
        className="sidebar__nav"
        aria-label="Main navigation"
      >
        {navigationItems.map(renderNavigationItem)}
      </nav>

      {/* =====================================================
          Bottom Navigation
      ===================================================== */}

      <div className="sidebar__bottom">
        {settingsItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            onClick={handleNavigation}
            className={({ isActive }) =>
              [
                'sidebar__nav-link',
                'sidebar__nav-link--bottom',
                isActive
                  ? 'sidebar__nav-link--active'
                  : '',
              ]
                .filter(Boolean)
                .join(' ')
            }
          >
            <span
              className="sidebar__nav-icon"
              aria-hidden="true"
            >
              {item.icon}
            </span>

            <span className="sidebar__nav-label">
              {item.label}
            </span>
          </NavLink>
        ))}
      </div>
    </aside>
  );
};

export default Sidebar;