import { useTheme } from '../context/useTheme'
import './LandingPage.css'
import heroImage from '../assets/hero.png'
import logoImage from '../assets/logo.png'

function LandingPage() {
  const { theme, toggleTheme } = useTheme()

  return (
    <div className="landing-page">
      {/* =====================================================
          HEADER
      ===================================================== */}
      <header className="landing-header">
        {/* Brand */}
        <a
          href="/"
          className="landing-header__brand"
          aria-label="Escrow ET home"
        >
         <div className="landing-header__shield">
  <img
    src={logoImage}
    alt="Escrow ET"
    className="landing-header__logo"
  />
</div>

          <span className="landing-header__brand-name">
            Escrow <span>ET</span>
          </span>
        </a>

        {/* Navigation */}
        <nav
          className="landing-header__nav"
          aria-label="Main navigation"
        >
          <a href="#how-it-works">
            How It Works
          </a>

          <a href="#buyers">
            For Buyers
          </a>

          <a href="#sellers">
            For Sellers
          </a>

          <a href="#developers">
            Developers
          </a>

          <a href="#about">
            About Us
          </a>
        </nav>

        {/* Header actions */}
        <div className="landing-header__actions">
          {/* Theme toggle */}
          <button
  type="button"
  className="landing-theme-toggle"
  onClick={toggleTheme}
  aria-label={
    theme === 'dark'
      ? 'Switch to light mode'
      : 'Switch to dark mode'
  }
  aria-pressed={theme === 'dark'}
>
  <span aria-hidden="true">
    {theme === 'dark' ? '☀' : '☾'}
  </span>
</button>

          <a
            href="/login"
            className="landing-header__login"
          >
            Log In
          </a>

          <a
            href="/register"
            className="landing-header__signup"
          >
            Get Started
          </a>
        </div>
      </header>

      <main>
        {/* =====================================================
            HERO
        ===================================================== */}
        <section className="landing-hero">
          <div className="landing-hero__content">
            <p className="landing-hero__eyebrow">
              Secure Digital Escrow
            </p>

            <h1 className="landing-hero__title">
              Buy and Sell
              <br />
              with total <span>confidence.</span>
            </h1>

            <p className="landing-hero__description">
              Escrow ET is Ethiopia's mobile-money-native
              escrow platform. Your money is safely locked
              until delivery is verified.
            </p>

            <div className="landing-hero__actions">
              <a
                href="/payment-links"
                className="landing-button landing-button--primary"
              >
                Create Payment Link
              </a>

              <a
                href="#how-it-works"
                className="landing-button landing-button--secondary"
              >
                <span
                  className="landing-button__play"
                  aria-hidden="true"
                >
                  ▶
                </span>

                Learn How It Works
              </a>
            </div>

            
          </div>

          <div className="landing-hero__visual">
            <div
              className="landing-hero__visual-glow"
              aria-hidden="true"
            />

            <img
              src={heroImage}
              alt="Escrow ET secure payment illustration"
            />
          </div>
        </section>

         {/* =====================================================
            STATISTICS
        ===================================================== */}
        <section className="landing-stats">
          <div className="landing-stat">
            <strong>10,245+</strong>
            <span>Total Transactions</span>
          </div>

          <div className="landing-stat">
            <strong>3,450+</strong>
            <span>Happy Users</span>
          </div>

          <div className="landing-stat">
            <strong>2.4M ETB+</strong>
            <span>Secured in Escrow</span>
          </div>

          <div className="landing-stat">
            <strong>99.8%</strong>
            <span>Successful Deliveries</span>
          </div>
        </section>

        {/* =====================================================
            HOW IT WORKS
        ===================================================== */}
        <section
          id="how-it-works"
          className="landing-process"
        >
          <div className="landing-section-heading">
            <p className="landing-section-heading__eyebrow">
              Simple & Secure
            </p>

            <h2 className="landing-section-title">
              How Escrow ET Works
            </h2>

            <p className="landing-section-description">
              A simple three-step process that keeps both
              buyers and sellers protected.
            </p>
          </div>

          <div className="landing-process__steps">
            {/* Step 1 */}
            <div className="landing-step">
              <div className="landing-step__top">
                <div className="landing-step__number">
                  1
                </div>

                <div
                  className="landing-step__icon"
                  aria-hidden="true"
                >
                  ▱
                </div>
              </div>

              <div className="landing-step__content">
                <h3>Create Deal</h3>

                <p>
                  Create a secure payment link and agree
                  on the transaction details.
                </p>
              </div>
            </div>

            <div
              className="landing-step__arrow"
              aria-hidden="true"
            >
              →
            </div>

            {/* Step 2 */}
            <div className="landing-step">
              <div className="landing-step__top">
                <div className="landing-step__number">
                  2
                </div>

                <div
                  className="landing-step__icon"
                  aria-hidden="true"
                >
                  ♢
                </div>
              </div>

              <div className="landing-step__content">
                <h3>Funds Locked</h3>

                <p>
                  The buyer sends payment and the funds
                  remain safely secured in escrow.
                </p>
              </div>
            </div>

            <div
              className="landing-step__arrow"
              aria-hidden="true"
            >
              →
            </div>

            {/* Step 3 */}
            <div className="landing-step">
              <div className="landing-step__top">
                <div className="landing-step__number">
                  3
                </div>

                <div
                  className="landing-step__icon"
                  aria-hidden="true"
                >
                  ▱
                </div>
              </div>

              <div className="landing-step__content">
                <h3>Delivery Verified</h3>

                <p>
                  Once delivery is confirmed, the funds
                  are released to the seller.
                </p>
              </div>
            </div>
          </div>
        </section>

     {/* ===================================================
    BUYERS / SELLERS
=================================================== */}

<section className="landing-audience" id="buyers">
  <div className="landing-audience__intro">
    <p className="landing-section-eyebrow">For Buyers</p>

    <h2>Pay with confidence.</h2>

    <p>
      Your payment stays protected until you receive what
      you paid for and confirm delivery.
    </p>

    <a href="/register" className="landing-audience__link">
      Start as a Buyer <span aria-hidden="true">→</span>
    </a>
  </div>

  <div className="landing-audience__intro" id="sellers">
    <p className="landing-section-eyebrow">For Sellers</p>

    <h2>Sell with certainty.</h2>

    <p>
      Know that your buyer's funds are secured before you
      deliver your product or service.
    </p>

    <a href="/register" className="landing-audience__link">
      Start as a Seller <span aria-hidden="true">→</span>
    </a>
  </div>
</section>


{/* ===================================================
    DEVELOPERS
=================================================== */}
<section
  id="developers"
  className="landing-developer"
>
  <div className="landing-developer__inner">

    {/* Code Preview */}
    <div className="landing-developer__code">
      <div className="landing-developer__window">

        <div className="landing-developer__window-bar">
          <div className="landing-developer__window-dots">
            <span />
            <span />
            <span />
          </div>

          

          <span
            className="landing-developer__window-icon"
            aria-hidden="true"
          >
            ◉
          </span>
        </div>

        <div className="landing-developer__code-body">
          <pre>
            <code>{`import { EscrowET } from "@escrow-et/sdk";

const client = new EscrowET({
  apiKey: "your_api_key"
});

async function createDeal() {
  const transaction = await client.createDeal({
    amount: 25000,
    currency: "ETB",
    buyer: "buyer@example.com",
    seller: "seller@example.com"
  });

  console.log("Secure Escrow Link:", transaction.url);
}`}</code>
          </pre>
        </div>

      </div>
    </div>


    {/* Developer Content */}
    <div className="landing-developer__content">

      <p className="landing-developer__eyebrow">
        Built for Developers
      </p>

      <h2 className="landing-developer__title">
        Integrate Trust into Your
        <br />
        E-Commerce Store
      </h2>

      <p className="landing-developer__description">
        Integrate secure escrow transactions into your
        application with just a few lines of code. Give
        your customers a safer way to buy and sell online.
      </p>


      {/* Features */}
      <div className="landing-developer__features">

        <div className="landing-developer__feature">
          <div
            className="landing-developer__feature-icon"
            aria-hidden="true"
          >
            ✓
          </div>

          <div>
            <h3>Native SDKs</h3>

            <p>
              Available for Node.js, Python, PHP, and Go.
            </p>
          </div>
        </div>


        <div className="landing-developer__feature">
          <div
            className="landing-developer__feature-icon"
            aria-hidden="true"
          >
            ✓
          </div>

          <div>
            <h3>Webhook Notifications</h3>

            <p>
              Get real-time updates when deals are created,
              verified, or completed.
            </p>
          </div>
        </div>

      </div>


      {/* Actions */}
      <div className="landing-developer__actions">

        <a
          href="/docs"
          className="landing-developer__button landing-developer__button--primary"
        >
          Read API Docs
        </a>

        <a
          href="/settings/developer"
          className="landing-developer__button landing-developer__button--secondary"
        >
          Get Sandbox Keys
        </a>

      </div>

    </div>

  </div>
</section>

        <section className="landing-info">
          <div className="landing-section-heading">
            <p className="landing-section-heading__eyebrow">
              Company
            </p>
            <h2 className="landing-section-title">
              About Escrow ET
            </h2>
            <p className="landing-section-description">
              Built in Ethiopia for buyers, sellers, and
              merchants who need funds held until delivery
              is confirmed.
            </p>
          </div>

          <div className="landing-info__grid">
            <article id="about" className="landing-info__card">
              <h3>About Us</h3>
              <p>
                Escrow ET holds payment until the buyer
                confirms delivery. Sellers get paid only
                after the goods or service arrive. The
                website mirrors the same Fayda-backed
                flows as the mobile app.
              </p>
            </article>

            <article id="security" className="landing-info__card">
              <h3>Security</h3>
              <p>
                Accounts are created with a Fayda QR
                payload. Escrow balances live in an
                immutable ledger on PostgreSQL. Payment
                is collected through Chapa. Secrets stay
                on the Django API, never in the browser.
              </p>
            </article>

            <article id="privacy" className="landing-info__card">
              <h3>Privacy</h3>
              <p>
                We store the phone number, role, and
                Fayda identifiers needed to open an
                account and settle a deal. We do not
                sell personal data. Contact us if you
                want your account closed.
              </p>
            </article>

            <article id="contact" className="landing-info__card">
              <h3>Contact</h3>
              <p>
                Questions about a deal, a dispute, or
                API access can go to the GitHub repo or
                your project teammates. This is a student
                build, not a licensed bank.
              </p>
              <a href="https://github.com/sudik2005/Escrow-ET">
                github.com/sudik2005/Escrow-ET
              </a>
            </article>

            <article id="terms" className="landing-info__card">
              <h3>Terms of Service</h3>
              <p>
                Use Escrow ET only for lawful goods and
                services. Creating a deal means you
                accept that funds stay locked until
                delivery is verified or a dispute is
                resolved. We can freeze a deal that
                looks fraudulent.
              </p>
            </article>

            <article id="refund" className="landing-info__card">
              <h3>Escrow Refund Policy</h3>
              <p>
                If delivery is not confirmed, or a
                dispute is decided for the buyer, the
                locked amount is refunded to the buyer.
                If delivery is verified, funds are
                released to the seller. Partial refunds
                follow the dispute outcome.
              </p>
            </article>

            <article id="requirements" className="landing-info__card">
              <h3>KYC Requirements</h3>
              <p>
                Sign up with a valid Fayda QR and an
                Ethiopian phone number. Sellers who
                create payment links must register as
                SELLER. Unverified or mismatched Fayda
                data is rejected at registration.
              </p>
            </article>
          </div>
        </section>
      </main>

      {/* =====================================================
          FOOTER
      ===================================================== */}
     <footer className="landing-footer">
  <div className="landing-footer__top">
    {/* Brand */}
    <div className="landing-footer__brand">
      <a href="/" className="landing-footer__logo">
        <img
          src={logoImage}
          alt="Escrow ET"
          className="landing-footer__logo-image"
        />
        <span className="landing-footer__brand-name">
          Escrow <span>ET</span>
        </span>
      </a>

      <p className="landing-footer__description">
        Secure digital escrow for Ethiopia's mobile-money
        economy. Protecting buyers and sellers with every
        transaction.
      </p>

      <div className="landing-footer__status">
        <span
          className="landing-footer__status-dot"
          aria-hidden="true"
        />
        Secure & Trusted Escrow Platform
      </div>
    </div>

    {/* Navigation */}
    <div className="landing-footer__navigation">
      {/* Product */}
      <div className="landing-footer__column">
        <h3>Product</h3>

        <a href="#how-it-works">
          How It Works
        </a>

        <a href="/payment-links">
          Payment Links
        </a>

        <a href="#buyers">
          For Buyers
        </a>

        <a href="#sellers">
          For Sellers
        </a>

        <a href="#developers">
          Developers
        </a>
      </div>

      {/* Company */}
      <div className="landing-footer__column">
        <h3>Company</h3>

        <a href="#about">
          About Us
        </a>

        <a href="#security">
          Security
        </a>

        <a href="#privacy">
          Privacy
        </a>

        <a href="#contact">
          Contact
        </a>
      </div>

      {/* Legal */}
      <div className="landing-footer__column">
        <h3>Legal</h3>

        <a href="#terms">
          Terms of Service
        </a>

        <a href="#privacy">
          Privacy Policy
        </a>

        <a href="#refund">
          Escrow Refund Policy
        </a>

        <a href="#requirements">
          KYC Requirements
        </a>
      </div>
    </div>
  </div>

  {/* Bottom */}
  <div className="landing-footer__bottom">
    <p className="landing-footer__copyright">
      © 2026 Escrow ET. All rights reserved.
    </p>

    <div className="landing-footer__socials">
      <a href="#contact">
        Contact
      </a>
      <a
        href="https://github.com/sudik2005/Escrow-ET"
        aria-label="GitHub"
        target="_blank"
        rel="noreferrer"
      >
        GitHub
      </a>
    </div>
  </div>
</footer>
    </div>
  )
}

export default LandingPage