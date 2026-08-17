import { useState } from 'react'
import { ArrowLeft, Copy, Share2 } from 'lucide-react'

function CreatePaymentLink() {
  const [formData, setFormData] = useState({
    productName: '',
    amount: '',
    currency: 'ETB',
    description: '',
    deliveryTime: '',
  })
  const [generatedLink, setGeneratedLink] = useState(null)

  function handleChange(e) {
    const { name, value } = e.target
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  function handleSubmit(e) {
    e.preventDefault()
    // TODO: replace with real API call to Django once backend is ready.
    const fakeId = Math.random().toString(36).substring(2, 8).toUpperCase()
    setGeneratedLink(`https://escrow-et.com/pay/${fakeId}`)
  }

  return (
    // NOTE: colors are hardcoded for light mode for now.
    // Once Hermella's theme toggle/CSS variables land, swap these
    // for her theme tokens instead of maintaining our own light/dark logic.
    <div className="min-h-screen bg-white text-gray-900 p-4">
      <div className="max-w-md mx-auto">
        <div className="flex items-center gap-3 mb-6 pt-2">
          <button type="button" aria-label="Go back">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Create Payment Link</h1>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-gray-600 mb-1.5">
              Product / Service
            </label>
            <input
              type="text"
              name="productName"
              value={formData.productName}
              onChange={handleChange}
              required
              className="w-full bg-white border border-gray-300 rounded-xl px-4 py-3 text-gray-900 placeholder-gray-400 focus:outline-none focus:border-red-800"
              placeholder="Yirgacheffe Coffee"
            />
          </div>

          <div>
            <label className="block text-sm text-gray-600 mb-1.5">
              Amount
            </label>
            <div className="flex gap-2">
              <input
                type="number"
                name="amount"
                value={formData.amount}
                onChange={handleChange}
                required
                min="1"
                className="flex-1 bg-white border border-gray-300 rounded-xl px-4 py-3 text-gray-900 placeholder-gray-400 focus:outline-none focus:border-red-800"
                placeholder="500"
              />
              <select
                name="currency"
                value={formData.currency}
                onChange={handleChange}
                className="bg-white border border-gray-300 rounded-xl px-3 py-3 text-gray-900 focus:outline-none focus:border-red-800"
              >
                <option value="ETB">ETB</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-sm text-gray-600 mb-1.5">
              Description (Optional)
            </label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows="2"
              className="w-full bg-white border border-gray-300 rounded-xl px-4 py-3 text-gray-900 placeholder-gray-400 focus:outline-none focus:border-red-800"
              placeholder="1kg freshly roasted coffee beans"
            />
          </div>

          <div>
            <label className="block text-sm text-gray-600 mb-1.5">
              Delivery Time (Optional)
            </label>
            <input
              type="text"
              name="deliveryTime"
              value={formData.deliveryTime}
              onChange={handleChange}
              className="w-full bg-white border border-gray-300 rounded-xl px-4 py-3 text-gray-900 placeholder-gray-400 focus:outline-none focus:border-red-800"
              placeholder="3-5 days"
            />
          </div>

          <button
            type="submit"
            className="w-full bg-red-800 hover:bg-red-900 text-white font-semibold py-3.5 rounded-xl transition-colors mt-2"
          >
            Generate Payment Link
          </button>
        </form>

        {generatedLink && (
          <div className="mt-6 p-5 border border-gray-200 rounded-2xl">
            <p className="text-center font-semibold mb-1">
              Link Created Successfully! 🎉
            </p>
            <p className="text-center text-sm text-gray-500 mb-4">
              Share this link with your buyer
            </p>
            <div className="flex items-center justify-between bg-red-50 border border-red-200 rounded-xl px-4 py-3 mb-4">
              <span className="text-red-800 text-sm break-all">{generatedLink}</span>
              <button
                onClick={() => navigator.clipboard.writeText(generatedLink)}
                aria-label="Copy link"
              >
                <Copy className="w-4 h-4 text-gray-500 shrink-0 ml-2" />
              </button>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => navigator.clipboard.writeText(generatedLink)}
                className="flex-1 bg-red-800 hover:bg-red-900 text-white rounded-full py-2.5 text-sm font-semibold transition-colors"
              >
                Copy Link
              </button>
              <button className="flex-1 bg-red-800 hover:bg-red-900 text-white rounded-full py-2.5 text-sm font-semibold transition-colors flex items-center justify-center gap-1.5">
                <Share2 className="w-3.5 h-3.5" />
                Share Link
              </button>
            </div>
            <p className="text-center text-xs text-gray-400 mt-4">
              Anyone with this link can pay securely.
            </p>
          </div>
        )}
      </div>
    </div>
  )
}

export default CreatePaymentLink