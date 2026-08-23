import { useTheme } from '../../context/useTheme'
import logoDark from '../../assets/logo dark.png'
import logoLight from '../../assets/logo light.png'

export default function BrandLogo({ className = '', alt = 'Escrow ET' }) {
  const { theme } = useTheme()

  return (
    <img
      src={theme === 'dark' ? logoDark : logoLight}
      alt={alt}
      className={className}
    />
  )
}
