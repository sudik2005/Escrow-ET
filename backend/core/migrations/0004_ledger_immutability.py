from django.db import migrations


FORWARD_SQL = r"""
CREATE OR REPLACE FUNCTION core_prevent_ledger_mutation()
RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'ledger rows are immutable; post a reversing transaction instead';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER core_ledgertransaction_immutable
BEFORE UPDATE OR DELETE ON core_ledgertransaction
FOR EACH ROW EXECUTE FUNCTION core_prevent_ledger_mutation();

CREATE TRIGGER core_ledgerentry_immutable
BEFORE UPDATE OR DELETE ON core_ledgerentry
FOR EACH ROW EXECUTE FUNCTION core_prevent_ledger_mutation();

CREATE OR REPLACE FUNCTION core_ledger_tx_must_balance()
RETURNS trigger AS $$
DECLARE
    tx_id uuid;
    debit_total numeric;
    credit_total numeric;
BEGIN
    tx_id := COALESCE(NEW.ledger_transaction_id, OLD.ledger_transaction_id);
    SELECT
        COALESCE(SUM(CASE WHEN direction = 'DEBIT' THEN amount ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN direction = 'CREDIT' THEN amount ELSE 0 END), 0)
    INTO debit_total, credit_total
    FROM core_ledgerentry
    WHERE ledger_transaction_id = tx_id;

    IF debit_total <> credit_total THEN
        RAISE EXCEPTION 'LedgerTransaction % does not balance (debit=% credit=%)',
            tx_id, debit_total, credit_total;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER core_ledger_entry_balanced
AFTER INSERT ON core_ledgerentry
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION core_ledger_tx_must_balance();
"""

REVERSE_SQL = r"""
DROP TRIGGER IF EXISTS core_ledger_entry_balanced ON core_ledgerentry;
DROP TRIGGER IF EXISTS core_ledgerentry_immutable ON core_ledgerentry;
DROP TRIGGER IF EXISTS core_ledgertransaction_immutable ON core_ledgertransaction;
DROP FUNCTION IF EXISTS core_ledger_tx_must_balance();
DROP FUNCTION IF EXISTS core_prevent_ledger_mutation();
"""


class Migration(migrations.Migration):

    dependencies = [
        ("core", "0003_seed_system_accounts"),
    ]

    operations = [
        migrations.RunSQL(FORWARD_SQL, REVERSE_SQL),
    ]
