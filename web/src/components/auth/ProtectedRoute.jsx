import { Navigate, Outlet, useLocation } from 'react-router-dom';

function ProtectedRoute() {
  const location = useLocation();

  /*
   * Temporary authentication check.
   *
   * Replace this later with the real authentication
   * state/context when login is implemented.
   */
  const isAuthenticated =
    localStorage.getItem('authToken') !== null;

  if (!isAuthenticated) {
    return (
      <Navigate
        to="/"
        replace
        state={{ from: location }}
      />
    );
  }

  return <Outlet />;
}

export default ProtectedRoute;