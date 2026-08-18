import { BrowserRouter, Routes, Route } from 'react-router-dom'
import CreatePaymentLink from './pages/CreatePaymentLink'
import Checkout from './pages/Checkout'
import Payment from './pages/Payment'
import PaymentSuccess from './pages/PaymentSuccess'
import TransactionTracking from './pages/TransactionTracking'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/create-link" element={<CreatePaymentLink />} />
        <Route path="/checkout" element={<Checkout />} />
        <Route path="/payment" element={<Payment />} />
        <Route path="/payment-success" element={<PaymentSuccess />} />
        <Route path="/transaction-tracking" element={<TransactionTracking />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App