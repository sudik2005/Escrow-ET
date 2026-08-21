import { createContext, useContext, useEffect, useState } from 'react'
import * as api from '../lib/api'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => localStorage.getItem('authToken') || null)
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  // On mount, restore user from saved token
  useEffect(() => {
    if (!token) {
      setLoading(false)
      return
    }
    api.me(token)
      .then((u) => setUser(u))
      .catch(() => {
        // Token is stale — clear it
        localStorage.removeItem('authToken')
        setToken(null)
      })
      .finally(() => setLoading(false))
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  async function login(username, password) {
    const data = await api.login(username, password)
    localStorage.setItem('authToken', data.token)
    setToken(data.token)
    setUser(data.user)
    return data.user
  }

  async function register({ username, password, phoneNumber, role, email }) {
    const data = await api.register({ username, password, phoneNumber, role, email })
    localStorage.setItem('authToken', data.token)
    setToken(data.token)
    setUser(data.user)
    return data.user
  }

  function logout() {
    localStorage.removeItem('authToken')
    setToken(null)
    setUser(null)
  }

  return (
    <AuthContext.Provider value={{ token, user, loading, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>')
  return ctx
}
