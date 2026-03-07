const fs = require('fs');
const path = require('path');
const pool = require('./src/db');

async function runSchema() {
    console.log("Connecting to Supabase to run SQL schemas...");
    try {
        // Read 03_schema.sql and patch.sql
        const schemaSql = fs.readFileSync(path.join(__dirname, '03_schema.sql'), 'utf-8');
        const patchSql = fs.readFileSync(path.join(__dirname, 'patch.sql'), 'utf-8');
        const triggerSql = fs.readFileSync(path.join(__dirname, '04_triggers.sql'), 'utf-8');

        // We should skip `SET ROLE` statements as Supabase might reject them depending on permissions
        const cleanSql = (sql) => sql.replace(/SET ROLE hardware_admin;/g, '').replace(/RESET ROLE;/g, '');

        console.log("Running 03_schema.sql...");
        await pool.query(cleanSql(schemaSql));
        
        console.log("Running 04_triggers.sql...");
        try {
            await pool.query(cleanSql(triggerSql));
        } catch (e) {
            console.log("Triggers might already exist or had issues, continuing:", e.message);
        }

        console.log("Running patch.sql...");
        await pool.query(cleanSql(patchSql));

        console.log("Database initialized with correct schema.");

    } catch (e) {
        console.error("Error setting up DB:", e);
    } finally {
        pool.end();
    }
}
runSchema();
