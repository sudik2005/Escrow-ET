import React, { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';
import './AppLayout.css';

const DESKTOP_BREAKPOINT = 1024;

const AppLayout = ({ children }) => {
  const location = useLocation();
  const isAdminPage = location.pathname.startsWith('/admin');

  const [sidebarOpen, setSidebarOpen] = useState(() => {
    if (typeof window === 'undefined') {
      return true;
    }

    return window.innerWidth >= DESKTOP_BREAKPOINT;
  });


  const [isMobile, setIsMobile] = useState(() => {
    if (typeof window === 'undefined') {
      return false;
    }

    return window.innerWidth < DESKTOP_BREAKPOINT;
  });


  useEffect(() => {
    const handleResize = () => {
      const mobile =
        window.innerWidth < DESKTOP_BREAKPOINT;

      setIsMobile(mobile);

      if (mobile) {
        setSidebarOpen(false);
      } else {
        setSidebarOpen(true);
      }
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  useEffect(() => {
    if (isMobile && sidebarOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }

    return () => {
      document.body.style.overflow = '';
    };
  }, [isMobile, sidebarOpen]);

  const closeSidebar = () => {
    
    if (window.innerWidth < DESKTOP_BREAKPOINT) {
      setSidebarOpen(false);
    }
  };

  const toggleSidebar = () => {
    setSidebarOpen((current) => !current);
  };

  const handleContentClick = () => {
    if (
      window.innerWidth < DESKTOP_BREAKPOINT &&
      sidebarOpen
    ) {
      closeSidebar();
    }
  };
  useEffect(() => {
    const handleKeyDown = (event) => {
      if (event.key === 'Escape' && sidebarOpen) {
        closeSidebar();
      }
    };

    document.addEventListener('keydown', handleKeyDown);

    return () => {
      document.removeEventListener(
        'keydown',
        handleKeyDown,
      );
    };
  }, [sidebarOpen]);

  return (
    <div
      className={`
        app-layout
        ${sidebarOpen ? 'app-layout--sidebar-open' : ''}
        ${isMobile ? 'app-layout--mobile' : ''}
      `}
    >
      
      {isMobile && sidebarOpen && (
        <button
          type="button"
          className="
            fixed
            inset-0
            z-40
            cursor-default
            border-0
            bg-black/40
            p-0
            lg:hidden
          "
          onClick={closeSidebar}
          aria-label="Close navigation"
        />
      )}
      <Sidebar
        isOpen={sidebarOpen}
        onClose={closeSidebar}
      />
      <div
        className={`
          app-main
          ${!sidebarOpen ? 'app-main--sidebar-closed' : ''}
          ${isMobile ? 'app-main--mobile' : ''}
        `}
      >
        {!isAdminPage && (
          <div
            className="
              relative
              z-50
            "
          >
            <Header
              sidebarOpen={sidebarOpen}
              setSidebarOpen={toggleSidebar}
            />
          </div>
        )}
        <main
          className="
            app-content
            relative
            z-10
          "
          onClick={handleContentClick}
        >
          {React.isValidElement(children)
            ? React.cloneElement(children, { sidebarOpen, toggleSidebar })
            : children}
        </main>
      </div>
    </div>
  );
};

export default AppLayout;
