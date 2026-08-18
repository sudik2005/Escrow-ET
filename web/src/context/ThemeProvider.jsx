import { useEffect, useState } from 'react'
import ThemeContext from './ThemeContext'

const THEME_STORAGE_KEY = 'escrow-theme'

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState(() => {
    if (typeof window === 'undefined') {
      return 'light'
    }

    const savedTheme = localStorage.getItem(THEME_STORAGE_KEY)

    return savedTheme === 'dark' ? 'dark' : 'light'
  })

  useEffect(() => {
    const root = document.documentElement

    root.setAttribute('data-theme', theme)

    root.style.colorScheme = theme

    localStorage.setItem(THEME_STORAGE_KEY, theme)
  }, [theme])

  const toggleTheme = () => {
    setTheme((currentTheme) =>
      currentTheme === 'light' ? 'dark' : 'light',
    )
  }

  const value = {
    theme,
    toggleTheme,
  }

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  )
}