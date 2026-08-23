import { createContext, useContext, useEffect, useState } from 'react'
import * as api from '../lib/api'

const AuthContext = createContext(null)

function applySession(setToken, setUser, data) {
  localStorage.setItem('authToken', data.token)
  setToken(data.token)
  setUser(data.user)
  return data.user
}

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => localStorage.getItem('authToken') || null)
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!token) {
      setLoading(false)
      return
    }
    api.me(token)
      .then((u) => setUser(u))
      .catch(() => {
        localStorage.removeItem('authToken')
        setToken(null)
      })
      .finally(() => setLoading(false))
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  async function login(username, password) {
    const data = await api.login(username, password)
    return applySession(setToken, setUser, data)
  }

  async function loginWithFayda(rawPayload) {
    const data = await api.loginWithFayda(rawPayload)
    return applySession(setToken, setUser, data)
  }

  async function register({ phoneNumber, role, rawPayload }) {
    const data = await api.register({ phoneNumber, role, rawPayload })
    return applySession(setToken, setUser, data)
  }

  async function updateProfile(payload) {
    const next = await api.updateProfile(token, payload)
    setUser(next)
    return next
  }

  function logout() {
    const current = token
    localStorage.removeItem('authToken')
    setToken(null)
    setUser(null)
    if (current) {
      api.logout(current).catch(() => {})
    }
  }

  return (
    <AuthContext.Provider
      value={{
        token,
        user,
        loading,
        login,
        loginWithFayda,
        register,
        updateProfile,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used inside <AuthProvider>')
  return ctx
}
