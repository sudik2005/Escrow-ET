const STORAGE_KEY = 'escrow-et-merchant-dev';

function randomHex(bytes) {
  const values = crypto.getRandomValues(new Uint8Array(bytes));
  return Array.from(values, (value) => value.toString(16).padStart(2, '0')).join('');
}

export function createSandboxKeys() {
  return {
    publicKey: `pk_test_${randomHex(16)}`,
    secretKey: `sk_test_${randomHex(24)}`,
    createdAt: new Date().toISOString(),
  };
}

export function loadDeveloperSettings() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      return null;
    }
    const parsed = JSON.parse(raw);
    if (!parsed?.publicKey || !parsed?.secretKey) {
      return null;
    }
    return parsed;
  } catch {
    return null;
  }
}

export function saveDeveloperSettings(settings) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(settings));
}

export function loadOrCreateDeveloperSettings() {
  const existing = loadDeveloperSettings();
  if (existing) {
    return existing;
  }
  const created = {
    ...createSandboxKeys(),
    webhookUrl: '',
  };
  saveDeveloperSettings(created);
  return created;
}
