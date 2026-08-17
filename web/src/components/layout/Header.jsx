// web/src/components/layout/Header.jsx

import { useLocation } from 'react-router-dom';
import { useTheme } from '../../context/ThemeContext';
import './Header.css';

const routeTitles = {
  '/': 'Dashboard',
  '/transactions': 'Transactions',
  '/payment-links': 'Payment Links',
  '/disputes': 'Disputes',
  '/settings/developer': 'Developer Settings',
};

const Header = ({ sidebarOpen, setSidebarOpen }) => {
  const { theme, toggleTheme } = useTheme();
  const location = useLocation();

  const currentTitle =
    routeTitles[location.pathname] || 'Dashboard';

  return (
    <header className="header">
      <div className="header__left">
        <button
          type="button"
          className="header__menu-toggle"
          onClick={() => setSidebarOpen(!sidebarOpen)}
          aria-label={
            sidebarOpen ? 'Close navigation' : 'Open navigation'
          }
          aria-expanded={sidebarOpen}
        >
          <span className="header__menu-icon" aria-hidden="true">
            ☰
          </span>
        </button>

        <div className="header__title-group">
          <span className="header__eyebrow">
            Merchant Portal
          </span>

          <h1 className="header__title">
            {currentTitle}
          </h1>
        </div>
      </div>

      <div className="header__right">
        <button
          type="button"
          className="header__theme-toggle"
          onClick={toggleTheme}
          aria-label={
            theme === 'dark'
              ? 'Switch to light mode'
              : 'Switch to dark mode'
          }
          aria-pressed={theme === 'dark'}
          title={
            theme === 'dark'
              ? 'Switch to light mode'
              : 'Switch to dark mode'
          }
        >
          <span aria-hidden="true">
            {theme === 'dark' ? '☀' : '☾'}
          </span>
        </button>

        <button
          type="button"
          className="header__placeholder header__notification"
          aria-label="Notifications"
          title="Notifications"
        >
          <span aria-hidden="true">🔔</span>
        </button>

        <button
          type="button"
          className="header__placeholder header__profile"
          aria-label="Profile"
          title="Profile"
        >
          <span aria-hidden="true">👤</span>
        </button>
      </div>
    </header>
  );
};

export default Header;