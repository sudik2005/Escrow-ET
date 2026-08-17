import { ArrowLeft } from "lucide-react";

function Checkout() {
  // TODO: replace this hardcoded data with a real fetch from Django,
  // using a transaction/link ID pulled from the URL (e.g. /pay/:linkId).
  const deal = {
    productName: "Yirgacheffe Coffee",
    sellerName: "Buna Coffee",
    description: "Top quality freshly roasted coffee beans",
    itemAmount: 500.0,
    escrowFee: 10.0,
  };
  const total = deal.itemAmount + deal.escrowFee;

  const whyEscrowSteps = [
    "Pay safely and securely",
    "Funds are held in escrow",
    "Delivery person scans the QR",
    "Funds are released after delivery",
  ];

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900 p-4 flex items-center justify-center">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-sm p-8">
        <div className="flex items-center gap-3 mb-6 pt-2">
          <button type="button" aria-label="Go back">
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h1 className="text-lg font-bold">Checkout</h1>
        </div>

        {/* Step indicator: Review -> Payment -> Confirm */}
        <div className="flex items-center justify-center gap-2 mb-6 text-xs">
          <span className="flex items-center gap-1.5 font-semibold text-red-800">
            <span className="w-5 h-5 rounded-full bg-red-800 text-white flex items-center justify-center text-[10px]">
              1
            </span>
            Review
          </span>
          <span className="text-gray-300">→</span>
          <span className="flex items-center gap-1.5 text-gray-400">
            <span className="w-5 h-5 rounded-full border border-gray-300 flex items-center justify-center text-[10px]">
              2
            </span>
            Payment
          </span>
          <span className="text-gray-300">→</span>
          <span className="flex items-center gap-1.5 text-gray-400">
            <span className="w-5 h-5 rounded-full border border-gray-300 flex items-center justify-center text-[10px]">
              3
            </span>
            Confirm
          </span>
        </div>

        <h2 className="text-sm font-semibold text-gray-700 mb-3">
          Order Summary
        </h2>
        <div className="flex gap-3 mb-4 pb-4 border-b border-gray-200">
          <div className="w-14 h-14 bg-gray-100 rounded-lg shrink-0" />
          <div>
            <p className="font-semibold">{deal.productName}</p>
            <p className="text-sm text-gray-500">by {deal.sellerName}</p>
            <p className="text-sm text-gray-500">{deal.description}</p>
          </div>
        </div>

        <div className="space-y-2 mb-4 pb-4 border-b border-gray-200 text-sm">
          <div className="flex justify-between text-gray-600">
            <span>Item Amount</span>
            <span>{deal.itemAmount.toFixed(2)} ETB</span>
          </div>
          <div className="flex justify-between text-gray-600">
            <span>Escrow Protection Fee</span>
            <span>{deal.escrowFee.toFixed(2)} ETB</span>
          </div>
        </div>

        <div className="flex justify-between font-bold mb-6">
          <span>Total</span>
          <span>{total.toFixed(2)} ETB</span>
        </div>

        <div className="bg-gray-50 rounded-xl p-4 mb-6">
          <p className="text-sm font-semibold mb-2">Why Escrow ET?</p>
          <ol className="text-sm text-gray-600 space-y-1 list-decimal list-inside">
            {whyEscrowSteps.map((step) => (
              <li key={step}>{step}</li>
            ))}
          </ol>
        </div>

        <button
          type="button"
          className="w-full bg-red-800 hover:bg-red-900 text-white font-semibold py-3.5 rounded-xl transition-colors"
        >
          Continue to Payment
        </button>
      </div>
    </div>
  );
}

export default Checkout;
