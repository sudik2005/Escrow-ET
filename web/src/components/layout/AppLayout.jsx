// web/src/components/layout/AppLayout.jsx

import React, { useEffect, useState } from 'react';
import Sidebar from './Sidebar';
import Header from './Header';
import './AppLayout.css';

const AppLayout = ({ children }) => {
  // Sidebar is open by default on desktop
  // and closed by default on mobile/tablet.
  const [sidebarOpen, setSidebarOpen] = useState(() => {
    if (typeof window !== 'undefined') {
      return window.innerWidth >= 1024;
    }

    return true;
  });

  // Automatically close the sidebar when
  // switching from desktop to mobile/tablet.
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth < 1024) {
        setSidebarOpen(false);
      }
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  const openSidebar = () => {
    setSidebarOpen(true);
  };

  const closeSidebar = () => {
    setSidebarOpen(false);
  };

  const toggleSidebar = () => {
    setSidebarOpen((current) => !current);
  };

  return (
    <div className="app-layout">
      {/* Sidebar */}
      <Sidebar
        isOpen={sidebarOpen}
        onClose={closeSidebar}
      />

      {/* Main Application Area */}
      <div
        className={`app-main ${
          !sidebarOpen
            ? 'app-main--sidebar-closed'
            : ''
        }`}
      >
        {/* Header */}
        <Header
          sidebarOpen={sidebarOpen}
          setSidebarOpen={toggleSidebar}
        />

        {/* Main Content */}
        <main
          className="app-content"
          onClick={() => {
            if (
              sidebarOpen &&
              window.innerWidth < 1024
            ) {
              closeSidebar();
            }
          }}
        >
          {children}
        </main>
      </div>
    </div>
  );
};

export default AppLayout;