import psycopg2
import sys

def audit_suppliers():
    conn = None
    cur = None
    try:
        # Connect to your postgres DB
        # This is a sample connection string, adjust as needed or use environment variables
        conn = psycopg2.connect(
            dbname="karoo_db", 
            user="postgres", 
            password="password", 
            host="localhost"
        )
        cur = conn.cursor()

        # Run the risk query to find suppliers meeting the criteria
        risk_query = """
            SELECT supplier_id
            FROM v_supplier_health
            WHERE cert_status IN ('Expired', 'Expiring Soon')
               OR orders_90d = 0
               OR latest_yield < (0.8 * rolling_avg_yield);
        """
        cur.execute(risk_query)
        flagged_suppliers = cur.fetchall()

        if not flagged_suppliers:
            print("0 suppliers require review")
            return

        at_risk_ids = [row[0] for row in flagged_suppliers]

        # Use parameterised UPDATE for flagged suppliers
        update_query = """
            UPDATE Suppliers 
            SET status = %s, last_audit = CURRENT_DATE 
            WHERE supplier_id = %s
        """
        cur.executemany(update_query, [('Review', sid) for sid in at_risk_ids])
        
        # Commit changes permanently
        conn.commit()
        
        print(f"{len(at_risk_ids)} suppliers require review")

    except psycopg2.Error as e:
        print(f"Database error occurred: {e}")
        # Ensure no partial updates on error
        if conn:
            conn.rollback()
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        if conn:
            conn.rollback()
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()

if __name__ == "__main__":
    audit_suppliers()
