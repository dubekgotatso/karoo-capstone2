# Karoo Organics - Supplier Risk & Compliance Auditor

This repository contains the solution for the Karoo Organics Supplier Risk & Compliance Auditor project (Phase 2). 

## Project Components
1. **`auditor_views.sql`**: Contains the SQL definitions for the `v_supplier_health` monitoring view and the risk-flagging query. It aggregates supplier, orders, and harvest data to provide key health metrics, such as certification status, the number of orders in the last 90 days, and the latest versus rolling average harvest yields.
2. **`test_data.sql`**: Sample schema definitions and mock data to initialize the `Suppliers`, `Orders`, and `Harvests` tables. Contains specific cases designed to effectively test the distinct failure conditions (expiring cert, zero orders, dropping yield).
3. **`audit_suppliers.py`**: A Python script designed to automatically run the risk query, update flagged suppliers' statuses to 'Review', print out a summary of actions taken, and safely commit transactions with automatic rollback in case of runtime failures.

## Risk Logic
A supplier requires review if ANY of the following conditions are met:
- **Certification expiry <= 30 days**: The supplier's certification will either expire within the next month or has already expired. This poses a compliance and reputational risk to the organization.
- **Zero orders in the last 90 days**: Stagnant supplier connections are audited to ensure viability.
- **Latest yield < 80% of 3-harvest rolling average**: Disproportionate dropoffs in yield often indicate underlying business or operational risks.

## Compliance Error Handling Considerations
The database updates leverage database transactions (`conn.commit()`) along with explicit try/except blocks to rollback (`conn.rollback()`) changes in the event of network interruptions, constraints violations, or syntactic errors during the evaluation of supplier status. This fundamentally prevents partial schema updates and ensures accurate audits.