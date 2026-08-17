import { BrowserRouter, Routes, Route } from 'react-router-dom'
import CreatePaymentLink from './pages/CreatePaymentLink'
import Checkout from './pages/Checkout'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/create-link" element={<CreatePaymentLink />} />
        <Route path="/checkout" element={<Checkout />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App